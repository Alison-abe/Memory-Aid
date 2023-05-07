import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memory_aid/functions.dart';
import 'package:memory_aid/searchSummary.dart';
import 'package:memory_aid/summaryclass.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<SummaryClass> createSummary(String title) async {
  final response = await http.post(
    Uri.parse('https://flask-hello-world-u1yz.onrender.com/summarize'),
    headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'text': title,
    }),
  );
  print(response.body);
  // if (response.statusCode == 201) {
  //   return SummaryClass.fromJson(jsonDecode(response.body));
  // } else {
  //   throw Exception('Failed to create summaryclass.');
  // }
  return SummaryClass.fromJson(jsonDecode(response.body));
  
}

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final CollectionReference allTexts = firestore.collection('texts');
List finalText = [];
String finalSum = '';
String textforsummarization = '';

class _RecordPageState extends State<RecordPage> {
  SpeechToText speechToText = SpeechToText();
  var text = "Tap to record";
  bool isListening = false;
  Future<SummaryClass>? _futureSummary;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Memory Aid',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75.0,
        animate: isListening,
        duration: const Duration(milliseconds: 2500),
        glowColor: Colors.blue,
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTap: () async {
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechToText.listen(
                      //listenFor:const Duration(minutes: 2),
                      onResult: (result) {
                    setState(() {
                      text = result.recognizedWords;
                    });
                  });
                });
              }
            } else {
              setState(() {
                isListening = false;
                finalText.add(text);
              });
              speechToText.stop();
            }
          },
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 35,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 2 / 3,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('The recorded data during this Conversation:'),
              const SizedBox(
                height: 10,
              ),
              Text(finalSum),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      for (int i = 0; i < finalText.length; i++) {
                        finalSum = '$finalSum  ${finalText[i]}';
                      }
                    });
                    var todayDate = DateTime.now().toString();
                    await createtexts(text: finalSum, date: todayDate);
                    setState(() {
                      finalSum = '';
                      finalText.clear();
                      text = 'Tap to Record';
                    });
                  },
                  child: const Text('Upload')),
              const SizedBox(height: 30),
              StreamBuilder<QuerySnapshot>(
                  stream: allTexts.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    return ElevatedButton(
                        onPressed: () {
                          for (int i = 0; i < documents.length - 1; i++) {
                            for (int j = 0; j < documents.length - 1 - i; j++) {
                              if (documents[j].get('date').compareTo(
                                      documents[j + 1].get('date')) ==
                                  1) {
                                var temp = documents[j];
                                documents[j] = documents[j + 1];
                                documents[j + 1] = temp;
                              }
                            }
                          }
                          for (int i = 0; i < documents.length; i++) {
                            setState(() {
                              textforsummarization =
                                  '$textforsummarization ${documents[i].get('text')}';
                              _futureSummary =
                                  createSummary(textforsummarization);
                            });
                          }
                        },
                        child: const Text('Summarize'));
                  }),
              const SizedBox(
                height: 10,
              ),
              // Text(textforsummarization)
              _futureSummary == null
                  ? const Text('Summary is being fetched!!'):
                   FutureBuilder<SummaryClass>(
                      future: _futureSummary,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          createSummaryDB(summary: snapshot.data!.summary_text, date: DateTime.now().toString());
                          return Text(snapshot.data!.summary_text);
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        return const CircularProgressIndicator();
                      },
                    ),
                const SizedBox(height: 30,),
                ElevatedButton(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const SearchSummary()));
                }, 
                child: Text('Search'))
            ],
          ),
        ),
      ),
    );
  }
}
