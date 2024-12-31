import 'package:flutter/material.dart';
import 'package:quizzler/quiz_brain.dart';
import 'package:string_utilities/string_utilities.dart';

void main() => runApp(Quizzler());

QuizBrain quizBrain = QuizBrain();

class Quizzler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: QuizPage(),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  
  List<Icon> scoreKeeper = [];
  
  void checkAnswer(bool userAnswer) {
    setState(() {
      bool answer = quizBrain.getQuestionAnswer();
      bool isFinished = quizBrain.isFinished();

      if (isFinished) {
        //TODO : add dialog
        return;
      }

      if (userAnswer == answer) {
        scoreKeeper.add(Icon(Icons.check, color: Colors.green,));
      } else {
        scoreKeeper.add(Icon(Icons.close, color: Colors.red,));
      }
      quizBrain.nextQuestion();
    });
  }

  Expanded createButton({required Color btnColor, required bool btnText}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(btnColor),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            textStyle: WidgetStateProperty.all<TextStyle>(
              TextStyle(fontSize: 20.0),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero)
            )
          ),
          child: Text(
            btnText.toString().toCapitalize(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          onPressed: () {
            checkAnswer(btnText);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                quizBrain.getQuestionText(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        createButton(btnColor: Colors.green, btnText: true),
        createButton(btnColor: Colors.red, btnText: false),
        SizedBox(
          height: 45.0,
          child: Row(
            children: scoreKeeper,
          ),
        )
      ],
    );
  }
}
