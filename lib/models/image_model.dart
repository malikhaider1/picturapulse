class ImageModel {
  final String url;
  final int? height;
  final int? width;
  final int? id;
  final String largeUrl;
  final String large2xl;
  final String original;

  ImageModel({required this.url,required this.width,required this.height,required this.id, required this.largeUrl,required this.large2xl, required this.original});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['src']['medium'],
      height: json['height'] ,
      width: json['width'],
      id: json['id'],
      largeUrl: json['src']['large'],
      large2xl: json['src']['large2x'],
      original: json['src']['original'],


    );
  }
}
