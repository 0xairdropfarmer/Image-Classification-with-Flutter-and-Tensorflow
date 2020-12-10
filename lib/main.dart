import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File _imageFile;
  List _classifiedResult;

  @override
  void initState() {
    super.initState();
    loadImageModel();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Classification"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 2),
                    spreadRadius: 2,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: (_imageFile != null)?
              Image.file(_imageFile) :
              Image.network('https://i.imgur.com/sUFH1Aq.png')
            ),
            RaisedButton(
              onPressed: (){
                selectImage();
              },
              child: Text('Select Image')
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                children: _classifiedResult != null
                    ? _classifiedResult.map((result) {
                        return Card(
                          elevation: 0.0,
                          color: Colors.lightBlue,
                          child: Container(
                            width: 300,
                            margin: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "${result["label"]} :  ${(result["confidence"] * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }).toList()
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future loadImageModel() async {
    Tflite.close();
    String result;
    result = await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
    );
    print(result);
  }

  Future selectImage() async {
    final picker = ImagePicker();
    var image = await picker.getImage(source: ImageSource.gallery, maxHeight: 300);
    classifyImage(image);
  }

  Future classifyImage(image) async {
    _classifiedResult = null;
    // Run tensorflowlite image classification model on the image
    print("classification start $image");
    final List result = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print("classification done");
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        _classifiedResult = result;
      } else {
        print('No image selected.');
      }
    });
  }

}
