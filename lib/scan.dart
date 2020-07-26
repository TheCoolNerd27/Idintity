import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_cropper/image_cropper.dart';
import 'package:hamari/LoginScreen.dart';
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
    var dueDate;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
              child: Center(
             child: RaisedButton(
                 onPressed: pick,
                 child: Text('Extract Text'),

                    ),
           ),

          ),
          _image!=null?Image.file(_image,height:300,width:200):Container(),
          Container(
              child: Text('Recognised Text:$dueDate'),
          ),
            Container(
                child: Center(
                    child: RaisedButton(
                        onPressed: (){
                            setState(() {
                              _image=null;
                              dueDate=null;
                            });
                        },
                        child: Text('Reset'),

                    ),
                ),

            ),
        ],
      ),
    );
  }
  void pick() async {
      //pick image   use ImageSource.camera for accessing camera.
      PickedFile Pimage = await ImagePicker().getImage(source: ImageSource.gallery);
      File image=File(Pimage.path);
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
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
          ));
      setState(() {
        _image=croppedFile;
      });
    getText();
  }
  void getText()
  async{
      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
      final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
      final VisionText visionText = await textRecognizer.processImage(visionImage);
      String pattern =
          r"_((([0-9])|([0-2][0-9])|([3][0-1]))?(((_)?\-(_)?|(_)?\/(_)?)|_)?(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?|[0-9]|[0][0-9]|[0-1][0-2])(((_)?\-(_)?|(_)?\/(_)?)|_)\d{4})_";
      RegExp regEx = RegExp(pattern,multiLine:true);
      //Returns All Matching Dates as a Map
      Iterable<String> _allStringMatches(String text, RegExp regExp) =>
          regExp.allMatches(text).map((m) => m.group(0));

      String txt=visionText.text;

      var extDates=_allStringMatches(txt.replaceAll(" ","_"),regEx).map((str)=>str.replaceAll("_",""))
          .map((str)=>convertDate(str))
          .map((str)=>DateTime.parse(str).toIso8601String()+"+05:30")
          .toList();
      extDates.sort((a,b) => b.compareTo(a));
      var dDate=extDates[0];
      setState(() {
        dueDate=dDate;
      });



  }

  String convertDate(String dates)
  {
      var res = dates.split(new RegExp(r"(-|\/)"));
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
      var temp=res[2];
      res[2]=res[0];
      res[0]=temp;

      return (res.join("-"));

  }




}
