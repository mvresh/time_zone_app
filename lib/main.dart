import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/standalone.dart' as standalone;

void main() async {
  var byteData =
      await rootBundle.load('packages/timezone/data/${tzDataDefaultFilename}');
  initializeDatabase(byteData.buffer.asUint8List());
  runApp(MaterialApp(
    home: TimeZoneApp(),
    theme: ThemeData.dark(),
  ));
}

class TimeZoneApp extends StatefulWidget {
  @override
  _TimeZoneAppState createState() => _TimeZoneAppState();
}

List<String> locationsList = [];

class _TimeZoneAppState extends State<TimeZoneApp> {
//  Future<List<int>> loadDefaultData() async {
//    var byteData = await rootBundle.load('packages/timezone/data/2019b.tzf');
//    return byteData.buffer.asUint8List();
//  }

  LocationDatabase database = standalone.timeZoneDatabase;

  Future<void> setup() async {
    await standalone.initializeTimeZone();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setup();
    database.locations.forEach((key, val) {
      String text = val.currentTimeZone.toString().split(' ')[0].substring(1);
      bool isNumber = val.currentTimeZone
          .toString()
          .split(' ')[0]
          .substring(1)
          .startsWith('+');
      bool isFraction =
          val.currentTimeZone.toString().split(' ')[0]
              .substring(1)
              .length > 3;

      if (isNumber) {
        if (isFraction) {
          locationsList.add(
              '$key GMT  ${text.substring(0, 3) + ':' +
                  text.substring(3, text.length)}');
        } else {
          locationsList.add(
              '$key GMT   ${val.currentTimeZone.toString().split(' ')[0]
                  .substring(1)}');
        }
      } else {
        locationsList.add(
            '$key   ${val.currentTimeZone.toString().split(' ')[0].substring(1)}');
      }
    });

//    loadDefaultData().then((rawData) {
//      initializeDatabase(rawData);
////      print(database.locations.length);
//      database.locations.forEach((key, val){
//        print('$key - $val');
//      });
//    });
  }

  dynamic selection;
  String selectedTimeZone = 'Select Time Zone';
  Widget appBarTitle = Text(
    'Select Time Zone',
    style: TextStyle(fontWeight: FontWeight.bold),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: Container(
          child: GestureDetector(
              onTap: () async {
                final result =
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) {
                    return TimeZoneList();
                  },
                ));
                setState(() {
                  selectedTimeZone = result;
                  print(selectedTimeZone);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Region',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold))),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(selectedTimeZone,
                            style:
                            TextStyle(fontSize: 20, color: Colors.grey))),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class TimeZoneList extends StatefulWidget {
  @override
  _TimeZoneListState createState() => _TimeZoneListState();
}

List duplicateLocationsList = [];
List filteredList = [];
String searchText;

class _TimeZoneListState extends State<TimeZoneList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    duplicateLocationsList.addAll(locationsList);
    filteredList.addAll(duplicateLocationsList);

    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          filteredList.addAll(duplicateLocationsList);
        });
      }
      else {
        setState(() {
          searchText = searchController.text;
          filteredList = [];
          duplicateLocationsList.forEach((location) {
            if (location.toString().toLowerCase().contains(
                searchText.toLowerCase())) {
              filteredList.add(location);
            }
            setState(() {

            });
          });
        });
      }
    });
  }

  Widget appBarTextSearch;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTextSearch == null ? null : appBarTextSearch,
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              appBarTextSearch = TextField(
                controller: searchController,
              );
            });
          },
        ),
      ),
      body: ListView.builder(
          itemCount: filteredList.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop(filteredList[index]);
              },
              child: Card(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                        filteredList[index],
                        style: TextStyle(fontSize: 22),
                      )),
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
    print('disposed');
  }
}
