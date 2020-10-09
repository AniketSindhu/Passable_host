import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passable_host/methods/getUserId.dart';
import '../globals.dart' as globals;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:random_string/random_string.dart';

class FirebaseAdd{

  addUser(String name,String email, String phoneNumber,String uid,bool isIndia){
    Firestore.instance.collection('users').document(uid)
    .setData({ 'name': name, 'email': email,'phoneNumber': phoneNumber,'uid':uid,'isIndia':isIndia},merge: true);
}
  addEvent (String eventName,String eventCode,String eventDescription,String eventAddress,int maxAttendee,File _image,DateTime dateTime,GeoFirePoint eventLocation,String hostName,String hostEmail,String hostPhone,String eventCategory, bool isOnline, bool isPaid, bool isProtected,double ticketPrice,String partner,String upi) async {
    String uid= await getCurrentUid();
    String _uploadedFileURL;
    String fileName = "Banners/$eventCode";
    globals.eventAddLoading=true;
    var _random = new Random();
    int i=_random.nextInt(3);
    StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print(taskSnapshot);
    await firebaseStorageRef.getDownloadURL().then((fileURL) async {
        _uploadedFileURL = fileURL;
      });
  List eventNameArr=[];

    for(int j=1;j<=eventName.length;j++)
     eventNameArr.add(eventName.substring(0,j).toLowerCase());

  if(partner!=null){
    Firestore.instance.collection('partners').document(partner).collection('eventsPartnered').document(eventCode)
      .setData({
        'eventCode':eventCode,
      });
  }

  Firestore.instance.collection('users').document(uid).collection('eventsHosted').document(eventCode)
    .setData({
      'eventCode':eventCode,
      'isTeam':false
    });

  if(!isOnline){
    await Firestore.instance.collection('events').document(eventCode).setData({
      'eventCode':eventCode,
      'eventName':eventName,
      'eventDescription':eventDescription,
      'eventAddress':eventAddress,
      'maxAttendee':maxAttendee,
      'eventDateTime':dateTime,
      'eventBanner':_uploadedFileURL,
      'eventNameArr':eventNameArr,
      'joined':0,
      'scanDone':0,
      'position':eventLocation.data,
      'eventLive':true,
      'isPaid':isPaid,
      'isProtected':isProtected,
      'isOnline':isOnline,
      'partner':partner,
      'hostName':hostName,
      'hostEmail':hostEmail,
      'hostPhoneNumber':hostPhone,
      'amountEarned':0.0,
      'amount_to_be_paid':0.0,
      'ticketPrice':ticketPrice,
      'eventCategory':eventCategory,
      'helper':i,
      'payment_detail':upi
    });
  }
  else{
    await Firestore.instance.collection('OnlineEvents').document(eventCode).setData({
      'eventCode':eventCode,
      'eventName':eventName,
      'eventDescription':eventDescription,
      'maxAttendee':maxAttendee,
      'eventDateTime':dateTime,
      'eventBanner':_uploadedFileURL,
      'eventNameArr':eventNameArr,
      'joined':0,
      'scanDone':0,
      'eventLive':true,
      'isPaid':isPaid,
      'isProtected':isProtected,
      'isOnline':isOnline,
      'partner':partner,
      'hostName':hostName,
      'hostEmail':hostEmail,
      'hostPhoneNumber':hostPhone,
      'amountEarned':0.0,
      'amount_to_be_paid':0.0,
      'ticketPrice':ticketPrice,
      'eventCategory':eventCategory,
      'helper':i,
      'payment_detail':upi
    });
  }
}

Future<bool> editEvent ({String eventName,String eventCode,String eventDescription,String eventAddress,int maxAttendee,DateTime dateTime,GeoFirePoint eventLocation,String hostName,String hostEmail,String hostPhone,String eventCategory, bool isOnline, bool isPaid,double ticketPrice,String upi}) async {
  bool status;
  List eventNameArr=[];
  for(int j=1;j<=eventName.length;j++)
     eventNameArr.add(eventName.substring(0,j).toLowerCase());

  if(!isOnline){
    await Firestore.instance.collection('events').document(eventCode).setData({
      'eventName':eventName,
      'eventDescription':eventDescription,
      'eventAddress':eventAddress,
      'maxAttendee':maxAttendee,
      'eventDateTime':dateTime,
      'eventNameArr':eventNameArr,
      'position':eventLocation.data,
      'hostName':hostName,
      'hostEmail':hostEmail,
      'hostPhoneNumber':hostPhone,
      'ticketPrice':ticketPrice,
      'eventCategory':eventCategory,
      'payment_detail':upi
    },merge: true).then((value) {
      status=true;
      print('ok1');
    });
  }
  else{
    await Firestore.instance.collection('OnlineEvents').document(eventCode).setData({
      'eventName':eventName,
      'eventDescription':eventDescription,
      'eventAddress':eventAddress,
      'maxAttendee':maxAttendee,
      'eventDateTime':dateTime,
      'eventNameArr':eventNameArr,
      'position':eventLocation.data,
      'hostName':hostName,
      'hostEmail':hostEmail,
      'hostPhoneNumber':hostPhone,
      'ticketPrice':ticketPrice,
      'eventCategory':eventCategory,
      'payment_detail':upi
    },merge: true).then((value) { 
      status= true;
      print('ok');
      });
  }
  return status;
}

  Future<bool> announce(String eventCode,String description,File image,bool isOnline,String eventName) async{
    String _uploadedFileURL;
    String id=randomAlphaNumeric(8);
    if(image!=null){
    StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child("$eventCode/${randomAlphaNumeric(8)}");
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print(taskSnapshot);
    await firebaseStorageRef.getDownloadURL().then((fileURL) async {
        _uploadedFileURL = fileURL;
      });
    }
    Firestore.instance.collection('Announcements').document(id).setData({
      'description':description,
      'eventName':eventName,
      'media':_uploadedFileURL,
      'token':eventCode,
      'timestamp':DateTime.now(),
      'id':id
    });
    if(isOnline){
      Firestore.instance.collection("OnlineEvents").document(eventCode).collection('Announcements').document(id).setData({
      'description':description,
      'media':_uploadedFileURL,
      'timestamp':DateTime.now(),
      'id':id
    });
    }
    else
    Firestore.instance.collection("events").document(eventCode).collection('Announcements').document(id).setData({
      'description':description,
      'media':_uploadedFileURL,
      'timestamp':DateTime.now(),
      'id':id
    });
    return true;
  }
}