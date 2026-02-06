import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/pages/pages.dart';
import 'package:pikachu/datas/models/site_type.dart';
import 'package:pikachu/providers/providers.dart';

class AppPage extends ConsumerStatefulWidget {
  const AppPage({super.key});

  @override
  ConsumerState<AppPage> createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const HomePage(),
    const MomentPage(),
    const MinePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = ref.watch(currentLoginProvider);
    return Scaffold(
      appBar: AppBar(
        title: isLogin
            ? const Text('Pikachu')
            : Text(
                '登录${(ref.watch(preferenceProvider).value?['currentSite'] as SiteType?)?.name ?? 'Pixiv'}',
              ),
      ),
      bottomNavigationBar: isLogin
          ? BottomNavigationBar(
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
            )
          : null,
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
      body: isLogin
          ? IndexedStack(index: _selectedIndex, children: _pages)
          : LoginPage(),
    );
  }
}
