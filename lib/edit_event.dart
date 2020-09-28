import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/config.dart';
class EditPage extends StatefulWidget {
  final DocumentSnapshot post;
  EditPage(this.post);
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<EditPage>
    with SingleTickerProviderStateMixin {
  
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String selectedCategory;
  List<DropdownMenuItem> categoryList=[
    DropdownMenuItem(
      child: Text('Appearance/Singing',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Appearance/Singing',
    ),
    DropdownMenuItem(
      child: Text('Attaraction',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Attaraction',
    ),
    DropdownMenuItem(
      child: Text('Camp, Trip or Retreat',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Camp, Trip or Retreat',
    ),
    DropdownMenuItem(
      child: Text('Class, Training, or Workshop',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Class, Training, or Workshop',
    ),
    DropdownMenuItem(
      child: Text('Concert/Performance',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Concert/Performance',
    ),
    DropdownMenuItem(
      child: Text('Conference',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Conference',
    ),
    DropdownMenuItem(
      child: Text('Convention',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Convention',
    ),
    DropdownMenuItem(
      child: Text('Dinner or Gala',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Dinner or Gala',
    ),
    DropdownMenuItem(
      child: Text('Festival or Fair',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Festival or Fair',
    ),
    DropdownMenuItem(
      child: Text('Game or Competition',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Game or Competition',
    ),
    DropdownMenuItem(
      child: Text('Meeting/Networking event',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Meeting/Networking event',
    ),
    DropdownMenuItem(
      child: Text('Party/Social Gathering',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Party/Social Gathering',
    ),
    DropdownMenuItem(
      child: Text('Other',style: GoogleFonts.cabin(fontWeight: FontWeight.w800, fontSize: 20,),),
      value: 'Other',
    ),
  ];
  void _validateInputs(){
    if(_formKey.currentState.validate())
      {
        _formKey.currentState.save();
      }
    else{
      setState(() {
        _autoValidate = true;
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final hostNameController=TextEditingController(text: widget.post.data['hostName']);
    final hostEmailController=TextEditingController(text: widget.post.data['hostEmail']);
    final hostPhoneController=TextEditingController(text: widget.post.data['hostPhoneNumber']);
    final nameController=TextEditingController(text: widget.post.data['eventName']);
    final descriptionController=TextEditingController(text: widget.post.data['eventDescription']);
    final eventAddController=TextEditingController(text: widget.post.data['eventAddress']);
    final maxAttendeeController=TextEditingController(text: widget.post.data['maxAttendee'].toString());
    return new Scaffold(
      appBar: AppBar(title: Text("Edit Event"),),
      body: new Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(
              children: <Widget>[
                new Container(
                  height: 250.0,
                  color: Colors.white,
                  child: new Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: new Stack(fit: StackFit.loose, children: <Widget>[
                          new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                  width: 170.0,
                                  height: 170.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      image: new NetworkImage(
                                          widget.post.data['eventBanner']),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 90.0, right: 100.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 25.0,
                                    child: new Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )),
                        ]),
                      )
                    ],
                  ),
                ),
                new Container(
                  color: Color(0xffFFFFFF),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Edit information',
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    _status ? _getEditIcon() : new Container(),
                                  ],
                                )
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Event Name',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextFormField(
                                    controller: nameController,
                                    validator: (value) => value.length<2?'*must be 2 character long':null,
                                    decoration: InputDecoration(
                                      hintText: 'Event Name',
                                    ),
                                    enabled: !_status,
                                    autofocus: !_status,
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Description',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextFormField(
                                    maxLines: 3,
                                    validator: (value) => value.length<2?'*must be 2 character long':null,
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                        hintText: 'event Description'
                                      ),
                                    enabled: !_status,
                                  ),
                                ),
                              ],
                            )),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 12.0),
                              child: DropdownButtonFormField(   
                                items: categoryList,
                                validator: (value)=>selectedCategory==null?'Select a category':null,
                                value: widget.post.data["eventCategory"],
                                decoration: InputDecoration(
                                    enabled: !_status,
                                    labelStyle: GoogleFonts.cabin(fontWeight: FontWeight.w600, fontSize: 18,color: Colors.black),
                                    labelText: 'Category of the event',
                                ),
                                onChanged: (value){
                                  selectedCategory=value;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 30.0),
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    'Host Information',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Host Name',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextFormField(
                                    validator: (value) => value.trim().length>0?null:'Enter a valid name',
                                    controller: hostNameController,
                                    decoration: new InputDecoration(
                                        hintText: 'Host Name'),
                                    enabled: !_status,
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: new Text(
                                      'Phone Number',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    child: new Text(
                                      'Email',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: new TextFormField(
                                      controller: hostPhoneController,
                                      keyboardType: TextInputType.number,
                                      validator: (val){
                                        Pattern pattern =
                                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                        RegExp regex = new RegExp(pattern);
                                        if (!regex.hasMatch(val))
                                          return 'Enter Valid Phone Number';
                                        else
                                          return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: "Host PhoneNumber"),
                                      enabled: !_status,
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Flexible(
                                  child: new TextField(
                                    controller: hostEmailController,
                                    decoration: const InputDecoration(
                                        hintText: "Enter Host Email",
                                        ),
                                    enabled: !_status,
                                  ),
                                  flex: 2,
                                ),
                              ],
                            )),
                        !_status ? _getActionButtons() : new Container(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 20.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 20.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}