import 'dart:io';

import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/gestures.dart';
import 'package:share/share.dart';
import 'package:iconscatalog/iconsRegistry.dart';
import 'package:iconscatalog/library.dart';
import 'package:path_provider/path_provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material Design Icons catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Material Design Icons catalog'),
    );
  }
}

int numIconsPerPage = 130;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<IconData> selectedIcons = [];

  int indexStart = 0;
  int indexEnd = numIconsPerPage;

  TabController _tabController;

  String tab2Text = "PICKED";

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(initialIndex: 0, vsync: this, length: 2);

    _tabController.addListener(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
            controller: _tabController,
            tabs: [Tab(text: 'LIST'), Tab(text: tab2Text)],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicatorWeight: 4.0,
            onTap: (index) {}),
      ),
      body: TabBarView(
        //physics: NeverScrollableScrollPhysics(), //EVITAR EL SWIPE
        controller: _tabController,
        dragStartBehavior: DragStartBehavior.down,
        children: [_selectIconsWidget(), _picketReorderableList()],
      ),
    );
  }

  Widget _picketReorderableList() {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView(
            header: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .03,
                color: Colors.blueGrey[50],
                child: Center(child: Text('Drag to reorder, swipe to delete'))),
            onReorder: onReorder,
            children: getListItems(),
          ),
        ),
        InkWell(
          child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * .80,
              color: Colors.orange,
              alignment: Alignment.center,
              child: Center(
                  child: Text('Share',
                      style: TextStyle(color: Colors.white, fontSize: 30.0)))),
          onTap: () async {
            if (selectedIcons.length > 0) {
              _saveFileAndShare();
            }
          },
        ),
      ],
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      IconData icon = selectedIcons[oldIndex];

      selectedIcons.removeAt(oldIndex);
      selectedIcons.insert(newIndex, icon);
    });
  }

  List<Dismissible> getListItems() => selectedIcons
      .asMap()
      .map((i, item) => MapEntry(i, buildTenableListTile(item, i)))
      .values
      .toList();

  Dismissible buildTenableListTile(IconData item, int index) {
    return Dismissible(
      onDismissed: (DismissDirection direction) {
        setState(() {
          selectedIcons.removeAt(index);
          _updatePicketCount();
        });
      },
      secondaryBackground: Container(
        child: Center(
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
        color: Colors.red,
      ),
      key: ValueKey(index),
      direction: DismissDirection.endToStart,
      background: Container(),
      child: ListTile(
        key: ValueKey(item),
        title: Icon(
          item,
          size: 40.0,
        ),
      ),
    );
  }

  Widget _selectIconsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Wrap(
          children: iconsRegistry
              .sublist(indexStart, min(indexEnd, iconsRegistry.length))
              .map(
                (icon) => Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                      color: selectedIcons.contains(icon)
                          ? Colors.orange
                          : Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      )),
                  child: Center(
                    child: IconButton(
                        //color: Colors.red,
                        icon: Icon(icon),
                        onPressed: () {
                          setState(() {
                            if (!selectedIcons.contains(icon)) {
                              selectedIcons.add(icon);
                            } else {
                              selectedIcons.remove(icon);
                            }

                            _updatePicketCount();
                          });
                        } //=> Navigator.of(context).pop(icon.codePoint),

                        ),
                  ),
                ),
              )
              .toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(
                        CommunityMaterialIcons.arrow_left,
                        size: 40.0,
                      ),
                      onPressed: () {
                        if (indexStart > 0) {
                          setState(() {
                            indexStart = indexStart - numIconsPerPage;
                            indexEnd = indexEnd - numIconsPerPage;
                          });
                        }
                      }),
                  Spacer(),
                  Text(
                    'Page ${(indexStart / numIconsPerPage + 1).toInt()}/${(iconsRegistry.length / numIconsPerPage + 1).toInt()}',
                  ),
                  Spacer(),
                  IconButton(
                      //icon: Icon(CommunityMaterialIcons.arrow_right),
                      icon: Icon(
                        CommunityMaterialIcons.arrow_right,
                        size: 40.0,
                      ),
                      onPressed: () {
                        if (indexStart < 3540) {
                          setState(() {
                            indexStart = indexStart + numIconsPerPage;
                            indexEnd = indexEnd + numIconsPerPage;
                            print(
                                'indexStart ${indexStart.toString()}. | indexEnd: ${indexEnd.toString()}');
                          });
                        }
                      }),
                ],
              ),
              RaisedButton(
                  child: Text('[ Clear ]'),
                  color: Colors.white,
                  onPressed: () {
                    if (selectedIcons.length > 0) {
                      setState(() {
                        selectedIcons.clear();
                      });
                    }
                  })
            ],
          ),
        ),
      ],
    );
  }

  _updatePicketCount() {
    tab2Text = 'PICKED (${selectedIcons.length.toString()})';
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(border: Border.all(), color: Colors.blue);
  }

  _saveFileAndShare() async {
    var textline = new StringBuffer();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/MaterialIconsList.txt');

    selectedIcons.forEach((icon) {
      textline.write(
          "IconData(${icon.codePoint.toString()},fontFamily: '${icon.fontFamily.toString()}', fontPackage: '${icon.fontPackage}' ), \n");
    });

    await file.writeAsString(textline.toString());

    List<String> path = [file.path];

    Share.shareFiles(path);
  }
}
