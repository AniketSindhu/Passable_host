import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'config/config.dart';

class PassesAlotted extends StatefulWidget {
  final bool isOnline;
  final String eventCode;
  final double price;
  PassesAlotted(this.eventCode,this.isOnline,this.price);
  @override
  _PassesAlottedState createState() => _PassesAlottedState();
}

class _PassesAlottedState extends State<PassesAlotted> {
  var firestore=Firestore.instance;
  Future<List<DocumentSnapshot>> users;
  Future getData()async{
    if(!widget.isOnline){
      final QuerySnapshot joinedGuests=await firestore.collection('events').document(widget.eventCode).collection('guests').getDocuments();
      return joinedGuests.documents;
    }
    else{
      final QuerySnapshot joinedGuests=await firestore.collection('OnlineEvents').document(widget.eventCode).collection('guests').getDocuments();
      return joinedGuests.documents;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Joined guests')),
      body: FutureBuilder(
        future: getData(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting)
            {
              return Center(child: SpinKitChasingDots(color: AppColors.secondary,size: 20,),);
            }
          else if(snapshot.hasData)
           { if(snapshot.data.length==0)
            {
              return Center(child: Text('No one joined yet :('),);
            }
            else
            return ListView.builder(
              itemCount:snapshot.data.length,
              itemBuilder:(context,index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.pink[50],
                    child: ListTile(
                     title:Text("${snapshot.data[index].data['name']} (${snapshot.data[index].data['passCode']})",),
                     subtitle: Text("${snapshot.data[index].data['phone']==null?snapshot.data[index].data['email']:snapshot.data[index].data['phone']}"),
                     trailing: Text("${widget.price.toInt()}*${snapshot.data[index].data['ticketCount']}= ₹ ${snapshot.data[index].data['ticketCount']*widget.price}"),
                    ),
                  ),
                );
              }
            );
           }
           else
           return Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[
               Lottie.asset('assets/NoOne.json',),
               SizedBox(height:20),
               Text('No One joined yet!',style: GoogleFonts.novaRound(textStyle:TextStyle(color: AppColors.secondary,fontSize:22,fontWeight:FontWeight.bold)),),
               SizedBox(height:20),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text('Tip: Use the Share button on the event detail page so that more people can get passes',style: GoogleFonts.novaRound(textStyle:TextStyle(color: Colors.redAccent,fontSize:17,fontWeight:FontWeight.bold,fontStyle: FontStyle.italic)),textAlign:TextAlign.center,),
               ),
            ],
          );
        }
      ),
    );
  }
}

class ScannedList extends StatefulWidget {
  final String eventCode;
  final bool isOnline;
  ScannedList(this.eventCode,this.isOnline);
  @override
  _ScannedListState createState() => _ScannedListState();
}

class _ScannedListState extends State<ScannedList> {
  var firestore=Firestore.instance;
  Future<List<DocumentSnapshot>> users;
  Future getData()async{
    if(!widget.isOnline){
      final QuerySnapshot result= await firestore.collection('events').document(widget.eventCode).collection('guests').where('Scanned',isEqualTo:true).getDocuments();
      return result.documents;
    }
    else{
      final QuerySnapshot result= await firestore.collection('events').document(widget.eventCode).collection('guests').where('Scanned',isEqualTo:true).getDocuments();
      return result.documents;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Joined guests')),
      body: FutureBuilder(
        future: getData(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting)
            {
              return Center(child: SpinKitChasingDots(color: AppColors.secondary,size: 20,),);
            }
          else if(snapshot.hasData)
           { if(snapshot.data.length==0)
            {
              return Center(child: Text('No one joined yet :('),);
            }
            else
            return ListView.builder(
              itemCount:snapshot.data.length,
              itemBuilder:(context,index){
                return ListTile(
                 title:Text("${snapshot.data[index].data['name']}",),
                 subtitle: Text("${snapshot.data[index].data['phone']==null?snapshot.data[index].data['email']:snapshot.data[index].data['phone']}"),
                );
              }
            );
           }
           else
           return Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[
               Lottie.asset('assets/NoOne.json',),
               SizedBox(height:20),
               Text('No Passes scanned yet',style: GoogleFonts.novaRound(textStyle:TextStyle(color: AppColors.secondary,fontSize:22,fontWeight:FontWeight.bold)),)
            ],
          );
        }
      ),
    );
  }
}