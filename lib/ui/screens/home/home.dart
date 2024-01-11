import 'package:flutter/material.dart';
import 'package:fit_now/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fit_now/models/user.dart';

class MainScreen extends StatefulWidget {
  final auth.User firebaseUser;

  MainScreen({required this.firebaseUser});

  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print(widget.firebaseUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 0.5,
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        title: Text("Home"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                _logOut();
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: Auth.getUser(widget.firebaseUser.uid),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(212, 20, 15, 1.0),
                ),
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 100.0,
                    width: 100.0,
                    child: CircleAvatar(
                      backgroundImage: (snapshot.data.profilePictureURL != '')
                          ? NetworkImage(snapshot.data.profilePictureURL)
                          : AssetImage("assets/images/default.png"),
                    ),
                  ),
                  Text("Name: ${snapshot.data.firstName}"),
                  Text("Email: ${snapshot.data.email}"),
                  Text("UID: ${snapshot.data.userID}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _logOut() async {
    Auth.signOut();
  }
}
