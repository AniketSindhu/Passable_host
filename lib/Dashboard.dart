import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passable_host/config/config.dart';
import 'package:passable_host/lists.dart';

class Dashboard extends StatefulWidget {
  bool isTeam;
  DocumentSnapshot post;
  Dashboard(this.isTeam,this.post);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12.0),
            shadowColor: AppColors.secondary,
            child:InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){return PassesAlotted(widget.post.data['eventCode']);}));
              },
              child:
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Joined Guests', style: TextStyle(color: AppColors.primary)),
                          Text('${NumberFormat.compact().format(widget.post.data['joined'])} / ${NumberFormat.compact().format(widget.post.data['maxAttendee'])}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0))
                        ],
                      ),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24.0),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(Icons.people, color: Colors.white, size: 30.0),
                          )
                        )
                      )
                    ]
                  ),
                ),
            ),
          ),
          SizedBox(height:10), 
          Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12.0),
            shadowColor: AppColors.secondary,
            child:InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){return ScannedList(widget.post.data['eventCode']);}));
              },
              child:
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Scanned Passes', style: TextStyle(color: AppColors.primary)),
                          StreamBuilder<DocumentSnapshot>(
                            stream: Firestore.instance.collection('events').document(widget.post.data['eventCode']).snapshots(),
                            builder: (context, snapshot) {
                              if(snapshot.connectionState==ConnectionState.waiting)
                                return Text('Loading..', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0));
                              else
                              return Text('${NumberFormat.compact().format(snapshot.data['scanDone'])}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0));
                            }
                          )
                        ],
                      ),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24.0),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(Icons.confirmation_number, color: Colors.white, size: 30.0),
                          )
                        )
                      )
                    ]
                  ),
                ),
            ),
          ),
        ],
      ),
      
    );
  }
}