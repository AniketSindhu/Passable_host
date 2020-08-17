import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passable_host/config/config.dart';
import 'package:flutter_svg/svg.dart';

class TeamPage extends StatefulWidget {
  final String eventCode;
  TeamPage(this.eventCode);
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  TextEditingController controller= TextEditingController();
  Future<List<DocumentSnapshot>> getTeamList() async{
    final x= await Firestore.instance.collection('events').document(widget.eventCode).collection('team').getDocuments();
    return x.documents;
  }
  addMember(String user) async{
    final x= await Firestore.instance.collection('users').where('email',isEqualTo:user.toLowerCase()).getDocuments();
    final y= await Firestore.instance.collection('users').where('phoneNumber',isEqualTo:user.toLowerCase()).getDocuments();
    if(x.documents.isEmpty&&y.documents.isEmpty){
      Fluttertoast.showToast(msg: 'No user found, try using different email or phone number',backgroundColor: Colors.red,gravity: ToastGravity.TOP);
    }
    else
     print('yo');
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
              return Container();
            }
          }
        } ,
    ),
    );
  }
}