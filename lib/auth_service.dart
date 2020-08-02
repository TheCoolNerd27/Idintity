import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/calendar',
    ],
);
class AuthenticationService {

//    Future loginWithEmail(
//        {String email, String password}) async {
//        // TODO: implement loginWithEmail
//        FirebaseUser user;
//
//        try {
//            user = (await auth.signInWithEmailAndPassword(
//                email: email,
//                password: password,
//            ))
//                .user;
//
//            return user != null;
//        }
//        catch (e) {
//            return e.message;
//        }
//    }

    Future<FirebaseUser> getUSer()async{
        FirebaseUser udf=await auth.currentUser();

        return udf;

    }
    Future<Map<String,String>> getAuthHeaders()
    async{
        return await googleSignIn.currentUser.authHeaders;
    }

    Future<int> signInWithGoogle() async {
        String identifier;
        String checkId;
        var resul;
        try {
            final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
            final GoogleSignInAccount googleUser = await googleSignIn.signIn();
            final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
            final AuthCredential credential = GoogleAuthProvider.getCredential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
            );
            final AuthResult authResult = await auth.signInWithCredential(
                credential);

            final FirebaseUser user =
                (await auth.signInWithCredential(credential)).user;
            assert(user.email != null);
            assert(user.displayName != null);
            assert(!user.isAnonymous);
            assert(await user.getIdToken() != null);
            try {
                if (Platform.isAndroid) {
                    var build = await deviceInfoPlugin.androidInfo;

                    identifier = build.androidId;  //UUID for Android
                } else if (Platform.isIOS) {
                    var data = await deviceInfoPlugin.iosInfo;
                    identifier = data.identifierForVendor;  //UUID for iOS
                }
            } on PlatformException {
                print('Failed to get platform version');
            }
            if(user!=null) {
                if (authResult.additionalUserInfo.isNewUser) {
                    var ref = Firestore.instance.collection('Users').document(
                        user.uid);
                    ref.setData({
                        "email": user.email,
                        "Name": user.displayName,
                        "deviceId": identifier,
                        "isCompleted":false
                    });
                   resul= 1;
                }
                else {
                    await Firestore.instance.collection('Users').document(
                        user.uid).get().then((doc) async {
                        checkId = doc['deviceId'];
                        if (checkId == identifier) {
                            print("F");
                            resul=1; //Same Device
                        }
                        else {
                            print("J2");
                            resul= 2; //Different Device

                        }
                    });
                }
            }
            else
                resul= 0;
            final FirebaseUser currentUser = await auth.currentUser();
            assert(user.uid == currentUser.uid);

        }
        catch (e) {
            print(e.message);
            resul=0;
        }
        print("Hello$resul");
        return resul;

    }
    Future signOut()
    async {



        print(googleSignIn.currentUser);
        await auth.signOut();
        googleSignIn.signOut();



    }
    FirebaseAuth getInstance()
    {
        return auth;
    }
}
