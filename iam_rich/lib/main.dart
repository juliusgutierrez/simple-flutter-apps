import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text(
          'I am rich',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: const Center(
        child: Image(image: AssetImage('images/diamond.png')),
      ),
    ),
  ));
}

