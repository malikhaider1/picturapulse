import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:picturapulse/api/pexelapi.dart';


class ImageGrid extends StatefulWidget {
  const ImageGrid({super.key});

  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
   late Future<List<dynamic>> _images;
  String _currentCategory = 'landscape'; // Default category

  @override
  void initState() {
    super.initState();
    _images = PexelsApi().fetchImages(_currentCategory); // Fetch default category images
  }

  Future<void> _downloadImage(String url) async {
    try {
      // Check for storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied')),
        );
        return;
      }

      // Get the image data
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get the temporary directory
        final directory = await getTemporaryDirectory();
        // Create a file to save the image
        final filePath = '${directory.path}/${url.split('/').last}';
        final file = File(filePath);
        // Write the image data to the file
        await file.writeAsBytes(response.bodyBytes);
        // Save the image to the gallery
        final result = await ImageGallerySaver.saveFile(filePath);
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to gallery')),
          );
        } else {
          throw Exception('Failed to save image to gallery');
        }
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  void _updateCategory(String category) {
    setState(() {
      _currentCategory = category;
      _images = PexelsApi().fetchImages(_currentCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PicturApulse'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _updateCategory,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'nature',
                child: Text('Nature'),
              ),
              const PopupMenuItem(
                value: 'dark',
                child: Text('Dark'),
              ),
              // Add more categories as needed
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _images,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images found'));
          }
          final images = snapshot.data;

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            itemCount: images!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _downloadImage(images[index]),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
