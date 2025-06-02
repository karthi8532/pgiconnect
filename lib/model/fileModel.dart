class FileModel {
  final String filename;
  final String url;
  final String type;

  FileModel({
    required this.filename,
    required this.url,
    required this.type,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      filename: json['filename'],
      url: json['url'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'url': url,
      'type': type,
    };
  }
}
