import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hamari/scan.dart';
import 'package:hamari/auth_service.dart';
import 'package:hamari/service_locator.dart';
import 'package:hamari/LoginScreen.dart';
import 'package:hamari/documents.dart';
import 'package:google_sign_in/google_sign_in.dart';

final AuthenticationService _authenticationService =
    locator<AuthenticationService>();
void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//    Widget _defaultHome=Login();
//    if(_authenticationService.getUSer()!=null)
//      _defaultHome=ScanPage();
    return MaterialApp(
      title: 'Hamari',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(
        title: "Dashboard",
      ),
      initialRoute: '/Login',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.

        // When navigating to the "/second" route, build the SecondScreen widget.

        '/Home': (context) => MyHomePage(
              title: "Dashboard",
            ),
        '/Login': (context) => Login()
      },
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
  FirebaseUser user;
  String params;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authenticationService.getInstance().onAuthStateChanged.listen((usr) async {
      setState(() {
        user = usr;
      });
    });

    //googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: ListView(

        children: <Widget>[
          Container(

            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                )),
            child: Column(
              mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: user != null
                            ? NetworkImage(user.photoUrl)
                            : NetworkImage(
                            "https://cdn.iconscout.com/icon/free/png-256/laptop-user-1-1179329.png"),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      user != null? Text(
                        "Hi, ${user.displayName}",
                        style: TextStyle(color: Colors.white),
                      ):Text("Loading..."),
                    ],
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  TextField(
                    decoration: InputDecoration(
                        hintText: "Search",
                        fillColor: Colors.white,
                        filled: true,

                        suffixIcon: Icon(Icons.filter_list),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.transparent)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                    ),
                    onChanged:(value){
                      setState(() {
                        params=value;
                      });

                    },
                    onSubmitted: (value){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DisplayPage(user,"Search",param: params,)));

                    },
                  ),
                ]),
          ),

          SizedBox(height: 20.0),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Category",style:
              TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0),),
          ),
          SizedBox(height: 10.0,),
          Container(
            height: 250.0,
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(10),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: <Widget>[
                InkResponse(
                  enableFeedback: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(

                          child: Icon(Icons.scanner,size: 30.0,),
                      radius: 30.0,),
                      Text("Scan")
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Scan(user))),
                ),
                InkResponse(
                  enableFeedback: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                          child: Icon(Icons.view_list,size: 30.0,),
                          radius: 30.0,),
                      Text("Documents")
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DisplayPage(user, "All"))),
                ),
                InkResponse(
                  enableFeedback: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                          child: Image(
                            image:AssetImage("assets/images/identity.png"),
                            height: 30,width: 30.0,),
                          radius: 30.0,),
                      Text("Identity")
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DisplayPage(user, "Identity"))),
                ),
                InkResponse(
                  enableFeedback: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                          child: Image(
                            image:AssetImage("assets/images/appliances.png"),
                            height: 30,width: 30.0,),
                            radius: 30.0,),
                      Text("Appliances")
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DisplayPage(user, "Appliance"))),
                ),
                InkResponse(
                  enableFeedback: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                          child: Image(
                            image: AssetImage('assets/images/pickup-car.png'),
                                height: 30.0, width: 30.0),
                          radius: 30.0,),
                      Text("Vehicle")
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DisplayPage(user, "Vehicle"))),
                ),
                InkResponse(
                  enableFeedback: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                          child: Image(
                            image: AssetImage('assets/images/bill.png'),
                                height: 30.0, width: 30.0),
                          radius: 30.0,),
                      Text("Utilities")
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DisplayPage(user, "Utilities"))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Upcoming Deadlines",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0
            ),),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Display(user,"All"),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
