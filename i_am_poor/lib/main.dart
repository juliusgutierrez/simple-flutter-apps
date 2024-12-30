import 'package:flutter/material.dart';

void main() {

  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text(
          'I am poor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: const Center(
        child: Image(image: AssetImage('images/iam_poor.png')),
      ),
    ),
  ));
}
