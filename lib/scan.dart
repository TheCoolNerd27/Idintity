import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:path/path.dart' as path;
import 'package:image_cropper/image_cropper.dart';
import 'package:hamari/LoginScreen.dart';
import 'package:hamari/httpClient.dart';
import 'package:hamari/auth_service.dart';
import 'package:hamari/service_locator.dart';

final AuthenticationService _authenticationService =
    locator<AuthenticationService>();

class ScanPage extends StatelessWidget {
  String title = 'Scan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scan(),
      ),
      drawer: MyDrawer(),
    );
  }
}

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  File _image;
  var _imageSize;
  var dueDate, date, toDate;

  String docName;
  BuildContext context;
  @override
  Widget build(context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Center(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Document Name',
              ),
              onChanged: (value) {
                setState(() {
                  docName = value;
                });
              },
            ),
          ),
          Container(
            child: Center(
              child: RaisedButton(
                onPressed: pick,
                child: Text('Extract Text'),
              ),
            ),
          ),
          _image != null
              ? Image.file(_image, height: 300, width: 200)
              : Container(),
          Container(
            child: Text('Recognised Text:$date'),
          ),
          Container(
            child: Center(
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    _image = null;
                    dueDate = null;
                    date = null;
                  });
                },
                child: Text('Reset'),
              ),
            ),
          ),
          Container(
            child: Center(
              child: RaisedButton(
                onPressed: addEvent,
                child: Text('Add Event to Calendar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pick() async {
    //pick image   use ImageSource.camera for accessing camera.
    PickedFile Pimage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    File image = File(Pimage.path);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.red,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      _image = croppedFile;
    });
    getText(croppedFile);
  }

  Iterable<String> _allStringMatches(String text, RegExp regExp) =>
      regExp.allMatches(text).map((m) => m.group(0));
  void getText(File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    String pattern =
        r"_?((([0-9])|([0-2][0-9])|([3][0-1]))?(((_)?\-(_)?|(_)?\/(_)?)|_)?(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?|[0-9]|[0][0-9]|[0-1][0-2])(((_)?\-(_)?|(_)?\/(_)?)|_)\d{4})_?";
    RegExp regEx = RegExp(pattern, multiLine: true);
    //Returns All Matching Dates as a Map

    String txt = visionText.text;
    print(txt.replaceAll(" ", "_"));
    var extDates = _allStringMatches(txt.replaceAll(" ", "_"), regEx)
        .map((str) => str.replaceAll("_", ""))
        .map((str) => convertDate(str))
        .map((str) => DateTime.parse(str).toIso8601String())
        .toList();
    extDates.sort((a, b) => b.compareTo(a));
    var dd;
    print(extDates);
    dd = DateTime.parse(extDates[0]).toString().substring(0, 10);
    var toDat =
        DateTime.parse(extDates[0]).add(Duration(days: 1)).toIso8601String();
    var res = dd.split("-");
    var temp = res[0];
    res[0] = res[2];
    res[2] = temp;
    dd = res.join("-");
    var dDate = extDates[0];
    setState(() {
      dueDate = dDate;
      toDate = toDat;
      //dueDate=txt;
      date = dd;
    });
    //addEvent();
  }

  String convertDate(String dates) {
    var res = dates.split(new RegExp(r"(-|\/)"));
    if (res.length == 2) res.insert(0, "01");
    switch (res[(res.length - 2)]) {
      case "Jan":
      case "January":
        res[(res.length - 2)] = "01";
        break;
      case "Feb":
      case "Febuary":
        res[(res.length - 2)] = "02";
        break;
      case "Mar":
      case "March":
        res[(res.length - 2)] = "03";
        break;
      case "Apr":
      case "April":
        res[(res.length - 2)] = "04";
        break;
      case "May":
        res[(res.length - 2)] = "05";
        break;
      case "Jun":
      case "June":
        res[(res.length - 2)] = "06";
        break;
      case "Jul":
      case "July":
        res[(res.length - 2)] = "07";
        break;
      case "Aug":
      case "August":
        res[(res.length - 2)] = "08";
        break;
      case "Sep":
      case "September":
        res[(res.length - 2)] = "09";
        break;
      case "Oct":
      case "October":
        res[(res.length - 2)] = "10";
        break;
      case "Nov":
      case "November":
        res[(res.length - 2)] = "11";
        break;
      case "Dec":
      case "December":
        res[(res.length - 2)] = "12";
        break;
    }
    var temp = res[2];
    res[2] = res[0];
    res[0] = temp;

    return (res.join("-"));
  }

  void addEvent() async {
    var event = {
      'summary': 'Due Date',
      'description': 'Your Document $docName is Due Today!',
      'start': {
        'dateTime': dueDate,
        'timeZone': 'Asia/Calcutta',
      },
      'defaultReminders': [
        {'method': 'email', 'minutes': 24 * 60},
        {'method': 'popup', 'minutes': 30}
      ],
      'end': {
        'dateTime': toDate,
        'timeZone': 'Asia/Calcutta',
      },

    };

    var calendarApi, result;
    if (_authenticationService.getUSer() == null)
      Navigator.pushNamed(context, "/Login");
    else {
      var authHeaders = await _authenticationService.getAuthHeaders();
      final httpClient = GoogleHttpClient(authHeaders);
      calendarApi = CalendarApi(httpClient);
      result = calendarApi.events.insert( Event.fromJson(event),"primary",sendUpdates:"all");//sendUpdates:'true');
      print(result);
    }
  }
}
