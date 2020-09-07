import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:international_phone_input/international_phone_input.dart';
import 'package:lottie/lottie.dart';
import 'package:passable_host/HomePage.dart';
import 'package:passable_host/loginui.dart';
import 'package:passable_host/methods/firebaseAdd.dart';
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
  PickResult mainResult;
  GeoFirePoint myLocation ;
  DateTime dateTime;
  Completer<maps.GoogleMapController> _controller = Completer();
  final hostNameController=TextEditingController();
  final hostEmailController=TextEditingController();
  final hostPhoneController=TextEditingController();
  final nameController=TextEditingController();
  final descriptionController=TextEditingController();
  final eventAddController=TextEditingController();
  final maxAttendeeController=TextEditingController();
  final dateTimeController=TextEditingController();
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
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP
        );
      }
      else if(dateTime==null){
        Fluttertoast.showToast(
          msg:'Date and Time is not valid ',
          backgroundColor: Colors.red,
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP
        );
      }
      else if(mainResult==null&&!isOnline){
        Fluttertoast.showToast(
          msg:'Locate the event location',
          backgroundColor: Colors.red,
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP
        );
      }
      else{
      _formKey.currentState.save();
      eventCode=randomAlphaNumeric(6);
      print(eventCode);
      Navigator.push(context, MaterialPageRoute(
        builder:(context){
          return PosterSelect(
            eventName: nameController.text,
            eventDescription:descriptionController.text,
            eventCategory: selectedCategory,
            hostName: hostNameController.text,
            hostEmail: hostEmailController.text,
            hostPhoneNumber: hostPhoneNumber,
            isOnline: isOnline,
            location: myLocation,
            eventAddress: eventAddController.text,
            eventDateTime: dateTime,
            eventCode: eventCode,
          );
        }
      ));
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
        apiKey:  'AIzaSyAJBaI8jdFjekZnRgtJ10DsNVF3RuSfXfc', 
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
Future<Null> _selectDate(BuildContext context) async {
  final DateTime picked = await DatePicker.showDateTimePicker(context,
    showTitleActions: true,
    minTime: DateTime.now(),
    maxTime: DateTime.now().add(new Duration(days: 365))
  );
  if (picked != null && picked != dateTime)
    setState(() {
      dateTime= picked;
      dateTimeController.text = DateFormat('dd-MM-yyyy  hh:mm a').format(dateTime);
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
                            border:Border.all(width: 1.5,color: AppColors.primary),
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
                            border:Border.all(width: 1.5,color: AppColors.primary),
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
                    validator: (value) => value.length<10?'*must be 10 character long':null,
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
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: EventCreateTextField(
                       maxLines:1,
                       number:false,
                       width:0.5,
                       radius: 5,
                       controller: dateTimeController,
                       validator: (value) => null,
                       hint: "Event Date & Time",
                       icon: Icon(FontAwesome.calendar,color:AppColors.secondary,),
                      )
                    ),
                  ),
                ],
              )
            ),
            SizedBox(height:10),
            Divider(thickness:1),
            SizedBox(height:20),
            Align(
              child: Padding(
                padding: const EdgeInsets.only(bottom:15.0),
                child: RaisedButton(
                  onPressed:(){
                    _validateInputs();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue',style: TextStyle(fontSize:22,fontWeight: FontWeight.w900,color: Colors.white,)),
                        SizedBox(width:10),
                        Icon(FontAwesome.arrow_right,color: Colors.white,size:16)
                      ],
                    ),
                  ),
                  color:AppColors.primary,
                   ),
              ),
            )
          ],
        ),
      )     
    );
  }
}

class PosterSelect extends StatefulWidget {
final String eventName;
final String eventDescription;
final String eventCategory;
final String hostName;
final String hostEmail;
final String hostPhoneNumber;
final String eventAddress;
final String eventCode;
final bool isOnline;
final DateTime eventDateTime;
final GeoFirePoint location;
PosterSelect({this.eventName,this.eventDescription,this.eventCategory,this.hostName,this.hostEmail,this.hostPhoneNumber,this.isOnline,this.location,this.eventAddress,this.eventDateTime,this.eventCode});
  @override
  _PosterSelectState createState() => _PosterSelectState();
}

class _PosterSelectState extends State<PosterSelect> {
  @override
  void initState(){
    super.initState();
    print(widget.eventCategory);
    print(widget.eventDateTime);
    print(widget.eventDescription);
    print(widget.eventName);
    print(widget.hostEmail);
    print(widget.hostName);
    print(widget.hostPhoneNumber);
    print(widget.isOnline);
    print(widget.eventAddress);
  }
  File _image;
  final picker = ImagePicker();

    Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height=SizeConfig.getHeight(context);
    double width=SizeConfig.getWidth(context);
    return Scaffold(
      appBar: AppBar(
        title:Text('Add Poster',style: GoogleFonts.cabin(fontWeight:FontWeight.w600,fontSize: 25)),
        centerTitle: true,
      ),
      floatingActionButton: _image!=null?FloatingActionButton(
        child:Icon(Icons.navigate_next,color:Colors.white,size:30),
        backgroundColor: AppColors.secondary,
        splashColor: AppColors.tertiary,
        onPressed: (){
          if(_image== null){
            Fluttertoast.showToast(
              msg:'Select a photo',
              backgroundColor: Colors.red,
              fontSize: 18,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP
            );
          }
          else
            Navigator.push(context, MaterialPageRoute(
              builder: (context){
                return TicketInfo(
                  eventName: widget.eventName,
                  eventDescription: widget.eventDescription,
                  eventCategory: widget.eventCategory,
                  eventAddress: widget.eventAddress,
                  location: widget.location,
                  hostName: widget.hostName,
                  hostEmail: widget.hostEmail,
                  hostPhoneNumber: widget.hostPhoneNumber,
                  eventDateTime: widget.eventDateTime,
                  isOnline: widget.isOnline,
                  image: _image,
                  eventCode: widget.eventCode
                );
              }
            )
          );
        },
      ):Container(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left:width/20,right:width/20,bottom: height/40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget>[
              Padding(
                padding: const EdgeInsets.only(top:20),
                child: Text('Event Poster',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)),
              ),
              Padding(
                padding: const EdgeInsets.only(top:2,bottom:12),
                child: Text(
                  'This is the first image people will see at the top of your listing. Vertical poster is recommended.',
                  style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:16,color: Color(0xff39364f),)),
              ),
              SizedBox(height: 10,),
              _image==null?InkWell(
                onTap: ()=>getImage(),
                child: Container(
                  color: Colors.purple[50].withOpacity(0.7),
                  height: height/2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          Icon(FontAwesome.image,size: 50,),
                          SizedBox(height:15),
                          Text('Select poster image from gallery.',style: GoogleFonts.cabin(fontWeight:FontWeight.w400,fontSize:26,color: Color(0xff1E0A3C),),textAlign:TextAlign.center,),
                          SizedBox(height:10),
                          Text('Vertical image is recommended.',style: GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:22,color: Colors.purple[200]),textAlign:TextAlign.center,),
                        ]
                      ),
                    ),
                  ),
                ),
              ):Center(
                child: InkWell(
                  child: Image.file(_image,height: height/1.5,),
                  onTap: ()=>getImage(),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
}

class TicketInfo extends StatefulWidget {
  final String eventName;
  final String eventDescription;
  final String eventCategory;
  final String hostName;
  final String hostEmail;
  final String hostPhoneNumber;
  final String eventAddress;
  final String eventCode;
  final bool isOnline;
  final DateTime eventDateTime;
  final GeoFirePoint location;
  final File image;
  TicketInfo({this.eventName,this.eventDescription,this.eventCategory,this.hostName,this.hostEmail,this.hostPhoneNumber,this.isOnline,this.location,this.eventAddress,this.eventDateTime,this.eventCode,this.image});
  @override
  _TicketInfoState createState() => _TicketInfoState();
}

class _TicketInfoState extends State<TicketInfo> {
  bool isProtected= false;
  bool isPaid=true;
  double ticketPrice=0;
  int ticketCount=0;
  TextEditingController ticketPriceController=TextEditingController();
  TextEditingController ticketCountController=TextEditingController();
  TextEditingController passcodeController=TextEditingController();
  TextEditingController upiController=TextEditingController();

  onPaidSelect(String x){
    if(x=='yes')
    setState(() {
      isPaid=true;
    });
    else
    setState(() {
      isPaid=false;
      ticketPriceController.clear();
      ticketPrice=0;
    });
    print(isPaid);
  }

  onProtectSelect(String x){
    if(x=='yes')
    setState(() {
      isProtected=true;
    });
    else
    setState(() {
      isProtected=false;
    });
    print(isProtected);
  }

  void validateInputs () async{
    Pattern pattern =r'^[\w\.\-_]{3,}@[a-zA-Z]{3,}';
    RegExp regex = new RegExp(pattern);
    if(ticketCount<=10){
      Fluttertoast.showToast(
        msg:'Ticket count must be greater than 10 ',
        backgroundColor: Colors.red,
        fontSize: 18,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP
      );
    }
    else if(ticketPrice<=20&&isPaid==true){
      Fluttertoast.showToast(
        msg:'Ticket Price must be greater than ₹20 ',
        backgroundColor: Colors.red,
        fontSize: 18,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP
      );   
    }
    else if(!regex.hasMatch(upiController.text)){
        Fluttertoast.showToast(
          msg:'Enter Valid UPI ID',
          backgroundColor: Colors.red,
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP
        ); 
    }
    else if(passcodeController.text.trim().length!=0&&passcodeController.text!=null&&passcodeController.text!=''){
      final x= await Firestore.instance.collection('partners').document(passcodeController.text).get();
      if(!x.exists){
        Fluttertoast.showToast(
          msg:'Invalid partner code added',
          backgroundColor: Colors.red,
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP
        ); 
      }

      else{
        await FirebaseAdd().addEvent(
          widget.eventName,
          widget.eventCode, 
          widget.eventDescription, 
          widget.eventAddress, 
          ticketCount, 
          widget.image, 
          widget.eventDateTime, 
          widget.location, 
          widget.hostName, 
          widget.hostEmail, 
          widget.hostPhoneNumber, 
          widget.eventCategory, 
          widget.isOnline, 
          isPaid, 
          isProtected, 
          ticketPrice, 
          passcodeController.text,
          upiController.text
        );
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return CongoScreen(widget.eventName,widget.eventCode,widget.eventAddress,widget.image,widget.eventDateTime);
        }));
      }
    }
    else{
        await FirebaseAdd().addEvent(
          widget.eventName,
          widget.eventCode, 
          widget.eventDescription, 
          widget.eventAddress, 
          ticketCount, 
          widget.image, 
          widget.eventDateTime, 
          widget.location, 
          widget.hostName, 
          widget.hostEmail, 
          widget.hostPhoneNumber, 
          widget.eventCategory, 
          widget.isOnline, 
          isPaid, 
          isProtected, 
          ticketPrice, 
          null,
          upiController.text
        );
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return CongoScreen(widget.eventName,widget.eventCode,widget.eventAddress,widget.image,widget.eventDateTime);
        }));
    }
  }
  @override
  Widget build(BuildContext context) {
    double height= SizeConfig.getHeight(context);
    double width= SizeConfig.getWidth(context);
    return Scaffold(
      appBar: AppBar(
        title:Text('Ticket Info',style: GoogleFonts.cabin(fontWeight:FontWeight.w600,fontSize: 25)),
        centerTitle: true,
      ),
      body: Container(
        margin:EdgeInsets.symmetric(horizontal: width/20),
        child: ListView(
          children:<Widget>[ 
            Padding(
              padding: const EdgeInsets.only(top:20.0),
              child: Text('Ticket Info',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)),
            ),
            SizedBox(height:8),  
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    onPaidSelect('yes');
                  },
                  child: Container(
                    width: 125,
                    decoration: BoxDecoration( 
                      borderRadius: BorderRadius.circular(10),
                      border:Border.all(width: 1.5,color: AppColors.primary),
                      color: !isPaid?Colors.white:AppColors.tertiary.withOpacity(1),
                    ),
                    child:Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(child: Text('Paid',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),)),
                    ),
                  ),
                ),
                SizedBox(width:20),
                InkWell(
                  onTap: (){
                    onPaidSelect('');
                  },
                  child: Container(
                    width: 125,
                    decoration: BoxDecoration( 
                      borderRadius: BorderRadius.circular(10),
                      border:Border.all(width: 1.5,color: AppColors.primary),
                      color: isPaid?Colors.white:AppColors.tertiary.withOpacity(1),
                    ),   
                    child:Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(child: Text('Free',style:GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height:15),
            isPaid?Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children:<Widget>[
                Container(
                  width: 150,
                  child: TextField(
                    controller: ticketPriceController,
                    style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 16),
                    onChanged: (val){
                      setState(() {
                        if(val.trim().length==0)
                          {
                            ticketPrice=0;
                          }
                        else
                        ticketPrice=double.parse(val);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Ticket Price',
                      labelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.secondary),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(FontAwesome.rupee,color: AppColors.primary)
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Expanded(child: Icon(FontAwesome.times,size: 30,)),
                Container(
                  width: 150,
                  child: TextField(
                    onChanged: (val){
                      setState(() {
                        if(val.trim().length==0)
                          {
                            ticketCount=0;
                          }
                        else
                        ticketCount=int.parse(val);
                            });
                    },
                    controller: ticketCountController,
                    style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Ticket Count',
                      alignLabelWithHint: true,
                      labelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.secondary),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ):
            EventCreateTextField(
              maxLines:1,
              number:true,
              width:0.5,
              radius: 5,
              controller: ticketCountController,
              hint: "Ticket Count",
              icon: Icon(FontAwesome.calculator,color:AppColors.secondary,),
              onChanged: (val){
                setState(() {
                  if(val.trim().length==0)
                    {
                      ticketCount=0;
                    }
                  else
                  ticketCount=int.parse(val);
                });
              }, 
            ),
            isPaid?SizedBox(height:10):Container(),
            isPaid?Padding(
              padding: const EdgeInsets.only(top:20),
              child: Row(
                children: [
                  Text('Gross Earning:',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:26,color: Color(0xff1E0A3C),)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(FontAwesome.rupee,size:25,color: Color(0xff1E0A3C)),
                        SizedBox(width: 5,),
                        Text('${ticketPrice * ticketCount}',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:26,color:AppColors.primary ,))
                      ],
                    ),
                  )
                ],
              ),
            ):Container(),
            isPaid?Text(
              '(Ticket price * Ticket Count)',
                style:GoogleFonts.mavenPro(fontWeight:FontWeight.w600,fontSize:17,color: Color(0xff39364f),)
            ):Container(),
            isPaid?Padding(
              padding: const EdgeInsets.only(top:20),
              child: Row(
                children: [
                  Text('Est. Earning:',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:26,color: Color(0xff1E0A3C))),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(FontAwesome.rupee,size:25,color: Color(0xff1E0A3C)),
                        SizedBox(width: 5,),
                        Text('${(ticketPrice * ticketCount)*92/100}',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:26,color: AppColors.primary,))
                      ],
                    ),
                  )
                ],
              ),
            ):Container(),
            isPaid?Text(
              '(Gross Earning - Passable fees 8%)',
                style:GoogleFonts.mavenPro(fontWeight:FontWeight.w600,fontSize:17,color: Color(0xff39364f),)
            ):Container(),
            isPaid?SizedBox(height:5):Container(),
            isPaid?Text(
              '*This is the amount you will get in 24 hours after event completion',
              style:GoogleFonts.cabin(fontWeight:FontWeight.w600,fontSize:18,color: Colors.red,)
            ):Container(),
            isPaid?SizedBox(height:20):Container(),
            SizedBox(height:10),
            Divider(thickness:1),
            SizedBox(height:8),
            Text('Event Protection',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)),
            Padding(
              padding: const EdgeInsets.only(top:2,bottom:12),
              child: Text(
                'Yes : Only People with code can buy or redeem passes of this event.\nNo: Anyone can buy passes of this event aisa krde',
                style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:15,color: Color(0xff39364f),)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    onProtectSelect('yes');
                  },
                  child: Container(
                    width: 125,
                    decoration: BoxDecoration( 
                      borderRadius: BorderRadius.circular(10),
                      border:Border.all(width: 1.5,color: AppColors.primary),
                      color: !isProtected?Colors.white:AppColors.tertiary.withOpacity(1),
                    ),
                    
                    child:Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(child: Text('Yes',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary),)),
                    ),
                  ),
                ),
                SizedBox(width:20),
                InkWell(
                  onTap: (){
                    onProtectSelect('');
                  },
                  child: Container(
                    width: 125,
                    decoration: BoxDecoration( 
                      borderRadius: BorderRadius.circular(10),
                      border:Border.all(width: 1.5,color: AppColors.primary),
                      color: isProtected?Colors.white:AppColors.tertiary.withOpacity(1),
                    ),   
                    child:Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(child: Text('No',style:GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,color: AppColors.primary))),
                    ),
                  ),
                ), 
              ],
            ),
            isPaid?SizedBox(height:10):Container(),
            isPaid?Divider(thickness:1):Container(),
            isPaid?SizedBox(height:8):Container(),
            isPaid?Text('Partner code',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)):Container(),
            isPaid?Padding(
              padding: const EdgeInsets.only(top:2,bottom:12),
              child: Text(
                'If you are referred by one of our Partners, please mention his/her code.',
                style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:15,color: Color(0xff39364f),)),
            ):Container(),
            isPaid?EventCreateTextField(
              maxLines:1,
              number:false,
              width:0.5,
              radius: 5,
              controller: passcodeController,
              hint: "Enter code here",
              icon: Icon(FontAwesome.keyboard_o,color:AppColors.secondary,),
              onChanged: (val){
              }, 
            ):Container(),
            isPaid?SizedBox(height:10):Container(),
            isPaid?Divider(thickness:1):Container(),
            isPaid?SizedBox(height:8):Container(),
            isPaid?Text('Payment details',style: GoogleFonts.cabin(fontWeight:FontWeight.w800,fontSize:34,color: Color(0xff1E0A3C),)):Container(),
            isPaid?Padding(
              padding: const EdgeInsets.only(top:2,bottom:12),
              child: Text(
                'Enter your UPI ID for receiving the payment.Payment will be transferred within 24 hrs after event completion.For any other payment method contact your personal helper which will be assigned after event creation',
                style:GoogleFonts.mavenPro(fontWeight:FontWeight.w500,fontSize:15,color: Color(0xff39364f),)),
            ):Container(),
            isPaid?EventCreateTextField(
              maxLines:1,
              number:false,
              width:0.5,
              radius: 5,
              controller: upiController,
              hint: "Enter UPI ID",
              icon: Icon(FontAwesome.keyboard_o,color:AppColors.secondary,),
              onChanged: (val){
              }, 
            ):Container(),
            SizedBox(height:10),
            Divider(thickness:1),
            SizedBox(height:8),
            Align(
              child: Padding(
                padding: const EdgeInsets.only(bottom:15.0),
                child: RaisedButton(
                  onPressed:(){
                    validateInputs();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Create event',style: TextStyle(fontSize:22,fontWeight: FontWeight.w900,color: Colors.white,)),
                        SizedBox(width:10),
                        Icon(FontAwesome.arrow_right,color: Colors.white,size:16)
                      ],
                    ),
                  ),
                  color:AppColors.primary,
                   ),
              ),
            ),
            SizedBox(height:10)
          ],
        ),
      ),
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
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){return HomePage();}), ModalRoute.withName('/homepage'));
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
                            linkUrl: 'https://passable.in',
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