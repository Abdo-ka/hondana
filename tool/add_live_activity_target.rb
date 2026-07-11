# One-shot: adds the DownloadActivityExtension WidgetKit target to
# Runner.xcodeproj and embeds it in Runner. Idempotent — re-running exits if
# the target already exists. Run from the repo root:
#   ruby tool/add_live_activity_target.rb
require 'xcodeproj'

PROJECT = File.expand_path('../ios/Runner.xcodeproj', __dir__)
EXT_NAME = 'DownloadActivityExtension'

project = Xcodeproj::Project.open(PROJECT)
if project.targets.any? { |t| t.name == EXT_NAME }
  puts "#{EXT_NAME} target already exists — nothing to do."
  exit 0
end
runner = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target not found'

ext = project.new_target(:app_extension, EXT_NAME, :ios, '16.1')

# --- file references ---------------------------------------------------------
ext_group = project.main_group.new_group(EXT_NAME, EXT_NAME)
shared_group = project.main_group.new_group('Shared', 'Shared')

%w[DownloadActivityBundle.swift DownloadActivityLiveActivity.swift].each do |f|
  ext.source_build_phase.add_file_reference(ext_group.new_file(f))
end
ext_group.new_file('Info.plist')

attrs = shared_group.new_file('DownloadActivityAttributes.swift')
ext.source_build_phase.add_file_reference(attrs)
runner.source_build_phase.add_file_reference(attrs)

bridge = project.main_group['Runner'].new_file('LiveActivityBridge.swift')
runner.source_build_phase.add_file_reference(bridge)

# --- build settings ----------------------------------------------------------
generated_xcconfig = project.files.find { |f| f.path == 'Flutter/Generated.xcconfig' }
ext.build_configurations.each do |config|
  # FLUTTER_BUILD_NAME/NUMBER for the version settings below; App Store
  # validation requires the extension's version to match the app's.
  config.base_configuration_reference = generated_xcconfig
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.mihonx.mihonx.DownloadActivity'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.1'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['INFOPLIST_FILE'] = "#{EXT_NAME}/Info.plist"
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = 'M8326784QX'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  config.build_settings['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
    '$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks'
  ]
end

# --- embed in Runner ---------------------------------------------------------
runner.add_dependency(ext)
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.dst_subfolder_spec = '13' # PlugIns
embed.dst_path = ''
bf = embed.add_file_reference(ext.product_reference)
bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

project.save
puts "Added #{EXT_NAME} target (configs: #{ext.build_configurations.map(&:name).join(', ')})"
