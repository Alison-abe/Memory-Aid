import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memory_aid/functions.dart';
import 'package:memory_aid/searchSummary.dart';
import 'package:memory_aid/summaryclass.dart';
import 'package:memory_aid/searchclass.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<SearchClass> createAnswer(String question, String summary) async {
  print("full last"+summary);
  final response = await http.post(
    Uri.parse('https://flask-hello-world-u1yz.onrender.com/search'),
    headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'question': question,
      'summary': summary,
    }),
  );
  print(response.body);
  // if (response.statusCode == 201) {
  //   return SummaryClass.fromJson(jsonDecode(response.body));
  // } else {
  //   throw Exception('Failed to create summaryclass.');
  // }
  return SearchClass.fromJson(jsonDecode(response.body));
}

class SearchSummary extends StatefulWidget {
  const SearchSummary({super.key});

  @override
  State<SearchSummary> createState() => _SearchSummaryState();
}

TextEditingController question = TextEditingController();
String ques = '';
var AllSummaries = '';
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final CollectionReference allSummaries = firestore.collection('summaries');

class _SearchSummaryState extends State<SearchSummary> {
  Future<SearchClass>? _futureAnswer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextField(
            controller: question,
            decoration: const InputDecoration(label: Text('Search Anything')),
          ),
          const SizedBox(
            height: 30,
          ),
          // ElevatedButton(onPressed: (){
          //   setState(() {
          //     ques=question.text;
          //   });
          // }, child:const Text('show Result')),

          StreamBuilder<QuerySnapshot>(
              stream: allSummaries.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                List<DocumentSnapshot> documents1 = snapshot.data!.docs;
                print("all document =====");
                print(documents1[0]);
                return ElevatedButton(onPressed: () {
                  setState(() {
                    ques = question.text;
                  });
                  for (int i = 0; i < documents1.length - 1; i++) {
                    for (int j = 0; j < documents1.length - 1 - i; j++) {
                      if (documents1[j].get('date')
                              .compareTo(documents1[j + 1].get('date')) ==
                          1) {
                        var temp = documents1[j];
                        documents1[j] = documents1[j + 1];
                        documents1[j + 1] = temp;
                      }
                    }
                  }
                  print("summary in database == "+documents1[0].get('summary') );
                  for (int i = 0; i < documents1.length; i++) {
                    setState(() {
                      AllSummaries =
                          '$AllSummaries ${documents1[i].get('summary')}';
                    });
                  }
                 
                  // setState(() {
                  //     AllSummaries =
                  //         '$AllSummaries "';
                  //   });
                  _futureAnswer = createAnswer(ques, AllSummaries);
                },
                    
                    child: const Text('Show Result'));
              }),
              _futureAnswer == null
                  ? const Text('Summary is being fetched!!'):
                   FutureBuilder<SearchClass>(
                      future: _futureAnswer,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!.answer);
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        return const CircularProgressIndicator();
                      },
                    ),
        ],
      ),
    );
  }
}
