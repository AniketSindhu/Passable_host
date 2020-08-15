import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:passable_host/config/config.dart';
import 'package:passable_host/HomePage.dart';
import 'package:passable_host/Methods/getUserId.dart';
import 'package:passable_host/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widgets/clipper.dart';
import 'config/size.dart';
import 'Methods/firebaseAdd.dart';
import 'userInfo.dart';

class OTP extends StatefulWidget {
  OTP(this.phone);
  final String phone;
  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  
String actualCode,status;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    phoneSignin();
  }
  void onAuthenticationSuccessful(AuthResult result) async {    
    String uid = await getCurrentUid();
    final x = await Firestore.instance.collection('users').document(uid).get();
    
    if(x.exists)
      {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('login', true);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), ModalRoute.withName('login'));
      }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return UserInfoPage(widget.phone,null,null,false);}));
    }  
  }
  void _signInWithPhoneNumber(String smsCode) async {
    AuthCredential auth = PhoneAuthProvider.getCredential(
      verificationId: actualCode, smsCode: smsCode);
      _auth.signInWithCredential(auth).catchError((error) {
        setState(() {
           status = 'Wrong code entered or Something went wrong!';
         });
         print(status);
       }).then((user) async {
         if(user!=null){
         setState(() {
           status = 'Authentication successful';
         });
      onAuthenticationSuccessful(user);
        }});
  }
      
      void phoneSignin() async{
        final PhoneCodeSent codeSent =
            (String verificationId, [int forceResendingToken]) async {
          this.actualCode = verificationId;
          setState(() {
            print('Code sent to $widget.phone');
            status = "\nEnter the code sent to " + widget.phone;
          });
        };
      
        final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
            (String verificationId) {
          this.actualCode = verificationId;
          setState(() {
            status = "\nAuto retrieval time out";
          });
        };
      
        final PhoneVerificationFailed verificationFailed =
           (AuthException authException) {
          setState(() {
            status = '${authException.message}';
            print("Error message: " + status);
            if (authException.message.contains('not authorized'))
              status = 'Something has gone wrong, please try later';
            else if (authException.message.contains('Network'))
              status = 'Please check your internet connection and try again';
            else
              status = 'Something has gone wrong, please try later';
          });
        };
      
        final PhoneVerificationCompleted verificationCompleted =
            (AuthCredential auth) {
         setState(() {
           status = 'Auto retrieving verification code';
          });
          _auth
            .signInWithCredential(auth)
            .then((AuthResult value) {
              if (value.user != null) {
                setState(() {
                  status = 'Authentication successful';
                });
                onAuthenticationSuccessful(value);
              } else {
               setState(() {
                 status = 'Invalid code/invalid authentication';
               });
             }
            }).catchError((error) {
              setState(() {
               status = 'Something has gone wrong, please try later';
            });
            });
           };
            await _auth.verifyPhoneNumber(
              phoneNumber: widget.phone,
              timeout: Duration(seconds: 60),
              verificationCompleted: verificationCompleted,
              verificationFailed: verificationFailed,
              codeSent: codeSent,
              codeAutoRetrievalTimeout: null);
          }
        @override
        Widget build(BuildContext context) {
          double height=SizeConfig.getHeight(context);
          double width=SizeConfig.getWidth(context);
              return Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  children:<Widget>[
                    SizedBox(height:height/20,),
                    Center(
                         child:Text("Verification",style: GoogleFonts.lora(textStyle:TextStyle(color: AppColors.primary,fontSize: 35,fontWeight: FontWeight.w700))),
                      ),
                    SizedBox(height:20),
                    Expanded(child: Center(
                      child:status==null?
                      CircularProgressIndicator(backgroundColor: AppColors.secondary,):
                      Text("$status",style: GoogleFonts.lora(textStyle:TextStyle(color:AppColors.secondary,fontSize:25,fontWeight:FontWeight.w600)),textAlign: TextAlign.center,))),
                    Expanded(
                      child: OTPTextField(
                        length: 6,
                        width: MediaQuery.of(context).size.width,
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold
                        ),
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldStyle: FieldStyle.underline,
                        onCompleted: (pin) {
                          setState(() {
                            _signInWithPhoneNumber(pin);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Align(
                        child: ClipPath(
                          child: Container(
                            color: AppColors.tertiary,
                            height: 300,
                          ),
                          clipper: BottomWaveClipper(),
                        ),
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ]
                )
              );
        }
      }
