import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:picturapulse/screens/full_screen_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:picturapulse/models/image_provider.dart' as img;

class ImageGrid extends StatefulWidget {
  const ImageGrid({super.key});

  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  String _currentCategory = 'nature'; // Default category
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Using SchedulerBinding to delay the fetch operation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<img.ImageProvider>(context, listen: false)
          .fetchImages(_currentCategory);
    });
  }



  void _updateCategory(String category) {
    setState(() {
      _currentCategory = category;
    });
    Provider.of<img.ImageProvider>(context, listen: false)
        .fetchImages(_currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<img.ImageProvider>(context);

    return Form(
      autovalidateMode: AutovalidateMode.always,
      onChanged: () {
        Form.of(primaryFocus!.context!).save();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('PicturApulse'), actions: [
          SizedBox(
            height: 40,
            width: MediaQuery.sizeOf(context).width / 1.6,
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onFieldSubmitted: (string) {
                _currentCategory = string.isEmpty ? 'nature' : string;
                _updateCategory(_currentCategory);
              },
            ),
          ),
        ]),
        body: Stack(children: [
          imageProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  itemCount: imageProvider.images.length,
                  itemBuilder: (context, index) {
                    final image = imageProvider.images[index];
                    return GestureDetector(
                      // onTap: () => _downloadImage(image.url),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imageUrl: image.original,
                            height: image.height,
                            width: image.width,
                            large2x: image.large2xl,
                            large: image.largeUrl,
                          ),
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: image.url,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    );
                  },
                ),
          Consumer<img.ImageProvider>(
            builder: (context,provider, child){
              return Positioned(
                  top: MediaQuery
                      .sizeOf(context)
                      .height / 1.2,
                  child: SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.pageLoadMore();
                        provider.fetchImages(_currentCategory);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                        // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),

                        elevation: 5,
                        // Shadow elevation
                        shadowColor: Colors.black,
                      ),
                      child: const Text("Load More", style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ));
            })
        ]),
      ),
    );
  }
}



Future<String?> showSizeSelectionDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return Consumer<img.ImageProvider>(
        builder: (BuildContext context, value, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Choose Image Size', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop('large');
                  },
                  child: Text('Large'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop('large2x');
                  },
                  child: Text('Large2x'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop('original');
                  },
                  child: Text('Original'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
