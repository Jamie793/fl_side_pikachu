import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/providers/app.dart';
import 'package:pikachu/views/thumb_list_view.dart';
import 'package:pikachu/datas/models/site_thumb.dart';

class MomentPage extends ConsumerStatefulWidget {
  const MomentPage({super.key});

  @override
  ConsumerState<MomentPage> createState() => _MomentPageState();
}

class _MomentPageState extends ConsumerState<MomentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '动态'),
          Tab(text: '收藏'),
          Tab(text: '关注'),
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoment(),
          // ThumbListView(category: "hot"),
          // ThumbListView(category: "fav"),
        ],
      ),
    );
  }

  Future<List<SiteThumb>> _fetchFollowedMoment() async {
    return ref.read(activeSiteProvider).getFollowedMoment();
  }

  Widget _buildMoment() {
    return ThumbListView(
      site: ref.watch(activeSiteProvider),
      onFetch: () async {
        return await _fetchFollowedMoment();
      },
    );
  }
}
