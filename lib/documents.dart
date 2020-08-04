import 'package:hamari/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamari/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

//TODO:Add Photo Viewer
//TODO:Error when Calling Search
class DisplayPage extends StatelessWidget {
    FirebaseUser user;
    String choice,param;
    DisplayPage(this.user,this.choice,{this.param});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Documents"),

        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Display(user, choice),//content(context),
        ),
        drawer: MyDrawer(),
    );
  }
}


class Display extends StatefulWidget {
  String choice,param;
  FirebaseUser user;
  Display(this.user,this.choice,{this.param});
  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: buildList(),
    );
  }

  Widget buildItem(BuildContext context,DocumentSnapshot doc)
  {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
          children: <Widget>[
              Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                      image:DecorationImage(
                          image: NetworkImage(doc['Url']),
                          fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                  ),
              ),
              SizedBox(width: 20.0,),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Text("${doc['Document Name']}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,

                      ),),
                      SizedBox(height: 10.0,),
                      Text("Due Date:-${doc['Due Date']}",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold
                      ),),
                      SizedBox(height: 10.0,),
                      Text("${doc['Category']},${doc['Type']}",
                          style:TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ) ,)

                  ],
              )
          ],

      ),
    );

  }
  Widget buildList()
  {
      return Container(
        child: widget.user==null?
        Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red)))
            :StreamBuilder(
            stream:widget.choice=="All"?Firestore.instance
            .collection("Users")
            .document(widget.user.uid)
            .collection("Documents")
            .orderBy('Date Timestamp',descending: false)
            .snapshots()
            :widget.choice=="Search"?
                Firestore.instance.collection("Users")
                .document(widget.user.uid)
                .collection("Documents")
                .where("Document Name",isEqualTo: widget.param)
                :Firestore.instance.collection("Users")
            .document(widget.user.uid)
            .collection("Documents")
            .where("Category",isEqualTo: widget.choice)
            .snapshots(),
            builder: (context,snapshot){
                if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.red)));
                }
                else{
                    if(snapshot.data.documents.length==0)
                        {
                            return Text("No Documents!");
                        }
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context,index)=>
                        buildItem(context,snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                    );


                }


            },

        )
      );


  }
}




