import 'package:destini_challenge_starting/story_brain.dart';
import 'package:flutter/material.dart';

void main() => runApp(Destini());

class Destini extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: StoryPage(),
    );
  }
}

StoryBrain storyBrain = StoryBrain();

class StoryPage extends StatefulWidget {
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {

  TextButton createButton({required int choiceNumber, required Color color, required String btnText}) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(color),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          textStyle: WidgetStateProperty.all<TextStyle>(
            TextStyle(fontSize: 20.0),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero))),
      onPressed: () {
        setState(() {
          storyBrain.nextStory(choiceNumber);
        });
      },
      child: Text(
        btnText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
    );
  }

  BoxDecoration _createBackground() {
    return BoxDecoration(
      image: DecorationImage(
          image: AssetImage('images/background.png'),
          fit: BoxFit.cover
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _createBackground(),
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 15.0),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 12,
                child: Center(
                  child: Text(
                    storyBrain.getStory().storyTitle,
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: createButton(choiceNumber: 1, color: Colors.red, btnText: storyBrain.getStory().choice1),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                flex: 2,
                child: Visibility(
                    child: createButton(choiceNumber: 2, color: Colors.blue, btnText: storyBrain.getStory().choice2),
                    visible: storyBrain.isVisible(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
