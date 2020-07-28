import 'package:flutter/material.dart';
import 'package:hamari/service_locator.dart';
import 'package:hamari/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
final AuthenticationService _authenticationService =
locator<AuthenticationService>();
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

    bool _success;

    String _userID;
  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
              title: Text("Login"),),
          body:Container(
              padding:EdgeInsets.all(25.0) ,
              child:Center(

                  child:RaisedButton(
                      padding: EdgeInsets.all(15.0),
                      onPressed: () {

                          //googleSignIn();
                      },

                      child: Row(
                          children: <Widget>[
                              Image.asset('assets/images/google.png',
                                  height:30.0,width:30.0),
                              SizedBox( width:30.0),
                              Text('Sign in with Google',style: TextStyle(
                                  fontSize: 15.0,
                              ),),
                          ],
                      ),
                      textColor: Colors.black,
                      color: Colors.white,




                  ),
              )
          ),
      );
  }
  void googleSignIn(BuildContext context) async{
      var user;
      var res=await _authenticationService.signInWithGoogle();
      if(res==1)
          {
             user=await _authenticationService.getUSer();
             if(user!=null)
                 {
                     setState(() {
                         _success = true;
                         _userID=user.uid;

                     });


                     Fluttertoast.showToast(
                         msg: "Login Successful",
                         toastLength: Toast.LENGTH_SHORT,
                         gravity: ToastGravity.BOTTOM,
                         timeInSecForIosWeb: 2,
                         backgroundColor: Colors.greenAccent,
                         textColor: Colors.black,
                         fontSize: 16.0
                     );


                 }
             var isComp=await security();
             if(isComp==false)
                 {
                     Navigator.of(context).push(MaterialPageRoute(builder: (context) => CompleteProfile("comp",_userID)));
                 }
             else
                 {
                     Navigator.pushNamed(context, "/Scan");
                 }
          }
      else if(res==2)
          {
             //When user signs in on a different device
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => CompleteProfile("verify",_userID)));
          }
      else
          {
              setState(() {
                  _success = false;
              });
              Fluttertoast.showToast(
                  msg: "Login Failed! Try Again!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.redAccent,
                  textColor: Colors.black,
                  fontSize: 16.0
              );
          }
  }

 Future<bool> security()
  async{
      var isComp=
      await Firestore.instance.collection('Users').document(_userID)
          .get().then((doc){
              return doc["isCompleted"];

      });
      return isComp;
  }

}

class CompleteProfile extends StatefulWidget {
    String option,uid;
    CompleteProfile(this.option,this.uid);
  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
    String _ques="What is the name of your first school?", _answer;
    TextEditingController controllerNickname;
    TextEditingController controllerAboutMe;

    @override
    void initState() {
        // TODO: implement initState
        super.initState();


        controllerNickname = new TextEditingController(text: _ques);
        controllerAboutMe = new TextEditingController();
    }
    void submitData(BuildContext context)
    async{
        if(widget.option=="verify")
            {
                var ans=await Firestore.instance.collection("Users").document(widget.uid)
                    .get().then((doc){
                   return doc['answer'];
                });
                if(ans==_answer)
                    {
                        Navigator.pushNamed(context, "/Scan");
                    }
                else
                    {
                        Fluttertoast.showToast(
                            msg: "Wrong Answer,Try Again!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 2,
                            backgroundColor: Colors.redAccent,
                            textColor: Colors.black,
                            fontSize: 16.0);

                    }
            }
        else{
            var ref = Firestore.instance
                .collection("Users")
                .document(widget.uid)
                .updateData({"isCompleted":true,"answer":_answer}).then(
                    (value) async {



                    Fluttertoast.showToast(
                        msg: "Update Successful",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.greenAccent,
                        textColor: Colors.black,
                        fontSize: 16.0);
                    Navigator.pushNamed(context, '/chats');
                }).catchError((err) {
                Fluttertoast.showToast(
                    msg: err.toString(),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.black,
                    fontSize: 16.0);
                Navigator.pushNamed(context, '/Login');
            });


        }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Security Questions"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                ),
            ),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,


                    //padding:EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                    children: <Widget>[

                        TextField(
                            controller: controllerNickname,
                            decoration: InputDecoration(labelText: 'Display Name'),
                            enabled: false,
                        ),
                        TextField(
                            controller: controllerAboutMe,
                            decoration: InputDecoration(
                                labelText: 'About me',
                            ),
                            onChanged: (value) {
                                setState(() {
                                    _answer = value;
                                });
                            },
                        ),
                        SizedBox(
                            height: 15.0,
                        ),
                        RaisedButton(
                            onPressed: () {
                                controllerAboutMe.clear();
                                submitData(context);},
                            child: Text("Submit"),
                            textColor: Colors.black,
                            color: Colors.orange),
                    ],
                ),
            ),
        ),

        drawer: MyDrawer(),
    );
  }
}





class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

      return Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                  DrawerHeader(

                      decoration: BoxDecoration(
                          color: Colors.blue,
                          image:DecorationImage(
                              fit: BoxFit.fill,
                              image:  AssetImage('assets/images/drawer_header_background.png'))

                      ),
                      child: Stack(children: <Widget>[
                          Positioned(
                              bottom: 8.0,
                              left: 18.0,
                              right: 0.0,
                              child: Text("Help4Real",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500))
                              ),
                          ]),),

                  ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text('Dashboard'),
                      onTap: () {
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          Navigator.pushNamed(context,'/');
                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.input),
                      title: Text('Login'),
                      onTap: () {
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          Navigator.pushNamed(context,'/Login');
                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.scanner),
                      title: Text('Scan'),
                      onTap: () {
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          Navigator.pushNamed(context,'/Scan');

                      },
                  ),
                  ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Logout'),
                      onTap: () {
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          _authenticationService.signOut();

                      },
                  ),


              ],
          ),
      );
  }
}
