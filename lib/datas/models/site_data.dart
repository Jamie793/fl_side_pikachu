class SiteData<M> {
  final List<M> data;
  
  final Object? nextOffset; 
  
  final bool hasMore;

  SiteData({required this.data, this.nextOffset, this.hasMore = false});
}