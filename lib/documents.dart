import 'package:idintity/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idintity/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';

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
            title: Row(
                children: <Widget>[
                    Image.asset("assets/images/Logo.png",height:35.0 ,width: 35.0,),
                    SizedBox(width: 10.0,),
                    Text("Idintity"),
                ],
            ),

        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Display(user, choice,param: param,),//content(context),
        ),
        drawer: MyDrawer(),
    );
  }
}


class Display extends StatefulWidget {
  String choice,param;
  FirebaseUser user;
  Display(this.user,this.choice,{Key key,this.param}): super(key: key);
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
              InkResponse(
                  onTap: (){

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Photo(doc['Url'])));

                  },
                child: Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                        image:DecorationImage(
                            image: NetworkImage(doc['Url']),
                            fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                    ),
                ),
              ),
              SizedBox(width: 20.0,),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Text("${doc['Document Name']}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,

                      ),),
                      SizedBox(height: 10.0,),
                      doc['Due Date']!=null?Text("Due Date:-${doc['Due Date']}",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold
                      ),):Container(),
                      SizedBox(height: 10.0,),
                      Text("${doc['Category']},${doc['Type']}",
                          style:TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ) ,)

                  ],
              ),
              IconButton(icon: Icon(Icons.delete,color: Colors.redAccent,), onPressed: (){
                  return showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context){
                          return AlertDialog(
                              title: Text('Delete'),
                              content: SingleChildScrollView(
                                  child: ListBody(
                                      children: <Widget>[
                                          Text('Are you sure You want to Delete'),
                                          Text('this Document forever?'),
                                      ],
                                  ),
                              ),
                              actions: <Widget>[
                                  FlatButton(
                                      child: Text('Approve'),
                                      onPressed: () async{
                                          StorageReference ref=await FirebaseStorage.instance.getReferenceFromUrl(doc['Url']);
                                          ref.delete().then((val){
                                              Firestore.instance.collection("Users")
                                                  .document(widget.user.uid)
                                                  .collection("Documents")
                                                  .document(doc.documentID).delete();
                                              Navigator.of(context).pop();
                                          });

                                      },
                                  ),
                                  FlatButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                          Navigator.of(context).pop();
                                      },
                                  ),
                              ],
                          );
                      },
                  );

              })
          ],

      ),
    );

  }
  Widget buildList()
  {
      print('param:${widget.param}');
      return Container(
        child: widget.user==null?
        Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red)))
            :StreamBuilder(
            stream:widget.choice=="All"?Firestore.instance
                .collection("Users")
                .document(widget.user.uid).collection("Documents")
                .snapshots()
                :widget.choice=="DeadLine"?Firestore.instance
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
		            .snapshots()
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

                            return Center(child: Text("No Documents!",style:
                                TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                ),));
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

class Photo extends StatelessWidget {
    String url;
    Photo(this.url);
  @override
  Widget build(BuildContext context) {
       return new Scaffold(
          body: Container(
              //color: Colors.black,
//            child: Center(
//              child: new Image.network(
//              url,
//              fit: BoxFit.cover,
//
//              alignment: Alignment.center,
//      ),
//            ),
          child: PhotoView(
              imageProvider: NetworkImage(url),
          ),
          ),
      );
  }
}







