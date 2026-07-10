import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/network/app_http.dart';

/// In-app browser for a source site. Besides plain viewing, this is the
/// Cloudflare bypass: it runs with the same User-Agent as the app's Dio
/// clients and saves the site cookies (cf_clearance et al) into
/// [WebCookieStore] on every navigation, so once the user passes the
/// challenge here, normal source requests start succeeding.
@RoutePage()
class SourceWebViewPage extends StatefulWidget {
  const SourceWebViewPage({
    required this.initialUrl,
    this.title,
    super.key,
  });

  final String initialUrl;
  final String? title;

  @override
  State<SourceWebViewPage> createState() => _SourceWebViewPageState();
}

class _SourceWebViewPageState extends State<SourceWebViewPage> {
  InAppWebViewController? _controller;
  double _progress = 0;

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
          if (_progress < 1)
            LinearProgressIndicator(value: _progress == 0 ? null : _progress),
          Expanded(
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri(widget.initialUrl)),
              initialSettings: InAppWebViewSettings(
                userAgent: appUserAgent,
                javaScriptEnabled: true,
              ),
              onWebViewCreated: (c) => _controller = c,
              onProgressChanged: (c, p) {
                if (mounted) setState(() => _progress = p / 100);
              },
              onLoadStop: (c, url) => _captureCookies(url),
            ),
          ),
        ],
      ),
    );
  }
}
