class DailyText{
  String? id;
  String?  text;
  String? date;

  DailyText({
    required this.id,
    required this.text,
    required this.date
  });
  Map<String,dynamic> toJson()=>{
    'id':id,
    'text':text,
    'date': date
  };
}