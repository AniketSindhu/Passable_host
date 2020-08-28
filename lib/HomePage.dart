import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passable_host/createEvent.dart';
import 'package:passable_host/loginui.dart';
import 'package:passable_host/methods/getUserId.dart';
import 'package:passable_host/methods/googleSignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widgets/eventCard.dart';
import 'config/config.dart';
import 'config/size.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var firestore=Firestore.instance;
  String uid;
  int _selectedIndex = 0;
  void getUser() async{
    uid= await getCurrentUid();
    setState(() {  
    });
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState(){
    super.initState();
    getUser();
  }
  Future getEvents(int index) async{
    List<String>eventCodes=[];
    final QuerySnapshot result= await firestore.collection('users').document(uid).collection('eventsHosted').getDocuments();
    result.documents.forEach((element)=>eventCodes.add(element.data['eventCode']));
    if(index==0){
      final QuerySnapshot hostedEventDetails=await firestore.collection('events').orderBy('eventDateTime',descending: false).where("eventCode",whereIn:eventCodes).getDocuments();
      return hostedEventDetails.documents;
    }
    else{
      final QuerySnapshot hostedEventDetails=await firestore.collection('OnlineEvents').orderBy('eventDateTime',descending: false).where("eventCode",whereIn:eventCodes).getDocuments();
      return hostedEventDetails.documents;
    }
  }
  @override
  Widget build(BuildContext context) {
    double height=SizeConfig.getHeight(context);
    double width=SizeConfig.getWidth(context);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primary,
        items:<BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(FontAwesome.calendar),title: Text('Offline events',)),
          BottomNavigationBarItem(icon: Icon(FontAwesome.laptop),title: Text('Online events',)),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton:FloatingActionButton.extended(
       backgroundColor: AppColors.tertiary,
       onPressed: (){
         Navigator.push(context, MaterialPageRoute(builder:(context)=>CreateEvent(uid)));
       },
       label: Text("Host an event",style: TextStyle(fontWeight:FontWeight.w500),),
       icon: Icon(Icons.add),),
      body:Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(width/15,height/15,width/15,height/50),
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                   text: TextSpan(
                     children:<TextSpan>[
                      TextSpan(text:"Pass'",style:GoogleFonts.lora(textStyle:TextStyle(color: AppColors.primary,fontSize:35,fontWeight: FontWeight.bold))),
                      TextSpan(text:"able",style:GoogleFonts.lora(textStyle:TextStyle(color: AppColors.secondary,fontSize:35,fontWeight: FontWeight.bold))),
                    ]
                  )
                ),
                PopupMenuButton(
                  icon:Icon(Icons.more_horiz,color: AppColors.primary,size:30),
                  color: AppColors.primary,
                  itemBuilder: (context){
                    var list=List<PopupMenuEntry<Object>>();
                    list.add(PopupMenuItem(child: Text("Profile",style: TextStyle(color:AppColors.tertiary),)));
                    list.add(PopupMenuDivider(height: 4,));
                    list.add(PopupMenuItem(
                      child: Text("Logout",style: TextStyle(color:AppColors.tertiary),),
                      value: 2,
                    ));
                    return list;
                  },
                  onSelected:(value)async{
                    if(value==2)
                    {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      signOut();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Login()),ModalRoute.withName('homepage'));
                    }
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right:16.0,bottom: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("Hosted Events",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color:Colors.redAccent),),
            ),
          ),
          uid!=null?
          FutureBuilder(
            future: getEvents(_selectedIndex),
            builder:(context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting)
              {
                return Expanded(child: Center(child: SpinKitChasingDots(color:AppColors.secondary,size:40)));
              }
              else if(snapshot.data==null)
              {
                return Column(
                  children: [
                    Container(
                      width: width,              
                      height: height/2,
                      child: Center(
                       child: Padding(
                           padding: const EdgeInsets.all(16.0),
                          child: SvgPicture.asset(
                            'assets/event.svg',
                            semanticsLabel: 'Event Illustration'
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height:height/20),
                    Text("Nothing to show up here :(")
                  ],
                );
              }
              else{
                if(snapshot.data.length==0){
                  return Column(
                    children: [
                      Container(
                        width: width,              
                        height: height/2,
                        child: Center(
                          child: Padding(
                           padding: const EdgeInsets.all(16.0),
                           child: SvgPicture.asset(
                            'assets/event.svg',
                            semanticsLabel: 'Event Illustration'
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height:height/20),
                    Text("Nothing to show up here :(")
                  ],
                  );
                }
                else 
                return Expanded(
                  child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder:(context,index){
                    return eventCard(snapshot.data[index], height, width, context);
                  }
                ),
              );
          }}):Expanded(child: Center(child: SpinKitChasingDots(color:AppColors.secondary,size:40))),
        ],
      )
    );
  }
}