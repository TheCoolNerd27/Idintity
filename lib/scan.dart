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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

final AuthenticationService _authenticationService =
    locator<AuthenticationService>();


//TODO: Create an Upload function to upload doc to firebase and create calendar event if ans==true
class Scan extends StatefulWidget {
  FirebaseUser user;
  Scan(this.user);
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  File _image;
  var _imageSize;
  var dueDate, date, toDate;
  final _formkey = GlobalKey<FormState>();
  String dropdownValue,dropdownValue1;
  String docName;
  BuildContext context;
  bool ques,ans;
  TextEditingController _getDueDate;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getDueDate=new TextEditingController();
    setState(() {
      ques=true;
      ans=false;

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan"),

      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: content(context),
      ),
      drawer: MyDrawer(),
    );
  }

  Widget _popup()=>PopupMenuButton(icon:Icon(Icons.add,color: Colors.red,size: 50.0,),itemBuilder: (context) {
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.camera),
          title: Text("Camera"),
          onTap: () {
            pick(2);
          },
        ),
        value: 1,
      ),
    );
    list.add(
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.photo_library),
          title: Text("Gallery"),
          onTap: () {
            pick(1);
          },
        ),
        value: 2,
      ),
    );
    return list;
  }
  );

  Widget content(context) {
    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        Flexible(
          flex: 1,
          child: Stack(
            children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height*0.35,

                child:_image!=null?
                Image.file(_image, height: MediaQuery.of(context).size.height*0.5, width: MediaQuery.of(context).size.height*0.8)
                    :
                _popup(),
              ),

            ],
          ),

        ),
          Flexible(

            flex: 1,
            child:Form(
              key:_formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Document Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        docName = value;
                      });
                    },
                  validator: (value){
                      if(value.isEmpty)
                        {
                          return "Name cannot be empty!";
                        }
                      else{
                        return null;
                      }
                  },

                  ),
                  SizedBox(height:15.0),
              DropdownButtonFormField<String>(
                value: dropdownValue1 ,

                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.deepPurple),
                hint: Text("Category"),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Category cannot be empty!";
                  }
                  else {
                    return null;
                  }

                },
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue1 = newValue;
                  });
                },
                items: <String>['Identity', 'Appliance', 'Vehicle', 'Utilities']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
                  SizedBox(height:15.0),
                  Visibility(
                    visible: dropdownValue1==null?false:true,
                    child:
                    ((dropdownValue1=="Identity")?Identity():
                    (dropdownValue1=="Appliance")?Appliances():
                    (dropdownValue1=="Vehicle")?Vehicle()
                        :Utilities())),
                  Row(
                    children: <Widget>[
                      Visibility(
                        visible: ques,
                          child: Text("Does it have a Due date?"),
                      ),
                      IconButton(
                          icon: Icon(Icons.check,color: Colors.greenAccent,size: 25.0,),
                          onPressed: (){
                            setState(() {
                              ans=true;
                              getText();

                            });
                          }),
                      SizedBox(width: 15.0,),
                      IconButton(
                          icon: Icon(Icons.clear,color: Colors.redAccent,size: 25.0,),
                          onPressed: (){
                        setState(() {
                          ques=false;
                          ans=false;
                        });
                      })

                    ],
                  ),
                  SizedBox(height:15.0),
                  Visibility(
                    visible: ans,
                    child: TextFormField(
                      controller: _getDueDate,
                      decoration: InputDecoration(labelText: 'DueDate'),
                      enabled: false,
                    ),
                  ),

                  SizedBox(height:15.0),
                  Row(
                    children: <Widget>[
                      RaisedButton(
                          onPressed:(){
                            if (_formkey.currentState.validate())
                              {
                                //Upload To Firebase
                                //Add a condition to Upload Date only if its not null
                                  Upload();
                              }

                          },
                        child: Text("Upload"),
                          textColor: Colors.white,
                          color: Colors.redAccent
                      ),
                      SizedBox(width: 10.0,),
                      RaisedButton(
                          onPressed:(){
                           setState(() {
                             date=null;
                             dueDate=null;
                             toDate=null;
                             date=null;
                             _image=null;
                             ques=true;
                             ans=false;
                             dropdownValue=null;
                             dropdownValue1=null;

                             _getDueDate.clear();
                           });
                          },
                          child: Text("Scan Again"),
                          textColor: Colors.white,
                          color: Colors.redAccent
                      ),

                    ],
                  )
                ],
              ),
            ) ,

          ),


        ],
      ),
    );
  }
  Widget Identity()
  {
    return DropdownButtonFormField<String>(
      value: dropdownValue ,

      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      hint: Text("Type of Document"),
      validator: (value) {
        if (value.isEmpty) {
          return "Type cannot be empty!";
        }
        else {
          return null;
        }

      },
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Passport', 'Aadhar', 'Voter', 'Pan','Certificates','Courses','Others']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

  }
  Widget Appliances()
  {

    return DropdownButtonFormField<String>(
      value: dropdownValue ,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      hint: Text("Type of Document"),
      validator: (value) {
        if (value.isEmpty) {
          return "Type cannot be empty!";
        }
        else {
          return null;
        }

      },

      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Washing Machine', 'Microwave', 'Fridge', 'AC','Dishwasher','T.V']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );


  }
  Widget Vehicle()
  {

    return DropdownButtonFormField<String>(
      value: dropdownValue ,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      hint: Text("Type of Document"),
      validator: (value) {
        if (value.isEmpty) {
          return "Type cannot be empty!";
        }
        else {
          return null;
        }

      },
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Car', 'MotorCycle', 'Others']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );


  }
  Widget Utilities()
  {

    return DropdownButtonFormField<String>(
      value: dropdownValue ,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      hint: Text("Type of Document"),
      validator: (value) {
        if (value.isEmpty) {
          return "Type cannot be empty!";
        }
        else {
          return null;
        }

      },
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Electricity', 'Phone', 'Others']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );


  }


  void pick(int choice) async {
    PickedFile Pimage;
    //pick image   use ImageSource.camera for accessing camera.
    if(choice==1) {
      Pimage =
      await ImagePicker().getImage(source: ImageSource.gallery);
    }
    else if(choice==2)
      {
        Pimage =
        await ImagePicker().getImage(source: ImageSource.camera);
      }
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

  }

  Iterable<String> _allStringMatches(String text, RegExp regExp) =>
      regExp.allMatches(text).map((m) => m.group(0));
  void getText() async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
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
    _getDueDate.text=date;
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
    var authHeaders;
    try {
        authHeaders = await _authenticationService.getAuthHeaders();
    }
    catch(e)
      {
          Navigator.pushNamed(context, "/Login");
      }

        final httpClient = GoogleHttpClient(authHeaders);
        calendarApi = CalendarApi(httpClient);
        result = calendarApi.events.insert(Event.fromJson(event), "primary",
            sendUpdates: "all"); //sendUpdates:'true');
        print(result);


  }

  void Upload()
  async {
    var now = new DateTime.now().millisecondsSinceEpoch
        .toString();
    StorageReference reference = FirebaseStorage().ref().child(
        'Documents/${widget.user.uid}/$now/$docName');
    StorageUploadTask uploadTask = reference.putFile(_image);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    if (ans == true) {
      var rdate = DateTime
          .parse(dueDate)
          .millisecondsSinceEpoch
          .toString();
      var ref = Firestore.instance.collection('Users').document(widget.user.uid)
          .collection("Documents")
          .add({
        'Document Name': docName,
        'Category': dropdownValue1,
        'Type': dropdownValue,
        'Due Date': date,
        'Date Timestamp': rdate,
        'Url': downloadUrl,
      });
      addEvent();
    }
    else{
      var ref = Firestore.instance.collection('Users').document(widget.user.uid)
          .collection("Documents")
          .add({
        'Document Name': docName,
        'Category': dropdownValue1,
        'Type': dropdownValue,
        'Url': downloadUrl,
      });

    }

    setState(() {
      date=null;
      dueDate=null;
      toDate=null;
      date=null;
      _image=null;
      ques=true;
      ans=false;
      dropdownValue=null;
      dropdownValue1=null;



      _getDueDate.clear();
    });

    _formkey.currentState.reset();

  }

}
