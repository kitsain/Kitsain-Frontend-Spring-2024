import 'dart:io';

import 'package:flutter/material.dart';

class editImageWidget extends StatefulWidget {
  final List<File> images;
  final List<String> stringImages;

  const editImageWidget(
      {super.key, required this.images, required this.stringImages});

  @override
  _editImageWidgetState createState() => _editImageWidgetState();
}

class _editImageWidgetState extends State<editImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 355,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: widget.images.isNotEmpty
          ? _buildCarousel(context)
          : Container(
              height: 250,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: widget.images.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(context, itemIndex);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, int itemIndex) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.images.isNotEmpty
                ? Image.file(
                    widget.images[itemIndex],
                    fit: BoxFit.cover,
                    width: 1000,
                  )
                : Image.network(
                    'http://nocng.id.vn:9mons/${widget.stringImages[itemIndex]}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: () {
                // Add your logic to delete the image
                setState(() {
                  widget.images.removeAt(itemIndex);
                });
              },
              child: const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 16,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
