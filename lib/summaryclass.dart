class SummaryClass {
  final String summary_text;
  const SummaryClass({required this.summary_text});

  factory SummaryClass.fromJson(Map<String, dynamic> json) {
    return SummaryClass(
      summary_text: json['summary_text']
    );
  }
}