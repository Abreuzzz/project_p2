import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_p2/ui/texts_page.dart';

enum AddMode { ROOT, FOLDER, FILE }
enum AppMode { TEXT, PHOTO }

AddMode _addMode = AddMode.ROOT;
AppMode _appMode = AppMode.TEXT;

AppMode get appMode => _appMode;

List<String> _pathsList = [];

List<String> get pathsList => _pathsList;

set setPathsList(List _list) {
  _pathsList = _list;
}

class TextsPage extends StatefulWidget {
  @override
  _TextsPageState createState() => _TextsPageState();
}

class _TextsPageState extends State<TextsPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _rootController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();
  final TextEditingController _topicTitleController = TextEditingController();
  final TextEditingController _topicBodyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _error = "Field cannot be empty";
  final String _textButton = "Search";
  String _path = "";
  bool _textEnabled = true;
  int _selectedIndex = 0;
  String url;
  Map<String, IconData> _itemMap = {
    "Text": Icons.text_fields,
    "Photo": Icons.photo_library,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DuNtpad"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: _appMode == AppMode.TEXT
            ? Icon(Icons.add, semanticLabel: "Add")
            : Icon(Icons.camera_alt, semanticLabel: "Add"),
        onPressed: () {
          if (_appMode == AppMode.TEXT)
            _textFloating();
          else
            _imageFloating();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: TextFormField(
                        controller: _textController,
                        enabled: _textEnabled,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty || value == "") return _error;
                          return null;
                        },
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text(_textButton),
                    onPressed: () {
                      if (_textEnabled == true) {
                        setState(() {
                          if (_formKey.currentState.validate()) {
                            _buildPath(
                                pathString: _textController.text.toString());
                            _textController.clear();
                          } else
                            print("Not OK");
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                child: _pathsList.length == 0 ? null : _buildTags(),
              ),
            ),
            BuildOption(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
            if (_selectedIndex == 0) {
              _appMode = AppMode.TEXT;
            } else {
              _appMode = AppMode.PHOTO;
            }
            _addMode = AddMode.ROOT;
            _pathsList.clear();
            _textEnabled = true;
          });
        },
        items: _buildItem(),
      ),
    );
  }

  Future<String> _pickImage() async {
    File imgFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imgFile == null) return null;
    StorageUploadTask task = FirebaseStorage.instance
        .ref()
        .child("images")
        .child("IMG-${DateTime.now().toUtc().toString()}")
        .putFile(imgFile);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();

    return url;
  }

  void _imageFloating() {
    if (_pathsList.length == 0) {
      _addMode = AddMode.ROOT;
      _showDialog("Add new root for your files");
    } else if (_pathsList.length == 1) {
      _addMode = AddMode.FOLDER;
      _rootController.text = _pathsList[0];
      _showDialog("Add new folder for your files");
    } else {
      _addMode = AddMode.FILE;
      _rootController.text = _pathsList[0];
      _folderController.text = _pathsList[1];
      _showDialog("Add new topic for your file");
    }
  }

  void _textFloating() {
    if (_pathsList.length == 0) {
      _addMode = AddMode.ROOT;
      _showDialog("Add new root for your files");
    } else if (_pathsList.length == 1) {
      _addMode = AddMode.FOLDER;
      _rootController.text = _pathsList[0];
      _showDialog("Add new folder for your files");
    } else {
      _addMode = AddMode.FILE;
      _rootController.text = _pathsList[0];
      _folderController.text = _pathsList[1];
      _showDialog("Add new topic for your file");
    }
  }

  Future _showDialog(String _title) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _title,
          style: Theme.of(context).textTheme.body1,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _rootController ?? null,
              enabled: _addMode == AddMode.ROOT ? true : false,
              decoration: InputDecoration(labelText: "Root"),
            ),
            TextField(
              controller: _folderController ?? null,
              enabled: _addMode == AddMode.ROOT || _addMode == AddMode.FOLDER
                  ? true
                  : false,
              decoration: InputDecoration(labelText: "Folder"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(_appMode == AppMode.TEXT
                  ? "First topic of your file"
                  : "First image of your folder"),
            ),
            _appMode == AppMode.TEXT
                ? Column(
                    children: <Widget>[
                      TextField(
                        controller: _topicTitleController,
                        decoration: InputDecoration(labelText: "Topic title"),
                      ),
                      TextField(
                        controller: _topicBodyController,
                        decoration: InputDecoration(labelText: "Topic body"),
                      )
                    ],
                  )
                : Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        semanticLabel: "Icon camera",
                      ),
                      onPressed: () {
                        setState(() {
                          url = "";
                          _pickImage().then((value) {
                            _showToast("Uploaded image");
                            url = value;
                          });
                        });
                      },
                    ),
                  )
          ],
        ),
        contentPadding: EdgeInsets.all(25.0),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Add",
              semanticsLabel: "Add",
            ),
            onPressed: () {
              setState(() {
                if (_appMode == AppMode.TEXT) {
                  add();
                  _clearControllers();
                } else {
                  if (url == "") {
                    _showToast("Wait for image to load");
                  } else {
                    add(imgUrl: url);
                    _clearControllers();
                  }
                }
              });
            },
          )
        ],
      ),
    );
  }

  void _clearControllers() {
    if (_addMode == AddMode.ROOT)
      _textController.text = _rootController.text;
    else if (_addMode == AddMode.FOLDER)
      _textController.text = _folderController.text;
    _rootController.clear();
    _folderController.clear();
    _topicTitleController.clear();
    _topicBodyController.clear();
    Navigator.pop(context);
  }

  Future add({String imgUrl}) async {
    switch (_appMode) {
      case AppMode.TEXT:
        switch (_addMode) {
          case AddMode.ROOT:
            Firestore.instance
                .collection("all")
                .document("texts")
                .collection("${_rootController.text}")
                .document("${_folderController.text}")
                .setData({
              "title": _folderController.text,
              "topics": {
                "${_topicTitleController.text}": "${_topicBodyController.text}"
              },
            });
            break;
          case AddMode.FOLDER:
            Firestore.instance
                .collection("all")
                .document("texts")
                .collection("${_rootController.text}")
                .document("${_folderController.text}")
                .setData({
              "title": _folderController.text,
              "topics": {
                "${_topicTitleController.text}": "${_topicBodyController.text}"
              },
            });
            break;
          case AddMode.FILE:
            Firestore.instance
                .collection("all")
                .document("texts")
                .collection("${_rootController.text}")
                .document(_folderController.text)
                .updateData({
              "topics": {
                "${_topicTitleController.text}": "${_topicBodyController.text}"
              }
            });
        }
        break;
        break;
      case AppMode.PHOTO:
        switch (_addMode) {
          case AddMode.ROOT:
            Firestore.instance
                .collection("all")
                .document("images")
                .collection("${_rootController.text}")
                .document("${_folderController.text}")
                .setData({
              "title": _folderController.text,
              "imgUrl": ["$imgUrl"]
            });
            break;
          case AddMode.FOLDER:
            Firestore.instance
                .collection("all")
                .document("images")
                .collection("${_rootController.text}")
                .document("${_folderController.text}")
                .updateData({
              "title": _folderController.text,
              "imgUrl": ["$imgUrl"]
            });
            break;
          case AddMode.FILE:
            Firestore.instance
                .collection("all")
                .document("images")
                .collection("${_rootController.text}")
                .document("${_folderController.text}")
                .updateData({"title": _folderController.text, "imgUrl": ["$imgUrl"]});
            break;
        }
        break;
    }
  }

  Widget _buildTags() {
    Widget _widget;
    _widget = Container(
      height: 30.0,
      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
      padding: const EdgeInsets.only(left: 5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: <Widget>[
          Text(
            _path,
            semanticsLabel: _path,
          ),
          IconButton(
            tooltip: "Back a path",
            iconSize: 15.0,
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _pathsList.removeLast();
                _buildPath();
              });
            },
          ),
        ],
      ),
    );
    return _widget;
  }

  List<BottomNavigationBarItem> _buildItem() {
    List<BottomNavigationBarItem> _list = [];

    _itemMap.forEach((text, icon) {
      _list.add(BottomNavigationBarItem(
        icon: Icon(
          icon,
          semanticLabel: "Icon $text",
        ),
        title: Text(
          text,
          semanticsLabel: text,
          style: TextStyle(color: Colors.black54),
        ),
      ));
    });
    return _list;
  }

  void _buildPath({String pathString}) {
    String path = "";
    if (pathString != null) _pathsList.add(pathString);
    if (_pathsList.length == 2)
      _textEnabled = false;
    else
      _textEnabled = true;

    _pathsList.forEach((value) {
      print(value);
      path += "/$value";
    });
    _path = path;
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        fontSize: 12.0);
  }
}
