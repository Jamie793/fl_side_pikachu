import 'dart:async';
import 'package:app_links/app_links.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pikachu/providers/providers.dart';
import 'package:pikachu/datas/services/bases/site_server.dart';
import 'package:pikachu/datas/services/bases/site_auth.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends ConsumerState<LoginPage> {
  late final WebViewController _controller;
  SiteServer? siteServer;
  String loginUrl = 'https://www.bilibili.com';
  late AppLinks _appLinks;
  late StreamSubscription<Uri> _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => {},
          onPageFinished: (url) {},
          onUrlChange: (url) {},
        ),
      );

    siteServer = ref.read(activeSiteProvider);
    if (siteServer != null) {
      final loginUrl = siteServer?.getLoginUrl() ?? '';
      this.loginUrl = loginUrl;
      print(this.loginUrl);
      _controller.loadRequest(Uri.parse(this.loginUrl));
    }
  }

  void _initDeepLinks() {
    try {
      _appLinks = AppLinks();
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
        final siteServer = ref.read(activeSiteProvider);
        if (siteServer is SiteAuth) {
          await (siteServer as SiteAuth).handleLogin(uri);
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _linkSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async => await launchUrl(
              Uri.parse(loginUrl),
              mode: LaunchMode.inAppBrowserView,
            ),
            icon: const Icon(Icons.open_in_browser),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
