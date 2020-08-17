import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passable_host/config/config.dart';
import 'package:flutter_svg/svg.dart';
import 'package:passable_host/methods/getUserId.dart';

class TeamPage extends StatefulWidget {
  final String eventCode;
  final bool isTeam;
  TeamPage(this.eventCode,this.isTeam);
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  TextEditingController controller= TextEditingController();
  Future<List<DocumentSnapshot>> getTeamList() async{
    final x= await Firestore.instance.collection('events').document(widget.eventCode).collection('team').getDocuments();
    return x.documents;
  }
  removeMember(String removeUid) async{
    await Firestore.instance.collection('users').document(removeUid).collection('eventsHosted').document(widget.eventCode).delete();
    await Firestore.instance.collection('events').document(widget.eventCode).collection('team').document(removeUid).delete();
    Fluttertoast.showToast(msg: 'Removed from the team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.green);
    setState(() {});
  }
  addMember(String user) async{
    String uid= await getCurrentUid();
    final i = await Firestore.instance.collection('users').document(uid).get();
    final x= await Firestore.instance.collection('users').where('email',isEqualTo:user.toLowerCase()).getDocuments();
    final y= await Firestore.instance.collection('users').where('phoneNumber',isEqualTo:user.toLowerCase()).getDocuments();
    if(i.data['email']==user||i.data['phoneNumber']==user)
      {
        Fluttertoast.showToast(msg: 'You cannot add yourself to the team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.red,gravity: ToastGravity.TOP);
      }
    else if(x.documents.isEmpty&&y.documents.isEmpty){
      Fluttertoast.showToast(msg: 'No user found, try using different email or phone number',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.red,gravity: ToastGravity.TOP);
    }
    else{
      if(x.documents.isNotEmpty&&y.documents.isEmpty){
        final m=await Firestore.instance.collection('events').document(widget.eventCode).collection('team').document(x.documents[0].data['uid']).get();
        if(m.exists){
          Fluttertoast.showToast(msg: '${x.documents[0].data['name']} is already in your team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.red,gravity: ToastGravity.TOP);
        }
        else{
        await Firestore.instance.collection('users').document(x.documents[0].data['uid']).collection('eventsHosted').document(widget.eventCode).setData({
          'eventCode':widget.eventCode,
          'isTeam':true
        });
        await Firestore.instance.collection('events').document(widget.eventCode).collection('team').document(x.documents[0].data['uid']).setData({
          'email':x.documents[0].data['email'],
          'name':x.documents[0].data['name'],
          'phoneNumber':x.documents[0].data['phoneNumber'],
          'uid':x.documents[0].data['uid']
        });
          Fluttertoast.showToast(msg: '${x.documents[0].data['name']} is added in your team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.green,gravity: ToastGravity.TOP);
          setState(() {});
        }
      }
      else if(y.documents.isNotEmpty&&x.documents.isEmpty){
        final a=await Firestore.instance.collection('events').document(widget.eventCode).collection('team').document(y.documents[0].data['uid']).get();
        if(a.exists){
          Fluttertoast.showToast(msg: '${y.documents[0].data['name']} is already in your team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.red,gravity: ToastGravity.TOP);
        }
        else{
        await Firestore.instance.collection('users').document(y.documents[0].data['uid']).collection('eventsHosted').document(widget.eventCode).setData({
          'eventCode':widget.eventCode,
          'isTeam':true
        });
        await Firestore.instance.collection('events').document(widget.eventCode).collection('team').document(y.documents[0].data['uid']).setData({
          'email':y.documents[0].data['email'],
          'name':y.documents[0].data['name'],
          'phoneNumber':y.documents[0].data['phoneNumber'],
          'uid':y.documents[0].data['uid']
        });
          Fluttertoast.showToast(msg: '${y.documents[0].data['name']} is added in your team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.green,gravity: ToastGravity.TOP);
          setState(() {});
        }
      }
      else{
        final b=await Firestore.instance.collection('events').document(widget.eventCode).collection('team').document(x.documents[0].data['uid']).get();
        if(b.exists){
          Fluttertoast.showToast(msg: '${x.documents[0].data['name']} is already in your team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.red,gravity: ToastGravity.TOP);
        }
        else{
        await Firestore.instance.collection('users').document(x.documents[0].data['uid']).collection('eventsHosted').document(widget.eventCode).setData({
          'eventCode':widget.eventCode,
          'isTeam':true
        });
        await Firestore.instance.collection('events').document(widget.eventCode).collection('team').document(x.documents[0].data['uid']).setData({
          'email':x.documents[0].data['email'],
          'name':x.documents[0].data['name'],
          'phoneNumber':x.documents[0].data['phoneNumber'],
          'uid':x.documents[0].data['uid']
        });
          Fluttertoast.showToast(msg: '${x.documents[0].data['name']} is added in your team',textColor: Colors.white,toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.green,gravity: ToastGravity.TOP);
          setState(() {});
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getTeamList(),
        builder:(context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting)
            {
              return Center(child: SpinKitChasingDots(color: AppColors.secondary,size: 40,));
            }
          else if(!snapshot.hasData){
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:<Widget> [
                    SvgPicture.asset('assets/team.svg'),
                    SizedBox(height: 20,),
                    Text('No Team Member yet',style: GoogleFonts.alata(fontWeight:FontWeight.w600,fontSize:20))
                  ]
                ),
              ),
            );
          }
          else{
            if(snapshot.data.length==0){
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:<Widget> [
                      SvgPicture.asset('assets/team.svg',height: MediaQuery.of(context).size.height/3,),
                      SizedBox(height: 20,),
                      Text('No team member yet',style: GoogleFonts.alata(fontWeight:FontWeight.w600,fontSize:20)),
                      SizedBox(height: 20,),
                      RaisedButton(
                        onPressed: (){
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            enableDrag: true,
                            shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                            backgroundColor: AppColors.tertiary,
                            builder: (BuildContext bc){
                              return Container(
                                height: MediaQuery.of(context).size.height/1.8,
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                  left: 20,
                                  top: 20,
                                  right: 20
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:<Widget>[
                                    TextField(
                                      autofocus: true,
                                      cursorColor: AppColors.primary,
                                      controller: controller,
                                      decoration: InputDecoration(
                                        border:OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary,width: 3),borderRadius: BorderRadius.circular(10)),
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary,width: 2),borderRadius: BorderRadius.circular(10)),
                                        hintText: 'Email/Phone number of the team member',
                                        fillColor: AppColors.primary,
                                        focusColor: AppColors.primary,
                                        hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Align(
                                        child: RaisedButton(
                                        onPressed: ()=>addMember(controller.text),
                                        child: Text('Add',style: TextStyle(fontWeight:FontWeight.w700,fontSize: 16),),
                                        color: AppColors.primary,
                                        splashColor: AppColors.secondary,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                  ]
                                ),  
                              );
                            }
                          );
                        },
                        child: Text('Add a team member',style: TextStyle(fontWeight:FontWeight.w700,fontSize: 16),),
                        color: AppColors.tertiary,
                        splashColor: AppColors.primary,
                      )
                    ]
                  ),
                ),
              );
            }
            else{
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, int index){
                        return Padding(
                          padding: EdgeInsets.only(bottom:2),
                          child: ListTile(
                            trailing: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: !widget.isTeam?()=>removeMember(snapshot.data[index].data['uid']):null,
                              color:Colors.red,
                              splashColor: Colors.red,
                            ),
                            title: Text(snapshot.data[index].data['name'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                            subtitle: Text(snapshot.data[index].data['email']==null?snapshot.data[index].data['phoneNumber']:snapshot.data[index].data['email']),
                          ),
                        );
                      }
                    ),
                  ),
                  !widget.isTeam?Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.tertiary,
                        child: IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.add),
                        onPressed: (){
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            enableDrag: true,
                            shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                            backgroundColor: AppColors.tertiary,
                            builder: (BuildContext bc){
                              return Container(
                                height: MediaQuery.of(context).size.height/1.8,
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                  left: 20,
                                  top: 20,
                                  right: 20
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:<Widget>[
                                    TextField(
                                      autofocus: true,
                                      cursorColor: AppColors.primary,
                                      controller: controller,
                                      decoration: InputDecoration(
                                        border:OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary,width: 3),borderRadius: BorderRadius.circular(10)),
                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary,width: 2),borderRadius: BorderRadius.circular(10)),
                                        hintText: 'Email/Phone number of the team member',
                                        fillColor: AppColors.primary,
                                        focusColor: AppColors.primary,
                                        hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Align(
                                        child: RaisedButton(
                                        onPressed: ()=>addMember(controller.text),
                                        child: Text('Add',style: TextStyle(fontWeight:FontWeight.w700,fontSize: 16),),
                                        color: AppColors.primary,
                                        splashColor: AppColors.secondary,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                  ]
                                ),  
                              );
                            }
                          );
                        },
                        splashColor: AppColors.primary,
                        color: Colors.black,
                    ),
                      )),
                  ):Container()
                ],
              );
            }
          }
        } ,
    ),
    );
  }
}