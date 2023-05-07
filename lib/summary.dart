
class SummaryDb{
  String? id;
  String? summary;
  String? date;
  SummaryDb({
    required this.id,
    required this.summary,
    required this.date
  });
  Map<String,dynamic> toJson()=>{
    'id':id,
    'summary':summary,
    'date': date
  };
}