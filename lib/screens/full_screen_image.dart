import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturapulse/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:picturapulse/models/image_provider.dart' as img;
import 'package:saver_gallery/saver_gallery.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  final String large2x;
  final String large;
  final int? height;
  final int? width;

  const FullScreenImage(
      {super.key,
      required this.imageUrl,
      required this.height,
      required this.width,
      required this.large2x,
      required this.large});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  // Future<void> downloadImage(String url) async {
  //   try {
  //     if(await Permission.storage.isGranted){
  //       final response = await http.get(Uri.parse(url));
  //       if (response.statusCode == 200) {
  //         final directory = await getTemporaryDirectory();
  //         final filePath = '${directory.path}/${url.split('/').last}';
  //         final file = File(filePath);
  //         await file.writeAsBytes(response.bodyBytes);
  //         final result = await ImageGallerySaver.saveFile(filePath);
  //         if (result['isSuccess']) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Image saved to gallery')),
  //           );
  //         } else {
  //           throw Exception('Failed to save image to gallery');
  //         }
  //       } else {
  //         throw Exception('Failed to load image');
  //       }
  //     }
  //     if (await Permission.storage.isDenied) {
  //       await Permission.storage.request();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Permission Denied')),
  //       );
  //       return;
  //     } else if (await Permission.storage.isPermanentlyDenied) {
  //       await openAppSettings();}
  //
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error saving image: $e')),
  //     );
  //   }
  // }
  Future<void> downloadImage(String url) async {
    try {
      // Fetch image from API
      print(url);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get the temporary directory and create the file path
        final directory = await getTemporaryDirectory();
        final fileName = url.split('/').last.split('?').first;
        print(fileName);
        final filePath = '${directory.path}/$fileName';
        print(filePath);
        final file = File(filePath);

        // Write the image bytes to the file
        await file.writeAsBytes(response.bodyBytes);

        // Save image to gallery
        final result = await SaverGallery.saveFile(
            name: fileName,
            file: filePath,
            androidExistNotSave: true,
            androidRelativePath: "Pictures");

        // Provide feedback to the user
        final message = result.isSuccess
            ? 'Image saved to gallery'
            : 'Failed to save image to gallery';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Card(
        color: Colors.white,
        child: Consumer<img.ImageProvider>(builder: (context, provider, child) {
          return SizedBox(
            height: screenHeight % 91,
            width: screenWidth % 85,
            child: IconButton(
                onPressed: () async {
                  final selectedSizeKey =
                      await showSizeSelectionDialog(context);
                  if (selectedSizeKey == null) {
                    // User canceled the dialog or didn't select anything
                    return;
                  }
                  provider.changeImageSize(selectedSizeKey);

                  if (provider.currentSizeKey == "original") {
                    print('original');
                    await downloadImage(widget.imageUrl);
                  } else if (provider.currentSizeKey == "large2x") {
                    print('large2x');
                    await downloadImage(widget.large2x);
                  } else if (provider.currentSizeKey == "large") {
                    print('large');
                    await downloadImage(widget.large);
                  }
                },
                icon: const Icon(Icons.download)),
          );
        }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: InstaImageViewer(
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
