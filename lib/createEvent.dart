import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:international_phone_input/international_phone_input.dart';
import 'package:lottie/lottie.dart';
import 'package:passable_host/HomePage.dart';
import 'package:passable_host/Methods/firebaseAdd.dart';
import 'package:passable_host/loginui.dart';
import 'package:random_string/random_string.dart';
import 'Widgets/clipper.dart';
import 'config/config.dart';
import 'config/size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:place_picker/place_picker.dart' as latlng;
import 'package:flutter_config/flutter_config.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateEvent extends StatefulWidget {
  final String uid;
  CreateEvent(this.uid);
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  Geoflutterfire geo = Geoflutterfire();
  String eventName,eventDescription,eventAddress,eventCode;
  String hostName,hostEmail,hostPhoneNumber;
  String _phone;
  String isoCode;
  int maxAttendees;
  bool imageDone=false;
  File _image;
  PickResult mainResult;
  GeoFirePoint myLocation ;
  DateTime dateTime;
  Completer<maps.GoogleMapController> _controller = Completer();
  final picker = ImagePicker();
  final hostNameController=TextEditingController();
  final hostEmailController=TextEditingController();
  final hostPhoneController=TextEditingController();
  final nameController=TextEditingController();
  final descriptionController=TextEditingController();
  final eventAddController=TextEditingController();
  final maxAttendeeController=TextEditingController();
  String selectedCategory;
  bool isOnline=false;
  List<DropdownMenuItem> categoryList=[
    DropdownMenuItem(
      child: Text('Appearance/Singing',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Appearance/Singing',
    ),
    DropdownMenuItem(
      child: Text('Attaraction',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Attaraction',
    ),
    DropdownMenuItem(
      child: Text('Camp, Trip or Retreat',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Camp, Trip or Retreat',
    ),
    DropdownMenuItem(
      child: Text('Class, Training, or Workshop',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Class, Training, or Workshop',
    ),
    DropdownMenuItem(
      child: Text('Concert/Performance',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Concert/Performance',
    ),
    DropdownMenuItem(
      child: Text('Conference',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Conference',
    ),
    DropdownMenuItem(
      child: Text('Convention',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Convention',
    ),
    DropdownMenuItem(
      child: Text('Dinner or Gala',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Dinner or Gala',
    ),
    DropdownMenuItem(
      child: Text('Festival or Fair',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Festival or Fair',
    ),
    DropdownMenuItem(
      child: Text('Game or Competition',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Game or Competition',
    ),
    DropdownMenuItem(
      child: Text('Meeting/Networking event',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Meeting/Networking event',
    ),
    DropdownMenuItem(
      child: Text('Party/Social Gathering',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Party/Social Gathering',
    ),
    DropdownMenuItem(
      child: Text('Other',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),),
      value: 'Other',
    ),
  ];
  
  void _inputChange(
    String number, String internationlizedPhoneNumber, String isoCode) {
    setState(() {
      isoCode = isoCode;
      if (internationlizedPhoneNumber.isNotEmpty) {
        hostPhoneNumber=internationlizedPhoneNumber;
      }
    });
  }
  onEventSelect(int x){
    if(x==0)
    setState(() {
      isOnline=false;
    });
    else
    setState(() {
      isOnline=true;
      mainResult=null;
    });

    print(isOnline);
  }
  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      if (hostPhoneNumber== null) {
        Fluttertoast.showToast(
          msg:'Phone number is not valid :( ',
          backgroundColor: Colors.red,
          fontSize: 18 
        );
      }
      else{
      _formKey.currentState.save();
      eventCode=randomAlphaNumeric(6);
      Navigator.push(context, MaterialPageRoute(builder: (context){return MaxGuests(eventName, eventCode, eventDescription, eventAddress,_image,dateTime, widget.uid,myLocation);}));
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }}
     } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }
  void showPlacePicker() async {
   Navigator.push(
   context,
    MaterialPageRoute(
      builder: (context) => PlacePicker(
        //apiKey:  FlutterConfig.get('MAP_API'), 
        onPlacePicked: (result) { 
         setState(() {
          mainResult=result;
          eventAddController.text=mainResult.formattedAddress;
          myLocation = geo.point(latitude: result.geometry.location.lat, longitude: result.geometry.location.lng);
         }); 
           Navigator.of(context).pop();
         },
         initialPosition:latlng.LatLng(28.7041, 77.1025),
         useCurrentLocation: true,
       ),
     ),
  ).then((value) async{
    final maps.GoogleMapController controller = await _controller.future;
    controller.animateCamera(maps.CameraUpdate.newCameraPosition(
      maps.CameraPosition(
        target:maps.LatLng(myLocation.latitude,myLocation.longitude),
        zoom: 15.4746
      )
    ));
  });
}
                    
  @override
  Widget build(BuildContext context) {
    double height=SizeConfig.getHeight(context);
    double width=SizeConfig.getWidth(context);
    return Scaffold(
      appBar: AppBar(
        title:Text('Create an event',style: GoogleFonts.cabin(fontWeight:FontWeight.w600,fontSize: 25)),
        centerTitle: true,
      ),
      body:Container(
        margin: EdgeInsets.symmetric(horizontal:width/20),
        child: ListView(
          children: <Widget>[
            SizedBox(height:15),
            Padding(
              padding: const EdgeInsets.only(top:8),
              child: Text('Basic Info',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)),
            ),
            Padding(
              padding: const EdgeInsets.only(top:2,bottom:12),
              child: Text(
                'Name your event and tell event-goers why they should come. Add details that highlight what makes it unique.',
                style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:16,color: Color(0xff39364f),)),
            ),
            Form(
              autovalidate: _autoValidate,
              key: _formKey,
              child:Column(
                children: <Widget>[
                  EventCreateTextField(
                    maxLines:1,
                    number:false,
                    width:0.5,
                    radius: 5,
                    controller: nameController,
                    validator: (value) => value.length<2?'*must be 2 character long':null,
                    hint: "Event Name",
                    icon: Icon(FontAwesome.font,color:AppColors.secondary,),
                    onSaved: (input){
                      eventName=input;
                    },  
                  ),
                  SizedBox(height:20),
                  EventCreateTextField(
                    maxLines:5,
                    number:false,
                    width:0.5,
                    radius: 5,
                    controller: descriptionController,
                    validator: (value) => value.length<2?'*must be 2 character long':null,
                    hint: "Event Description",
                    icon: Icon(Icons.border_color,color:AppColors.secondary,),
                    onSaved: (input){
                      eventDescription=input;
                    },  
                  ),
                  SizedBox(height:20),
                  DropdownButtonFormField(   
                    items: categoryList,
                    validator: (value)=>selectedCategory==null?'Select a category':null,
                    decoration: InputDecoration(
                        labelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),
                        labelText: 'Category of the event',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color:AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color:AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                    ),
                    onChanged: (value){
                      setState(() {
                        selectedCategory=value;
                      });
                    },
                  ),
                  SizedBox(height:10),
                  Divider(thickness:1),
                  SizedBox(height:8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top:8),
                      child: Text('Host Info',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:2,bottom:12),
                    child: Text(
                      'Help guests by providing information about the host of the event, this info will be shown on the event page.',
                      style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:16,color: Color(0xff39364f),)),
                  ),
                  EventCreateTextField(
                    maxLines:1,
                    number:false,
                    width:0.5,
                    radius: 5,
                    controller: hostNameController,
                    validator: (value) => value.trim().length>0?null:'Enter a valid name',
                    hint: "Host Name",
                    icon: Icon(FontAwesome.font,color:AppColors.secondary,),
                    onSaved: (input){
                      hostName=input;
                    },  
                  ),
                  SizedBox(height:20),
                  EventCreateTextField(
                    maxLines:1,
                    number:false,
                    width:0.5,
                    radius: 5,
                    controller: hostEmailController,
                    validator: (value){
                      {
                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(value))
                          return 'Enter Valid Email';
                        else
                          return null;
                      }
                    },
                    hint: "Host Email",
                    icon: Icon(FontAwesome.at,color:AppColors.secondary,),
                    onSaved: (input){
                      hostEmail=input;
                    },  
                  ),
                  SizedBox(height:20),
                  FormField(
                    builder:(context)=>InternationalPhoneInput(
                    //border: OutlineInputBorder(borderSide: BorderSide(color:AppColors.primary,width:2,style:BorderStyle.solid)),
                      initialPhoneNumber: _phone,
                      initialSelection: '+91',
                      onPhoneNumberChange: _inputChange,
                      enabledCountries: ['+91'],
                      decoration: InputDecoration(
                        labelText: 'Host phone number',
                        fillColor:AppColors.primary,
                        focusColor: AppColors.primary,
                        enabledBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(5),borderSide: BorderSide(color:AppColors.primary,width:1.5)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),borderSide: BorderSide(color:AppColors.primary,width: 1.5)),
                        labelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height:10),
                  Divider(thickness:1),
                  SizedBox(height:8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top:8),
                      child: Text('Location',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:2,bottom:12),
                    child: Text(
                      'Help people in the area discover your event and let attendees know where to show up.',
                      style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:16,color: Color(0xff39364f),)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          onEventSelect(0);
                        },
                        child: Container(
                          decoration: BoxDecoration( 
                            borderRadius: BorderRadius.circular(10),
                            border:Border.all(width: 0.8,color: AppColors.primary),
                            color: isOnline?Colors.white:AppColors.tertiary.withOpacity(1),
                          ),
                          
                          child:Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(child: Text('Offline event',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),)),
                          ),
                        ),
                      ),
                      SizedBox(width:20),
                      InkWell(
                        onTap: (){
                          onEventSelect(1);
                        },
                        child: Container(
                          decoration: BoxDecoration( 
                            borderRadius: BorderRadius.circular(10),
                            border:Border.all(width: 0.8,color: AppColors.primary),
                            color: !isOnline?Colors.white:AppColors.tertiary.withOpacity(1),
                          ),   
                          child:Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(child: Text('Online event',style:GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height:20),
                 !isOnline&&mainResult==null?RaisedButton(
                    onPressed:()=>showPlacePicker(),
                    elevation: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesome.location_arrow,color: AppColors.secondary,),
                        SizedBox(width: 5,),
                        Text('Locate on map',style:GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: Colors.white)),
                      ],
                    ),
                    color: AppColors.primary,
                    splashColor: AppColors.secondary,
                  )
                  :!isOnline&&mainResult!=null?Container(
                    height: 200,
                    child: Column(
                      children: [
                        Expanded(
                          child: maps.GoogleMap(
                            onMapCreated: (maps.GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: {
                              maps.Marker(
                                markerId: maps.MarkerId('marker'),
                                position:maps.LatLng(myLocation.latitude,myLocation.longitude) ,
                              )
                            },            
                            initialCameraPosition: maps.CameraPosition(
                              target:maps.LatLng(myLocation.latitude,myLocation.longitude),
                              zoom: 15.4746
                            ),
                            mapType: maps.MapType.normal,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            color:AppColors.primary ,
                            splashColor: AppColors.tertiary,
                            child: Icon(FontAwesome.edit,color:Colors.white),
                            onPressed:(){
                              showPlacePicker();
                            },
                          ),
                        )
                      ],
                    ),
                  ):
                  Text(
                    'No location is required in online events, you can share the streaming/joining link using the announcement feature',
                    style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:16,color: Color(0xff39364f),)
                  ),              
                  mainResult!=null?SizedBox(height:20):Container(),
                  mainResult!=null?EventCreateTextField(
                    maxLines:1,
                    number:false,
                    width:0.5,
                    radius: 5,
                    controller: eventAddController,
                    validator: (value) => value.length<2?'*must be 2 character long':null,
                    hint: "Event Address",
                    icon: Icon(Icons.near_me,color:AppColors.secondary,),
                    onSaved: (input){
                      eventAddress=input;
                    },  
                  ):Container(),
                  SizedBox(height:10),
                  Divider(thickness:1),
                  SizedBox(height:8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top:8),
                      child: Text('Date & Time',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:2,bottom:12),
                    child: Text(
                      'Tell guests when your event starts so they can make plans to attend.',
                      style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:16,color: Color(0xff39364f),)),
                  ),

                  FormField(
                    validator: (value)=>dateTime==null?"*Date & time are neccessary":null,
                    builder:(datecontext){
                      return dateTime==null?FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius:BorderRadius.circular(6)
                        ),
                        color: AppColors.secondary,
                        onPressed: () {
                          DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime: DateTime.now().add(new Duration(days: 365)) ,onChanged: (date) {
                             setState(() {
                               dateTime=date;
                             }); 
                            }, onConfirm: (date) {
                                setState(() {
                                  dateTime=date;
                                }); 
                            }, currentTime: DateTime.now(), locale: LocaleType.en);
                        },
                      child: Text(
                        'Event Time & Date',
                        style: TextStyle(color: AppColors.primary,fontSize:20,fontWeight: FontWeight.w700,),
                      )):
                      Container(
                        child: OutlineButton(
                          borderSide: BorderSide(color:AppColors.secondary,width:3),
                          onPressed: (){
                          DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime: DateTime.now().add(new Duration(days: 365)) ,onChanged: (date) {
                             setState(() {
                               dateTime=date;
                             }); 
                            }, onConfirm: (date) {
                             setState(() {
                               dateTime=date;
                             }); 
                            }, currentTime: DateTime.now(), locale: LocaleType.en);                          
                          },
                          child: Text('${DateFormat('dd-MM-yyyy  hh:mm a').format(dateTime)}',style: TextStyle(color:AppColors.primary,fontWeight:FontWeight.w500,fontSize:20),))
                        );
                    },
                  ),
                  SizedBox(height:20),                
                  FormField(
                    validator:(value)=>_image==null?'*Must upload a photo':null,
                    onSaved:(input){imageDone=true;},
                    builder: (context){
                    return _image==null?Column(
                      children: <Widget>[
                        Container(
                          height: 80,
                          width: 80,
                          child: IconButton(
                            icon: Icon(Icons.image,size:60,color: AppColors.secondary,),
                            onPressed:()async{
                              final pickedFile = await picker.getImage(source: ImageSource.gallery);
                              setState(() {
                                _image = File(pickedFile.path);
                              });
                            }
                          ),
                        ),
                        Text('Upload event poster (vertical)',style: TextStyle(color:AppColors.primary,fontSize:20,fontWeight: FontWeight.w700),)
                      ],
                    ):
                    Column(
                      children: <Widget>[
                        Center(child: Image.file(_image,fit: BoxFit.contain,width:width*0.8,)),
                        SizedBox(height:10),
                        OutlineButton(
                          borderSide: BorderSide(color:AppColors.secondary,width:3),
                          onPressed:() async{
                            final pickedFile = await picker.getImage(source: ImageSource.gallery);
                            setState(() {
                              _image = File(pickedFile.path);
                            });                          
                          },
                          child: Text("Change banner?",style: TextStyle(color:AppColors.primary,fontWeight:FontWeight.w500,fontSize:20,fontStyle: FontStyle.italic),),
                        ),
                      ],
                    );
                  }),
                ],
              )
            ),
            SizedBox(height:20),
            Align(
              child: Padding(
                padding: const EdgeInsets.only(bottom:15.0),
                child: RaisedButton(
                  onPressed:(){
                    _validateInputs();
                  },
                  child: Text('Create event',style: TextStyle(fontSize:20),),
                  color: AppColors.tertiary,
                   ),
              ),
            )
          ],
        ),
      )     
    );
  }
}
class CongoScreen extends StatefulWidget {
  final String eventCode;
  final String eventName;
  final String eventAddress;
  final DateTime dateTime;
  final File image;
  CongoScreen(this.eventName,this.eventCode,this.eventAddress,this.image,this.dateTime,);
  @override
  _CongoScreenState createState() => _CongoScreenState();
}

class _CongoScreenState extends State<CongoScreen> {
  ConfettiController _controllerCenter;
  @override
  void initState(){
    super.initState();
   _controllerCenter =
      ConfettiController(duration: const Duration(seconds: 3));
  }
  Widget build(BuildContext context) {
    double height=SizeConfig.getHeight(context);
    double width=SizeConfig.getWidth(context);
     _controllerCenter.play();
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left:15.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton.extended(
            label: Text('Finish'),
            onPressed:(){
              Navigator.of(context)
              .popUntil(ModalRoute.withName("/homepage"));
              Navigator.push(context, MaterialPageRoute(builder: (context){return HomePage();}));
            },
            icon: Icon(Icons.play_arrow),
            tooltip: 'continue',
            backgroundColor: Colors.redAccent,
          ),
        ),
      ),
      body: Container(
        child: Center(
         child: 
          Stack(
            children: <Widget>[
              Align(
                child: ClipPath(
                  child: Container(
                    color: AppColors.tertiary,
                    height: 100,
                  ),
                  clipper: BottomWaveClipper(),
                ),
              alignment: Alignment.bottomCenter,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top:height/20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0),
                        child: Text("Your Event is created",style:GoogleFonts.lora(textStyle:TextStyle(color:AppColors.primary,fontSize:30,fontWeight:FontWeight.w800),)),
                      ),
                    ),
                    SizedBox(height:10),
                    Text("Event Code:${widget.eventCode}",style:GoogleFonts.poppins(textStyle:TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.red),)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 5),
                      child: Text("Share the event code with your guests and they will get an entry pass for the event",style:GoogleFonts.poppins(textStyle:TextStyle(fontSize:14,fontWeight:FontWeight.w500,fontStyle: FontStyle.italic,),),textAlign: TextAlign.center,),
                    ),
                    Image.file(widget.image,width: width*0.8,height: height*0.45),
                    Text("${widget.eventName}",textAlign: TextAlign.center,style:GoogleFonts.poppins(textStyle:TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: AppColors.primary),)),
                    Text("At ${widget.eventAddress}",style:GoogleFonts.poppins(textStyle:TextStyle(fontSize:16,fontWeight: FontWeight.bold),),textAlign: TextAlign.center,),
                    Text('On ${DateFormat('dd-MM-yyyy  hh:mm a').format(widget.dateTime)}',style:GoogleFonts.poppins(textStyle:TextStyle(fontSize:18,fontWeight: FontWeight.bold),)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape:BoxShape.circle,
                        border: Border.all(color:Colors.black)
                      ),
                      child: IconButton(
                        color: AppColors.primary,
                        splashColor: AppColors.primary,
                        highlightColor: AppColors.primary,
                        icon: Icon(Icons.share,color: Colors.black,),
                        onPressed:()async{
                          await FlutterShare.share(
                            title: 'Get entry pass for ${widget.eventName}',
                            text: 'Enter the code ''${widget.eventCode}'' to get an entry pass for the ${widget.eventName} happening on ${DateFormat('dd-MM-yyyy  hh:mm a').format(widget.dateTime)}',
                            linkUrl: 'https://flutter.dev/',
                            chooserTitle: 'Get entry pass for ${widget.eventName}'
                          );
                        }),
                    ),
                    Text("Invite guests",style: TextStyle(fontWeight:FontWeight.w500),),
                    SizedBox(height:10)
                  ],
                ),
              ),              
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                 confettiController: _controllerCenter,
                 blastDirectionality: BlastDirectionality.explosive,
                 numberOfParticles: 30,
                 gravity: 0.1,
                ),
              ),          
            ],
          )
        ),
      ),
    );
  }
}

class MaxGuests extends StatefulWidget {
  final String eventName;
  final String eventDescription;
  final String eventAddress;
  final String eventCode;
  final File image;
  final DateTime dateTime;
  final String uid;
  final GeoFirePoint myLocation;
  MaxGuests(this.eventName,this.eventCode,this.eventDescription,this.eventAddress,this.image,this.dateTime,this.uid,this.myLocation);
  @override
  _MaxGuestsState createState() => _MaxGuestsState();
}

class _MaxGuestsState extends State<MaxGuests> {
  int maxAttendees;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser _user;
  Razorpay _razorpay;
  double amount;
  int pay;
  TextEditingController maxAttendeeController=TextEditingController();

  void submit(){
    FirebaseAdd().addEvent(widget.eventName, widget.eventCode, widget.eventDescription, widget.eventAddress, maxAttendees,widget.image,widget.dateTime, widget.uid,widget.myLocation);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CongoScreen(widget.eventName,widget.eventCode,widget.eventAddress,widget.image,widget.dateTime)));
  }

  calcAmount(){
    if(maxAttendees<=50)
      setState(() {
        amount=0;
        pay=0;
      });
    else if(maxAttendees>50)
      setState(() {
        amount=149;
        pay=15900;
      });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "SUCCESS: " + response.paymentId,
      backgroundColor: Colors.green,
    );
    submit();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        backgroundColor: Colors.red,
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        backgroundColor: Colors.redAccent,
        msg: "EXTERNAL_WALLET: " + response.walletName,);
  }

  getCurrentUser() async {
    _user = await _firebaseAuth.currentUser();
   }
   
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getCurrentUser();
  }
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
  void openCheckout() async {
    if(maxAttendees<=0)
      {
        Fluttertoast.showToast(
        backgroundColor: Colors.red,
        msg: 'Max guests must be greater than 0');
      }
    else if(maxAttendees<=50 && maxAttendees>0)
      {
        submit();
      }
    else{
    var options = {
      //'key':'rzp_test_df25oDEIBVWDyE',
      'key': FlutterConfig.get('Razor_Pay'),
      'amount': pay,
      'name': '${widget.eventName}',
      'description': 'On ${DateFormat('dd-MM-yyyy AT hh:mm a').format(widget.dateTime)}',
      'prefill': {'contact': '${_user.displayName}', 'email': '${_user.email==null?'':_user.email}'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }}
}
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title:Text('Create Event')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Lottie.asset('assets/payment.json'),
            ),
            SizedBox(height:10),
              CustomTextField(
                maxLines:1,
                number:true,
                width:0.5,
                radius: 5,
                controller: maxAttendeeController,
                validator: (value) => value.contains(new RegExp(r'^[0-9]*[1-9]+$|^[1-9]+[0-9]*$'))?null:'*more than 1 guest required',
                hint: "Max number of guests",
                icon: Icon(Icons.confirmation_number,color:AppColors.secondary,),
                onChanged: (value){
                  maxAttendees=int.parse(value);
                  calcAmount();
                },
                onSaved: (input){
                  setState(() {
                    maxAttendees=int.parse(input);
                    calcAmount();
                  });                  
                },  
              ),
            SizedBox(height:4),
            Center(child: Text('*this value will not be able to change after event creation',style:TextStyle(color: Colors.redAccent))),
            SizedBox(height:15),
            Center(
              child: RichText(
                text:TextSpan(
                  children:<TextSpan>[
                    TextSpan(text:'Max Guests<50 = ',style: TextStyle(fontSize:15,fontWeight:FontWeight.w500,color: Colors.black)),
                    TextSpan(text:'FREE',style: TextStyle(fontSize:17,fontWeight:FontWeight.w700,color: Colors.black)),
                  ]
                ) 
              )
            ),
            SizedBox(height:5),
            Center(
              child: RichText(
                text:TextSpan(
                  children: <TextSpan>[
                    TextSpan(text:'Max Guests>150 = ',style: TextStyle(fontSize:15,fontWeight:FontWeight.w500,color: Colors.black)),
                    TextSpan(text:'₹199',style: TextStyle(fontSize:15,fontWeight:FontWeight.w600,decoration: TextDecoration.lineThrough,color:Colors.black)),
                    TextSpan(text:' ₹149',style: TextStyle(fontSize:18,fontWeight:FontWeight.w700,color: Colors.black,)),
                  ]
                )
              ),
            ),
            SizedBox(height:25),
            Align(
              child: RaisedButton(
                color: AppColors.primary,
                child: Text('${amount==0||amount==null?'FREE':'Pay ₹ $amount'}',style:GoogleFonts.montserrat(textStyle:TextStyle(color: Colors.white,fontWeight:FontWeight.w700,fontSize: 20))),
                onPressed:(){
                  openCheckout();
                } 
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EventCreateTextField extends StatelessWidget {

  EventCreateTextField(
      {this.icon,
      this.hint,
      this.obsecure = false,
      this.validator,
      this.controller,
      this.maxLines,
      this.minLines,
      this.onSaved,
      this.radius,
      this.number,
      this.color,
      this.width,
      this.onChanged});

  final TextEditingController controller;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;
  final int maxLines;
  final int minLines;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final bool number;
  final double radius;
  final Color color;
  final double width;

  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      obscureText: obsecure,
      keyboardType: number?TextInputType.number:TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      style: TextStyle(
        fontSize: 20,
        color: AppColors.primary
      ),
      decoration: InputDecoration(
          labelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),
          labelText: hint,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius==null?20:radius),
            borderSide: BorderSide(
              color: color==null?AppColors.primary:color,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius==null?20:radius),
            borderSide: BorderSide(
              color: color==null?AppColors.primary:color,
              width: width==null?1.5:width,
            ),
          ),
          prefixIcon: Padding(
            child: IconTheme(
              data: IconThemeData(color: AppColors.primary),
              child: icon,
            ),
            padding: EdgeInsets.only(left: 25, right: 10),
          )),
    );
  }
}