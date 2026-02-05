import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/pages/pages.dart';
import 'package:pikachu/datas/models/site_type.dart';
import 'package:pikachu/providers/pixiv.dart';
import 'package:pikachu/providers/providers.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class AppPage extends ConsumerStatefulWidget {
  const AppPage({super.key});

  @override
  ConsumerState<AppPage> createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> {
  int _selectedIndex = 0;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  late final List<Widget> _pages = [
    const HomePage(),
    const MomentPage(),
    const MinePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _handlePixivLink(Uri uri) {
    print(uri.toString());
    if (uri.scheme == 'pixiv' &&
        (uri.host == 'account' || uri.path.contains('callback'))) {
      final code = uri.queryParameters['code'];
      if (code != null) {
        print('成功获取 Code: $code');
        // 这里跳转到你的登录处理逻辑
      }
    }
  }

  @override
  void dispose() {
    // 取消订阅，避免内存泄漏
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pikachu')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '动态'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('assets/images/wallpaper.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: null,
            ),
            ListTile(
              title: const Text('Pixiv'),
              onTap: () => ref
                  .read(activeSiteProvider.notifier)
                  .changeSite(SiteType.pixiv),
            ),
            ListTile(
              title: const Text('Pika'),
              onTap: () => ref
                  .read(activeSiteProvider.notifier)
                  .changeSite(SiteType.pika),
            ),
            ListTile(
              title: const Text('E-Hentai'),
              onTap: () => ref
                  .read(activeSiteProvider.notifier)
                  .changeSite(SiteType.ehentai),
            ),
          ],
        ),
      ),
      body: ref.watch(currentLoginProvider)
          ? IndexedStack(index: _selectedIndex, children: _pages)
          : LoginPage(),
    );
  }
}
