import 'package:flutter/material.dart';

class RetryImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const RetryImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<RetryImage> createState() => _RetryImageState();
}

class _RetryImageState extends State<RetryImage> {
  Key _imageKey = UniqueKey();

  void _retry() {
    setState(() {
      _imageKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.imageUrl,
      key: _imageKey, // 绑定 Key
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      // 关键：加载失败的处理
      errorBuilder: (context, error, stackTrace) {
        return GestureDetector(
          onTap: _retry, // 点击触发重试
          child: Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey, size: 30),
                SizedBox(height: 4),
                Text(
                  "点击重试",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
