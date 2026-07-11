import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/network/app_http.dart';

/// In-app browser for a source site. Besides plain viewing, this is the
/// Cloudflare bypass: it runs with the same User-Agent as the app's Dio
/// clients and saves the site cookies (cf_clearance et al) into
/// [WebCookieStore] on every navigation, so once the user passes the
/// challenge here, normal source requests start succeeding.
@RoutePage()
class SourceWebViewPage extends StatefulWidget {
  const SourceWebViewPage({required this.initialUrl, this.title, super.key});

  final String initialUrl;
  final String? title;

  @override
  State<SourceWebViewPage> createState() => _SourceWebViewPageState();
}

class _SourceWebViewPageState extends State<SourceWebViewPage> {
  InAppWebViewController? _controller;

  /// Page load progress (0..1); drives the top [LinearProgressIndicator].
  final ValueNotifier<double> _progress = ValueNotifier(0);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  /// Persists the site's current cookies (cf_clearance et al) keyed by host so
  /// the app's Dio clients can replay them past the Cloudflare challenge.
  Future<void> _captureCookies(WebUri? url) async {
    if (url == null || url.host.isEmpty) return;
    final cookies = await CookieManager.instance().getCookies(url: url);
    final header = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    await getIt<WebCookieStore>().save(url.host, header);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: widget.title ?? Uri.parse(widget.initialUrl).host,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (context, progress, _) => progress < 1
                ? LinearProgressIndicator(
                    value: progress == 0 ? null : progress,
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              initialSettings: InAppWebViewSettings(
                userAgent: appUserAgent,
                javaScriptEnabled: true,
              ),
              onWebViewCreated: (c) => _controller = c,
              onProgressChanged: (c, p) => _progress.value = p / 100,
              onLoadStop: (c, url) => _captureCookies(url),
            ),
          ),
        ],
      ),
    );
  }
}
