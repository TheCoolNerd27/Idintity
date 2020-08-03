import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hamari/scan.dart';
import 'package:hamari/auth_service.dart';
import 'package:hamari/service_locator.dart';
import 'package:hamari/LoginScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
final AuthenticationService _authenticationService =
locator<AuthenticationService>();
void main(){
  setupLocator();
  runApp(MyApp());}

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
      home: MyHomePage(title: "Dashboard",),
      initialRoute: '/Login',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.

        // When navigating to the "/second" route, build the SecondScreen widget.

        '/Home':(context)=>MyHomePage(title: "Dashboard",),
        '/Login':(context)=>Login()

      },
    );  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);



  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authenticationService.getInstance().onAuthStateChanged.listen((usr)async{
      setState((){
        user=usr;

      });

    });




    //googleSignIn.signInSilently();

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      drawer: MyDrawer(),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(

                decoration:BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,//BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.red,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ),
              ]
        ),
                child: Card(


                  child: Column(
                    children: <Widget>[
                      ListTile(

                        leading: CircleAvatar(
                          backgroundImage: user!=null?NetworkImage(user.photoUrl):NetworkImage("https://cdn.iconscout.com/icon/free/png-256/laptop-user-1-1179329.png"),

                        ),
                        title:user!=null? Text('${user.displayName}'):Text("Loading.."),
                        subtitle: user!=null?Text('${user.email}'):Text("Loading.."),
                      ),

                        FlatButton(
                            onPressed: null,
                            child: Text("View Documents")
                        ) ,

                    ],
                  ),

                ),
              ),
            ),
            SizedBox(height:20.0),
            Expanded(
              child: GridView.count(

                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: <Widget>[
                  Container(

                    decoration:BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red,
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ]
                    ),

                    child: InkResponse(

                      enableFeedback: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(child: Image.asset('assets/images/identity.png',height: 100.0,width: 100.0,)),
                          Text("Identity")
                        ],
                      ),
                      onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scan(1))),
                    ),
                  ),
                  Container(
                    decoration:BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red,
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ]
                    ),
                    child: InkResponse(
                      enableFeedback: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(child: Image.asset('assets/images/appliances.png',height: 100.0,width: 100.0)),
                          Text("Appliances")
                        ],
                      ),
                      onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scan(2))),
                    ),
                  ),
                  Container(
                    decoration:BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red,
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ]
                    ),
                    child: InkResponse(
                      enableFeedback: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(child: Image.asset('assets/images/pickup-car.png',height: 100.0,width: 100.0)),
                          Text("Vehicle")
                        ],
                      ),
                      onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scan(3))),
                    ),
                  ),
                  Container(
                    decoration:BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red,
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ]
                    ),
                    child: InkResponse(
                      enableFeedback: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(child: Image.asset('assets/images/bill.png',height: 100.0,width: 100.0)),
                          Text("Utilities")
                        ],
                      ),
                      onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scan(4))),
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
