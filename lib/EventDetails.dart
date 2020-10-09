import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:passable_host/Announcements.dart';
import 'package:passable_host/Dashboard.dart';
import 'package:passable_host/Models/user.dart';
import 'package:passable_host/Team.dart';
import 'package:passable_host/config/size.dart';
import 'package:passable_host/edit_event.dart';
import 'package:passable_host/lists.dart';
import 'package:passable_host/scanPass.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Pass.dart';
import 'config/config.dart';
import 'package:flutter_show_more/flutter_show_more.dart';
import 'package:flutter_icons/flutter_icons.dart';

class DetailPage extends StatefulWidget {
  final DocumentSnapshot post;
  final String uid;
  final Function rebuild;
  DetailPage(this.post,this.uid,this.rebuild);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController eventCodeController=TextEditingController();
  String writtenCode,passCode;
  final _key = new GlobalKey();
  int page=0;
  bool isTeam;

  Future helper()async{
    final x=await Firestore.instance.collection('helpers').getDocuments();
    return x.documents;
  }
  void isTeamMember() async{
    final x = await Firestore.instance.collection('users').document(widget.uid).collection('eventsHosted').document(widget.post.data['eventCode']).get();
    isTeam=x.data['isTeam'];
  }
  void showPass()async{
    String passCode;
    await Firestore.instance.collection('users').document(widget.uid).collection('eventJoined').where('eventCode',isEqualTo:widget.post.data['eventCode']).getDocuments()
    .then((value){
      passCode=value.documents.elementAt(0).data['passCode'];
    });
    Navigator.push(context,MaterialPageRoute(builder:(context){return Pass(passCode,widget.post);}));
  }

  void getPass(BuildContext context,double height)async{
    showDialog(
      context:context,
       builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
          scrollable: true,
          backgroundColor:AppColors.secondary,
          title: Center(child: Text("Get Entry Pass",style: TextStyle(color:Colors.white,fontWeight:FontWeight.w700,fontSize:30),)),
          content: Container(
           height: height/5,
           child: Column(
             children: [
               TextField(
                  controller: eventCodeController,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.primary,fontSize: 25,fontWeight: FontWeight.w500),
                   cursorColor: AppColors.primary,
                  autofocus: true,
                   decoration: InputDecoration(
                    hintText:"Enter event code"
                   ),
                 ),
                 Expanded(
                   child: Center(
                     child: RaisedButton(
                       onPressed:() async{
                        final x= await Firestore.instance.collection('users').document(widget.uid).collection('eventJoined').document(widget.post.data['eventCode']).get();
                         if(widget.post.data['eventCode']!=eventCodeController.text)
                           Fluttertoast.showToast(msg: "Wrong code Entered",backgroundColor: Colors.red,textColor: Colors.white);
                         else if(widget.post.data['joined']>=widget.post.data['maxAttendee'])
                           Fluttertoast.showToast(msg: "Event Full",backgroundColor: Colors.red,textColor: Colors.white);
                        else if(x.exists)
                           {
                             Fluttertoast.showToast(msg: "Event Already Joined",backgroundColor: Colors.red,textColor: Colors.white);
                          }
                         else
                        { passCode= randomAlphaNumeric(6);
                          User user;
                          final userDoc= await Firestore.instance.collection('users').document(widget.uid).get();
                         user=User.fromDocument(userDoc);
                         Firestore.instance.collection("events").document(widget.post.data['eventCode']).collection('guests').document(passCode).setData({'user':user.uid,'phone':user.phone,'email':user.email,'name':user.name,'passCode':passCode,'Scanned':false});
                         Firestore.instance.collection('users').document(widget.uid).collection('eventJoined').document(widget.post.data['eventCode']).setData({'eventCode':widget.post.data['eventCode'],'passCode':passCode});
                         Firestore.instance.collection('events').document(widget.post.data['eventCode']).updateData({'joined': widget.post.data['joined']+1});
                         Navigator.pop(context);
                         Navigator.push(context, MaterialPageRoute(builder: (context){return Pass(passCode,widget.post);}));
                        }
                     },
                     textColor: AppColors.primary,
                      child: Text("Get Pass",style: TextStyle(fontWeight:FontWeight.w600,fontSize:20),),
                      elevation: 10,
                      color: AppColors.tertiary,
                    ),
                 ),
                )
             ],
           )
          ),
        );
     }
    ).then((value) {
      eventCodeController.clear();
    });
  }
  @override
  void initState(){
    super.initState();
    isTeamMember();
  }
  @override
  Widget build(BuildContext context) {
    double width=SizeConfig.getWidth(context);
    double height=SizeConfig.getHeight(context);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(FontAwesome.edit),title: Text('Event Info'),backgroundColor: AppColors.primary,),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard),title:Text('Dashboard'),backgroundColor: AppColors.primary,),
          BottomNavigationBarItem(icon: Icon(FontAwesome.qrcode),title:Text('Check in'),backgroundColor: AppColors.primary,),
          BottomNavigationBarItem(icon: Icon(FontAwesome.users),title:Text('Team'),backgroundColor: AppColors.primary,),
          BottomNavigationBarItem(icon: Icon(FontAwesome.bullhorn),title:Text('Announcements'),backgroundColor: AppColors.primary,),
        ],
        elevation: 5,
        unselectedItemColor: AppColors.secondary,
        currentIndex: page,
        backgroundColor: Colors.purple,
        selectedItemColor: AppColors.tertiary,
        showUnselectedLabels: true,
        onTap:(index){
          setState(() {
            page=index;
          });
        },
      ),
      appBar: AppBar(
        title:Text(page==0?"Event Details":page==1?'Dashboard':page==2?'Check In':page==3?'Team':'Announcements',),
        centerTitle: true,
        actions:<Widget>[
          page==3?
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: GestureDetector(
                onTap: (){
                  final dynamic tooltip = _key.currentState;
                  tooltip.ensureTooltipVisible();
                },
                child: Tooltip(
                  key: _key,
                  padding: EdgeInsets.all(20),
                  preferBelow: true,
                  showDuration: Duration(seconds:5),
                  message: 'What can team members do?\n\n'
                            '1. They can scan passes (check in the guests)\n'
                            '2. They can make announcements\n'
                            '3. They cant change event deatails',
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: AppColors.tertiary),
                  child: Icon(Icons.info,color: AppColors.tertiary,size: 30,),
                  textStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black),
                  verticalOffset: 10,
                ),
              ),
            ):Container()
        ],
        backgroundColor: AppColors.primary,
      ),
      body:page==0?SingleChildScrollView(
        child:Container(
          margin:EdgeInsets.symmetric(horizontal:width/25,vertical: height*0.02),
          child: Column(
            children: [
              Container(
                height: height/3.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(widget.post.data['eventBanner'],width:width/2.8,height: height/3.6,fit: BoxFit.fitHeight,),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 12, 10, 10),
                        child: Container(
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("${widget.post.data['eventName']}",style: GoogleFonts.varelaRound(textStyle:TextStyle(fontWeight:FontWeight.w600,fontSize: 22))),
                              ),
                              SizedBox(height:5),
                              Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text('${DateFormat('hh:mm a').format(widget.post.data['eventDateTime'].toDate())}',style: TextStyle(fontWeight:FontWeight.w600,fontSize: 18),)
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text('${DateFormat('EEE, d MMMM yyyy').format(widget.post.data['eventDateTime'].toDate())}',style: TextStyle(fontWeight:FontWeight.w400,fontSize: 14),)
                                  ),
                                ],
                              ),
                            ],
                          )
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height:15),
              Align(
                alignment:Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Event Code: ${widget.post.data['eventCode']}',style: GoogleFonts.varelaRound(textStyle:TextStyle(color: Colors.red,fontWeight: FontWeight.w600,fontSize: 18)),)),
                    IconButton(
                      icon: Icon(Icons.edit,color: Colors.black),
                      color: AppColors.primary,
                      splashColor: AppColors.primary,
                      highlightColor: AppColors.primary,
                      onPressed: (){
                        if(DateTime.now().isBefore(widget.post.data['eventDateTime'].toDate()))
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPage(widget.post,widget.rebuild)));
                        else 
                          Fluttertoast.showToast(msg: 'You cant edit your past ;)',backgroundColor:Colors.red,textColor:Colors.white,gravity: ToastGravity.TOP);
                      }, 
                    ),
                    IconButton(
                      color: AppColors.primary,
                      splashColor: AppColors.primary,
                      highlightColor: AppColors.primary,
                      icon: Icon(Icons.share,color: Colors.black,),
                      onPressed:()async{
                        await FlutterShare.share(
                          title: 'Get entry pass for ${widget.post.data['eventName']}',
                          text: ' Get passes for ${widget.post.data['eventName']} happening on ${DateFormat('dd-MM-yyyy AT hh:mm a').format(widget.post.data['eventDateTime'].toDate())}\n\n Event Code:''${widget.post.data['eventCode']}''',
                          linkUrl: 'https://passable.in/',
                          chooserTitle: 'Get entry pass for ${widget.post.data['eventName']}'
                        );
                      }
                    ),
                  ],
                ),
              ),
              !widget.post.data['isOnline']?SizedBox(height: 15,):Container(),
              !widget.post.data['isOnline']?Align(
                child: Text('Address',style: GoogleFonts.varelaRound(textStyle:TextStyle(color: AppColors.primary,fontWeight: FontWeight.bold,fontSize: 24)),),
                alignment: Alignment.centerLeft,
              ):Container(),
              !widget.post.data['isOnline']?Divider(color:AppColors.secondary,height: 10,thickness: 2,):Container(),
              !widget.post.data['isOnline']?SizedBox(height:15):Container(),
              !widget.post.data['isOnline']?Text('${widget.post.data['eventAddress']}',style: TextStyle(fontSize: 18),):Container(),            
              SizedBox(height:30),
              Align(
                child: Text('Event Description',style: GoogleFonts.varelaRound(textStyle:TextStyle(color: AppColors.primary,fontWeight: FontWeight.bold,fontSize: 24)),),
                alignment: Alignment.centerLeft,
              ),
              Divider(color:AppColors.secondary,height: 10,thickness: 2,),
              SizedBox(height:15),
              ShowMoreText(
                '${widget.post.data['eventDescription']}',
                maxLength: 50,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                showMoreText: 'show more',
                showMoreStyle: TextStyle(
                fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
                shouldShowLessText: false,
              ),
              SizedBox(height:30),
              Align(
                child: Text('Personal Helper',style: GoogleFonts.varelaRound(textStyle:TextStyle(color: AppColors.primary,fontWeight: FontWeight.bold,fontSize: 24)),),
                alignment: Alignment.centerLeft,
              ),
              Divider(color:AppColors.secondary,height: 10,thickness: 2,),
              SizedBox(height:10),
              FutureBuilder(
                future: helper(),
                builder:(context,snap){
                  if(snap.connectionState==ConnectionState.waiting||snap.data==null)
                    {
                      return Container();
                    }
                  else
                  return RaisedButton(
                    onPressed: (){
                      launch('${snap.data[widget.post.data['helper']].data['contact']}');
                    },
                    color: Colors.amber,
                    child: Text('Contact ${snap.data[widget.post.data['helper']].data['name']}',style: TextStyle(fontSize: 18, color: Colors.black),),
                  );
                },
              ),
            ],
          ),
        )
      ):page==1?Dashboard(isTeam,widget.post):page==2?ScanPass(widget.post.data['eventCode'],widget.post.data['isOnline']):page==3?TeamPage(widget.post.data['eventCode'],isTeam,widget.post.data['isOnline']):Announcements(widget.post.data['eventCode'], true,widget.post.data['isOnline'],widget.post.data['eventName'])
    );
  }
}
