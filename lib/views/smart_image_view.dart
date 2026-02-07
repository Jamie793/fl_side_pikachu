import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SmartImageView extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double? cacheWidth;
  final double? cacheHeight;
  final BoxFit fit;
  final Map<String, String> headers;

  const SmartImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    this.headers = const {},
    this.fit = BoxFit.cover,
  });

  @override
  State<SmartImageView> createState() => _SmartImageViewState();
}

class _SmartImageViewState extends State<SmartImageView> {
  Key _imageKey = UniqueKey();

  void _retry() {
    setState(() {
      _imageKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      key: _imageKey,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      httpHeaders: widget.headers,
      memCacheWidth: widget.cacheWidth?.toInt(),
      memCacheHeight: widget.cacheHeight?.toInt(),
      placeholder: (context, url) =>
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      errorWidget: (context, url, error) => GestureDetector(
        onTap: _retry,
        child: Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 30),
              SizedBox(height: 4),
              Text("点击重试", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
