import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_p2/ui/home_screen.dart';
import 'package:project_p2/ui/images_page.dart';
import 'package:transparent_image/transparent_image.dart';

enum ItemMode { EDIT, VIEW }

ItemMode _itemMode = ItemMode.VIEW;

class BuildOption extends StatefulWidget {
  @override
  _BuildOptionState createState() => _BuildOptionState();
}

class _BuildOptionState extends State<BuildOption> {
  final TextEditingController _controller = TextEditingController();
  List<Item> _data = [];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: pathsList.isEmpty
            ? Firestore.instance.collection("example").snapshots()
            : pathsList.length == 1
                ? Firestore.instance
                    .collection("all")
                    .document(appMode == AppMode.TEXT ? "texts" : "images")
                    .collection("${pathsList[0]}")
                    .snapshots()
                : Firestore.instance
                    .collection("all")
                    .document(appMode == AppMode.TEXT ? "texts" : "images")
                    .collection("${pathsList[0]}")
                    .where("title", isEqualTo: "${pathsList[1]}")
                    .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (appMode == AppMode.TEXT) {
                if (pathsList.length == 2) {
                  List r = snapshot.data.documents.toList();
                  r[0].data["topics"].forEach(
                    (key, value) {
                      if (r[0].data["topics"].length != _data.length) {
                        _data.add(Item(
                            headerValue: key.toString(),
                            expandedValue: value.toString(),
                            isExpanded: false));
                      }
                    },
                  );
                }
              } else {}
              return ListView.builder(
                itemCount: pathsList.length == 1 || pathsList.length == 0
                    ? snapshot.data.documents.length
                    : 1,
                itemBuilder: (context, index) {
                  if (pathsList.length == 0) {
                    _data.clear();
                    String _doc = "";
                    for(DocumentSnapshot doc in snapshot.data.documents){
                      _doc = doc.data["text"];
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text("HOW IT WORKS\n\n"
                          "Image and text functions are separated by the bottom navigation menu.\n\n"

                          "   *Consulting\n"
                          "1- The search bar is divided into directories / folders, so to access the required items you must identify where the data they are looking for.\n"
                          "2- The structure of duNtpad is:\n"
                          "   Root: General theme.\n"
                          "   File / folder: See a specific root subject.\n"
                          "   Topics: These are the possible guidelines within the subject.\n"
                          "3-Navigation is done by the search bar, typing each structure above, if you do not know the entire path, you can query all components from Root, by touching a file / folder or the component title is copied in the area. by simply pasting into the search bar.\n\n"

                          "   *Creating\n"
                          "It is possible to create roots, files / folders and topics, just to be above the component to be created, press the lower right button and save the necessary data (for example: to create a topic you must be inside a file / folder that in turn is within a root), it is also possible to create once (for example: I am before any root, I can use the button and save the root data, file / folder, topic and the body of the topic)\n\n"

                          "   *Editing topics\n"
                          "Within a root file / file, topics are presented in bulk, when touched on one of them, two buttons are shown, one for copying the topic text and one for editing the topic text which when selected allows component editing, To finish editing just click the edit button that now has the save icon.\n"),
                    );
                  } else if (pathsList.length == 1) {
                    List<String> _title = [];
                    _data.clear();
                    for (DocumentSnapshot doc in snapshot.data.documents) {
                      print(doc.data["title"]);
                      _title.add(doc.data["title"]);
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showToast(
                                "\'${_title[index]}\' copied to a clipboard");
                            Clipboard.setData(
                                new ClipboardData(text: _title[index]));
                            //pathsList.add(_title[index]);
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Icon(
                                Icons.folder_open,
                                semanticLabel: "Icon folder",
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              _title[index],
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    if (appMode == AppMode.TEXT) {
                      return _buildPanel();
                    } else {
                      return _buildGrid(context, snapshot);
                    }
                  }
                },
              );
          }
        },
      ),
    );
  }
  Widget _buildGrid(BuildContext context, AsyncSnapshot snapshot) {
    List<String> _urls = [];
    for (DocumentSnapshot doc in snapshot.data.documents) {
      if (_urls.length != doc.data["imgUrl"].length) {
        doc.data["imgUrl"].forEach((value) {
          _urls.add(value);
        });
      }
    }
    print(_urls);
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(10.0),
      itemCount: _urls.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemBuilder: (context, index) {
        return GestureDetector(
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: _urls.elementAt(index),
            height: 50.0,
            width: 50.0,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImagePage(_urls.elementAt(index))));
          },
          onLongPress: (){

          },
        );
      },
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
          _itemMode = ItemMode.VIEW;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: ListTile(
              title: _itemMode == ItemMode.VIEW
                  ? Text(item.expandedValue)
                  : TextField(
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
              trailing: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: GestureDetector(
                      child: Icon(Icons.content_copy,
                          semanticLabel: "Icon button copy"),
                      onTap: () {
                        _showToast(
                            "Contents of \'${item.headerValue}\' copied to a clipboard");
                        Clipboard.setData(
                            ClipboardData(text: item.expandedValue));
                      },
                    ),
                  ),
                  GestureDetector(
                    child: _itemMode == ItemMode.VIEW
                        ? Icon(Icons.edit, semanticLabel: "Icon button edit")
                        : Icon(Icons.save, semanticLabel: "Icon button save"),
                    onTap: () {
                      setState(() {
                        if (_itemMode == ItemMode.VIEW)
                          _itemMode = ItemMode.EDIT;
                        else
                          _itemMode = ItemMode.VIEW;
                        _controller.text = item.expandedValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
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

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded,
  });

  set setIsExpanded(bool value) => isExpanded = value;

  bool get getIsExpanded => isExpanded;

  String expandedValue;
  String headerValue;
  bool isExpanded;
}
