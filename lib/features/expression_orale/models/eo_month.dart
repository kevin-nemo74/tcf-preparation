import 'eo_party.dart';

class EOMonth {
  final String id;
  final String examTitle;
  final List<EOParty> parties;

  const EOMonth({
    required this.id,
    required this.examTitle,
    required this.parties,
  });

  factory EOMonth.fromJson(Map<String, dynamic> json) {
    return EOMonth(
      id: json['id'] ?? '',
      examTitle: json['examTitle'] ?? '',
      parties: (json['parties'] as List?)
              ?.map((p) => EOParty.fromJson(p))
              .toList() ??
          [],
    );
  }

  int get totalSujets =>
      parties.fold(0, (sum, p) => sum + p.sujets.length);
}
