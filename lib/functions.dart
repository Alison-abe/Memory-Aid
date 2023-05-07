import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memory_aid/summary.dart';
import 'text.dart';
Future createtexts({required String text,required String date}) async{
      final docText=FirebaseFirestore.instance.collection('texts').doc();
      final textSample = DailyText(id: docText.id, text: text, date: date);
      final result=textSample.toJson();
      await docText.set(result);
  }

Future createSummaryDB({required String summary,required String date}) async{
  final docSummary=FirebaseFirestore.instance.collection('summaries').doc();
      final summarySample = SummaryDb(id: docSummary.id, summary: summary, date: date);
      final result=summarySample.toJson();
      await docSummary.set(result);
}