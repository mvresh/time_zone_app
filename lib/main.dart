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

class _TimeZoneAppState extends State<TimeZoneApp> {
//  Future<List<int>> loadDefaultData() async {
//    var byteData = await rootBundle.load('packages/timezone/data/2019b.tzf');
//    return byteData.buffer.asUint8List();
//  }

  LocationDatabase database = standalone.timeZoneDatabase;
  List<String> locationsList = [];

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
      bool isNumber = val.currentTimeZone.toString().split(' ')[0].substring(1).startsWith('+');
      bool isFraction = val.currentTimeZone.toString().split(' ')[0].substring(1).length > 3;

      if(isNumber){
        if(isFraction){
          locationsList.add('$key GMT  ${text.substring(0,3) + ':' + text.substring(3,text.length)}');
        }
        else {
          locationsList.add(
              '$key GMT   ${val.currentTimeZone.toString().split(' ')[0]
                  .substring(1)}');
        }
      }
      else{
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
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Select Time Zone',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: database.locations == null
              ? CircularProgressIndicator()
              : Column(
                  children: <Widget>[
                    DropdownButton<String>(
                      hint: Text('Select '),
                      value: selection,
                      items: locationsList.map((dynamic location) {
                        return DropdownMenuItem<String>(
                          child: Text(location),
                          value:location,

                        );
                      }).toList(),
                      onChanged: (newValue) {
                        selection = newValue;
                         setState(() {
                         });
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
