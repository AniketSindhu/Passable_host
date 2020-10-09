import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passable_host/Widgets/colorCard.dart';
import 'package:passable_host/config/config.dart';
import 'package:passable_host/lists.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
    double div=widget.post.data['joined']/widget.post.data['maxAttendee']*100;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 13.0,
              animation: true,
              percent: widget.post.data['joined']/widget.post.data['maxAttendee'],
              center: new Text(
                '${div.toStringAsFixed(2)} %',
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              footer: new Text(
                "Passes sold",
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.amber
            ),
            SizedBox(height:10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                colorCard("Gross Earnings", widget.post.data['amountEarned'], 1, context, Color(0xFF1b5bff)),
                colorCard("Net Earnings", widget.post.data['amountEarned']*92/100, 1, context, Color(0xFFff3f5e)),
              ],
            ),
            SizedBox(height:20),
            Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(12.0),
              shadowColor: AppColors.secondary,
              child:InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){return PassesAlotted(widget.post.data['eventCode'],widget.post.data['isOnline'],widget.post.data['ticketPrice']);}));
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
                            Text('${NumberFormat.compact().format(widget.post.data['joined'])}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0))
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
                  Navigator.push(context, MaterialPageRoute(builder: (context){return ScannedList(widget.post.data['eventCode'],widget.post.data['isOnline']);}));
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
                              stream: widget.post.data['isOnline']?Firestore.instance.collection('OnlineEvents').document(widget.post.data['eventCode']).snapshots() :Firestore.instance.collection('events').document(widget.post.data['eventCode']).snapshots(),
                              builder: (context, snapshot) {
                                if(snapshot.connectionState==ConnectionState.waiting)
                                  return Text('Loading..', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0));
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
            SizedBox(height:20),
          ],
        ),
      ),
      
    );
  }
}