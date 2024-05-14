import 'package:flutter/material.dart';

class EditImageWidget extends StatefulWidget {
  final List<String> stringImages;
  final bool feedImages;

  const EditImageWidget({
    super.key,
    required this.stringImages,
    required this.feedImages,
  });

  @override
  _EditImageWidgetState createState() => _EditImageWidgetState();
}

class _EditImageWidgetState extends State<EditImageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 355,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: widget.stringImages.isNotEmpty
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
            itemCount: widget.stringImages.length,
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
            child: Image.network(
              'http://40.113.61.81:9000/commons/${widget.stringImages[itemIndex]}',
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
                    widget.stringImages.removeAt(itemIndex);
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
