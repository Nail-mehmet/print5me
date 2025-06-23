import 'dart:convert';

class IlanWHid {
  final String budget;
  final String createdBy;
  final bool custom;
  final String filamentType;
  final String fillRate;
  final String support;
  final String title;
  final String modelid;
  final List<String> offerIds;
  final String note;
  final String? acceptedOffer;
  final String? acceptedOdeme;
  final List<String>? fileURL;
  final String? pic;
  final DateTime createdAt;
  final DateTime updatedAt;

  IlanWHid({
    required this.budget,
    required this.createdBy,
    required this.custom,
    required this.filamentType,
    required this.fillRate,
    required this.support,
    required this.title,
    required this.modelid,
    required this.offerIds,
    required this.note,
    this.acceptedOffer,
    this.acceptedOdeme,
    this.fileURL,
    this.pic,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'budget': budget,
    'createdBy': createdBy,
    'custom': custom,
    'filamentType': filamentType,
    'fillRate': fillRate,
    'support': support,
    'title': title,
    'modelid': modelid,
    'offerIds': offerIds,
    'note': note,
    'acceptedOffer': acceptedOffer,
    'acceptedOdeme': acceptedOdeme,
    'fileURL': fileURL,
    'pic': pic,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
List<String> parseStringList(dynamic input) {
  try {
    if (input is List) {
      return input.map((e) => e.toString()).toList();
    } else if (input is String) {
      final decoded = jsonDecode(input);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    }
  } catch (e) {
  }
  return [];
}

DateTime? parseDateTime(dynamic input) {
  try {
    if (input is String) {
      return DateTime.parse(input);
    } else if (input is Map && input.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(input['_seconds'] * 1000);
    } else if (input is Map && input.containsKey('date')) {
      return DateTime.parse(input['date']);
    }
  } catch (e) {
  }
  return null;
}


class Ilan extends IlanWHid {
  final String ilanId;
  final DateTime? acceptedAt;

  Ilan({
    required this.ilanId,
    required String budget,
    required String createdBy,
    required bool custom,
    required String filamentType,
    required String fillRate,
    required String support,
    required String title,
    required String modelid,
    required List<String> offerIds,
    required String note,
    String? acceptedOffer,
    String? acceptedOdeme,
    List<String>? fileURL,
    String? pic,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.acceptedAt,
  }) : super(
    budget: budget,
    createdBy: createdBy,
    custom: custom,
    filamentType: filamentType,
    fillRate: fillRate,
    support: support,
    title: title,
    modelid: modelid,
    offerIds: offerIds,
    note: note,
    acceptedOffer: acceptedOffer,
    acceptedOdeme: acceptedOdeme,
    fileURL: fileURL,
    pic: pic,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory Ilan.fromJson(Map<String, dynamic> json) {
    return Ilan(
      ilanId: json['ilanId'],
      fileURL: parseStringList(json['fileURL']),



      pic: json['pic'],
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      acceptedAt: parseDateTime(json['acceptedAt']),
      budget: json['budget'],
      createdBy: json['createdBy'],
      custom: json['custom'],
      filamentType: json['filamentType'],
      fillRate: json['fillRate'],
      support: json['support'],
      title: json['title'],
      modelid: json['modelid'],
      offerIds: json['offerIds'] is String
          ? List<String>.from(jsonDecode(json['offerIds']))
          : List<String>.from(json['offerIds'] ?? []),
      note: json['note'],
      acceptedOffer: json['acceptedOffer'],
      acceptedOdeme: json['acceptedOdeme'],
    );
  }





  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['ilanId'] = ilanId;
    if (acceptedAt != null) {
      json['acceptedAt'] = acceptedAt!.toIso8601String();
    }
    return json;
  }
}