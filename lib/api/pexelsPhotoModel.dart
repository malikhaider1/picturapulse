class PexelPhotoModel {
  int? id;
  int? width;
  int? height;
  String? url;
  String? photographer;
  String? photographerUrl;
  int? photographerId;
  String? avgColor;
  Src? src;
  bool? liked;
  String? alt;

  PexelPhotoModel(
      {this.id,
        this.width,
        this.height,
        this.url,
        this.photographer,
        this.photographerUrl,
        this.photographerId,
        this.avgColor,
        this.src,
        this.liked,
        this.alt});

  PexelPhotoModel.fromJson(Map<String, dynamic> json) {


    id = json['id'];
    width = json['width'];
    height = json['height'];
    url = json['url'];
    photographer = json['photographer'];
    photographerUrl = json['photographer_url'];
    photographerId = json['photographer_id'];
    avgColor = json['avg_color'];
    src = json['src'] != null ? Src.fromJson(json['src']) : null;
    liked = json['liked'];
    alt = json['alt'];
  }


}

class Src {
  String? original;
  String? large2x;
  String? large;
  String? medium;
  String? small;
  String? portrait;
  String? landscape;
  String? tiny;

  Src(
      {this.original,
        this.large2x,
        this.large,
        this.medium,
        this.small,
        this.portrait,
        this.landscape,
        this.tiny});

  Src.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    large2x = json['large2x'];
    large = json['large'];
    medium = json['medium'];
    small = json['small'];
    portrait = json['portrait'];
    landscape = json['landscape'];
    tiny = json['tiny'];
  }

}