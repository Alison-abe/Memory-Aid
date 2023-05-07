class SearchClass {
  final String answer;
  final  double score;
  const SearchClass({required this.answer,required this.score});

  factory SearchClass.fromJson(Map<String, dynamic> json) {
    return SearchClass(
      answer: json['answer'],
      score:json['score'],
    );
  }
}