import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<String> questionsList;
  List<List<dynamic>> answersList;

  int current_q;

  Map<int, dynamic> scoreSelectedMap;

  int selected_value;

  bool isValuesFound;

  String hospital_link;
  @override
  void initState() {

    hospital_link = "";

    current_q = 0;
    questionsList = new List();
    answersList = new List();
//    questionsList = [
//      "Do you have a headache?",
//      "Did you travelled recently?",
//      "Do you have a high temperature?"
//    ];
    scoreSelectedMap = new Map();
    selected_value = 0;

    isValuesFound = false;

    getQuestionsFromFirebase().then((value) {
      getAnswersFromFirebase().then((value) {

        getHospitalLinkFromFirebase().then((value) {
          setState(() {
            isValuesFound = value;
          });
        });

      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
           decoration: BoxDecoration(
             gradient: LinearGradient(
                 begin: Alignment.topRight,
                 end: Alignment.bottomLeft,
                 colors: [Colors.orangeAccent,Colors.pinkAccent]
             )
           ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: isValuesFound? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[

                Card(
                  elevation: 4,
                  color: Colors.lightBlue,
                  margin: EdgeInsets.only(top: 60, left: 10, right: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(45), topRight: Radius.circular(45)),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    height: 140,
                    child: Text(questionsList[current_q], style: TextStyle(fontSize: 32, color: Colors.white), textAlign: TextAlign.center,),
                  ),
                ),

                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: Colors.white)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(answersList[current_q][0], style: TextStyle(color: Colors.white, fontSize: 20),),
                        ),
                        onPressed: () async {

                          await _showIntDialog();


                          print('selected number: '+selected_value.toString());
                          print('scoreSelectedMap: '+scoreSelectedMap.toString());

                        },
                      ),
                      RaisedButton(
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: Colors.white)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(answersList[current_q][1], style: TextStyle(color: Colors.white, fontSize: 20),),
                        ),
                        onPressed: (){
                          print('questionsList.length: '+questionsList.length.toString());
                          print('current_q: '+current_q.toString());

                          if(current_q<questionsList.length-1) {
                            // move to next question
                            setState(() {
                              current_q++;
                              selected_value = 0;
                            });
                          }else{
                            // calculate result
                              print('calculate final result');

                              print('total score:'+ calculateScore().toString());


                              showLinkDialog();

                              setState(() {
                                current_q=0;
                                selected_value = 0;
                              });


                          }

                          print('scoreSelectedMap: '+scoreSelectedMap.toString());

                        },
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: RaisedButton(
                    color: Colors.black45,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(color: Colors.white)
                    ),
                    child: Text('Reset', style: TextStyle(color: Colors.white),),
                    onPressed: () async {
                      setState(() {
                        current_q = 0;
                        scoreSelectedMap.clear();
                        selected_value = 0;
                      });
                    },
                  ),
                ),

              ],
            ):
            Center(child: CircularProgressIndicator(),),
          ),
        ),
      ),
    );
  }

  Future _showIntDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 10,
          step: 1,
          title: Text('Select Score'),
          initialIntegerValue: selected_value,
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() => selected_value = value);
        print('value updated');

        scoreSelectedMap.putIfAbsent(current_q, () => selected_value);

        // move to next question
        if(current_q<questionsList.length-1) {
          // move to next question
          setState(() {
            current_q++;
            selected_value = 0;
          });
        }else{
          // calculate result
          print('calculate result');

          print('total score:'+ calculateScore().toString());

          showLinkDialog();

          setState(() {
            current_q=0;
            selected_value = 0;
          });

        }

      }
    });
  }

  int calculateScore(){
    int sum = 0;
    scoreSelectedMap.forEach((k, v) {
      sum = sum + v;
    });

    return sum;
  }

  Future showLinkDialog() async{
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Your Total Score: '+calculateScore().toString(), style: TextStyle(fontSize: 16, color: calculateScore()>=20? Colors.red : Colors.green),)
              ),

              calculateScore()>=20 ?
              Column(

                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),

                    child: Text('You should visit the hospital with given link',  style: TextStyle(fontSize: 20,),),


                  ),

                  GestureDetector(
                    onTap: (){
                      _launchURL(hospital_link);
                    },
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(hospital_link??'http://abc.com', style: TextStyle(fontSize: 16, color: Colors.blueAccent),)
                    ),
                  )
                ],
              ) :
              Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Congratulations! You are doing safe. Stay in Home', style: TextStyle(fontSize: 20), )
              ),

            ],

      );

      },
    ).then((value){
      setState(() {
        current_q=0;
        scoreSelectedMap.clear();
        selected_value = 0;
      });
    });
  }



  Future<bool> getQuestionsFromFirebase()async{
    //database referene.
    final response = await FirebaseDatabase.instance
        .reference()
        .child("Questions")
        .once();

    response.value.forEach((v) => questionsList.add(v));

    return true;
  }

  Future<bool> getAnswersFromFirebase()async{
    //database referene.
    final response = await FirebaseDatabase.instance
        .reference()
        .child("Answers")
        .once();

    response.value.forEach((v) {

      answersList.add(v);

    });

    print('data: ' +response.value.toString());

    return true;
  }

  Future<bool> getHospitalLinkFromFirebase()async{
    //database referene.
    final response = await FirebaseDatabase.instance
        .reference()
        .child("Hospital").child("link")
        .once();

    setState(() {
      hospital_link = response.value;
    });

    print('data: ' +response.value.toString());

    return true;
  }


  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


}
