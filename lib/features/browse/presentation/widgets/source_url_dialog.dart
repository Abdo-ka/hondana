import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/domain/source_preferences.dart';

/// Edits a source's base URL — these sites hop domains frequently, so users
/// can repoint a source without waiting for an app update. Resolves true when
/// the URL changed.
Future<bool?> showSourceUrlDialog(BuildContext context, HttpSourceBase source) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _SourceUrlDialog(source: source),
  );
}

class _SourceUrlDialog extends StatefulWidget {
  const _SourceUrlDialog({required this.source});

  final HttpSourceBase source;

  @override
  State<_SourceUrlDialog> createState() => _SourceUrlDialogState();
}

class _SourceUrlDialogState extends State<_SourceUrlDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.source.baseUrl);
  final ValueNotifier<String?> _error = ValueNotifier(null);

  @override
  void dispose() {
    _controller.dispose();
    _error.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      _error.value = 'browse.edit_url_invalid'.tr();
      return;
    }
    getIt<SourcePreferences>().setUrlOverride(
      widget.source.id,
      text == widget.source.defaultBaseUrl ? null : text,
    );
    Navigator.of(context).pop(true);
  }

  void _reset() {
    getIt<SourcePreferences>().setUrlOverride(widget.source.id, null);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final overridden =
        getIt<SourcePreferences>().urlOverride(widget.source.id) != null;
    return AlertDialog(
      title: AppText.titleMedium(widget.source.name),
      content: ValueListenableBuilder<String?>(
        valueListenable: _error,
        builder: (context, error, _) => TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: 'browse.edit_url'.tr(),
            helperText: widget.source.defaultBaseUrl,
            errorText: error,
          ),
          onSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const AppText.labelLarge('common.cancel'),
        ),
        if (overridden)
          TextButton(
            onPressed: _reset,
            child: const AppText.labelLarge('common.reset'),
          ),
        FilledButton(
          onPressed: _save,
          child: const AppText.labelLarge('common.save'),
        ),
      ],
    );
  }
}
