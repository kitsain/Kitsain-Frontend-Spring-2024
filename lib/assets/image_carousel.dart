import 'dart:io';
import 'package:flutter/material.dart';

class EditImageWidget extends StatefulWidget {
  final List<File> images;
  final List<String> stringImages;
  final bool feedImages;

  const EditImageWidget(
      {super.key,
      required this.images,
      required this.stringImages,
      required this.feedImages});

  @override
  _EditImageWidgetState createState() => _EditImageWidgetState();
}

class _EditImageWidgetState extends State<EditImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 355,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: widget.images.isNotEmpty || widget.stringImages.isNotEmpty
          ? _buildCarousel(context, widget.feedImages)
          : Container(
              height: 250,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildCarousel(BuildContext context, bool feedImages) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount:
                feedImages ? widget.stringImages.length : widget.images.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(context, itemIndex, feedImages);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCarouselItem(
      BuildContext context, int itemIndex, bool feedImages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: feedImages == false
                ? Image.file(
                    widget.images[itemIndex],
                    fit: BoxFit.cover,
                    width: 1000,
                  )
                : Image.network(
                    'http://nocng.id.vn:9000/commons/${widget.stringImages[itemIndex]}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),
          if (feedImages == false)
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
