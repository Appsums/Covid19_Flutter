import 'package:covid19/HomePage.dart';
import 'package:flutter/material.dart';

main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MyApp> {
  bool isTimeout;

  startTimer() async{
    await Future.delayed(Duration(seconds: 10),(){
      setState(() {
        isTimeout = true;
      });
    });
  }

  @override
  void initState() {
    isTimeout = false;

    startTimer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid19',
      debugShowCheckedModeBanner: false,
      home: isTimeout? HomePage() : SplashScreen(),
    );
  }
}


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Image.asset('assets/images/splash.jpeg', fit: BoxFit.fill,),
        ),
      ),
    );
  }
}
