import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  final String _imageData;

  ImagePage(this._imageData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("DuNtpad"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.network(_imageData),
      ),
    );
  }
}
