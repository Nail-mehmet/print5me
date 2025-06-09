class ModelWHid {
  final bool accessible;
  final String title;
  final String category;
  final String createdBy;
  final List<String> tags;
  final String additional;
  final List<String> url;

  ModelWHid({
    required this.accessible,
    required this.title,
    required this.category,
    required this.createdBy,
    required this.tags,
    required this.additional,
    required this.url,
  });

  factory ModelWHid.fromJson(Map<String, dynamic> json) {
    return ModelWHid(
      accessible: json['accessible'],
      title: json['title'],
      category: json['category'],
      createdBy: json['createdBy'],
      tags: List<String>.from(json['tags']),
      additional: json['additional'],
      url: List<String>.from(json['url']),
    );
  }
}

class Model extends ModelWHid {
  final String modelid;
  final String pic;

  Model({
    required this.modelid,
    required this.pic,
    required bool accessible,
    required String title,
    required String category,
    required String createdBy,
    required List<String> tags,
    required String additional,
    required List<String> url,
  }) : super(
    accessible: accessible,
    title: title,
    category: category,
    createdBy: createdBy,
    tags: tags,
    additional: additional,
    url: url,
  );

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      modelid: json['modelid'] as String? ?? '',
      pic: json['pic'] as String? ?? '',
      accessible: json['accessible'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      tags: json['tags'] is List
          ? List<String>.from(json['tags'])
          : (json['tags'] is String ? [json['tags']] : []),
      additional: json['additional'] as String? ?? '',
      url: json['url'] is List
          ? List<String>.from(json['url'])
          : (json['url'] is String ? [json['url']] : []),
    );
  }


}
