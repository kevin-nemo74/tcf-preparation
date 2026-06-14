class EOParty {
  final String title;
  final List<String> sujets;

  const EOParty({required this.title, required this.sujets});

  factory EOParty.fromJson(Map<String, dynamic> json) {
    return EOParty(
      title: json['title'] ?? '',
      sujets: (json['sujets'] as List?)?.cast<String>() ?? [],
    );
  }
}
