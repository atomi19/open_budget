import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  final File image;

  const ImagePreview({
    super.key,
    required this.image,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final TransformationController _controller = TransformationController();

  void _resetZoom() {
    _controller.value = Matrix4.diagonal3Values(
      1.0, 
      1.0, 
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: const Icon(Icons.chevron_left, color: Colors.white,)
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTap: () {
            final currentScale = _controller.value.getMaxScaleOnAxis();

            if(currentScale > 1.0) _resetZoom();
          },
          child: InteractiveViewer(
            transformationController: _controller,
            clipBehavior: Clip.none,
            minScale: 1,
            maxScale: 5,
            child: Image.file(
              widget.image,
              fit: BoxFit.contain,
            ),
          ),
        )
      )
    );
  }
}