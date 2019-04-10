import 'dart:async';
import 'package:flutter/material.dart';

import '../github/graphql.dart';
import '../github/user.dart';
import '../github/token.dart';

import 'dashboard.dart';
import 'repolist.dart';
import 'loginpage.dart';

// displays user icon, username, and a button to the repo list page
class UserPage extends StatefulWidget {
  
  UserPage();

  @override
  State<StatefulWidget> createState() => UserPageState();
}

class UserPageState extends State<UserPage> {

  Widget _buildUser(BuildContext context, AsyncSnapshot<User> snapshot) {
    if (snapshot.connectionState == ConnectionState.done)
      return UserBanner(snapshot.data);
    else
      return CircularProgressIndicator();
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: ListView(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FutureBuilder(
                  future:
                      currentUser(), // User whose auth token is in token.dart
                  builder: _buildUser,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)
                ),
                onPressed: () {
                  // go to repo list page
                  Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => RepoListView(fetchUserRepos()),
                  ));
                },
                color: Theme.of(context).primaryColorDark,
                child: Text('View repos', style: TextStyle(color: Colors.white))
              )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)
                ),
                onPressed: () {
                  // go to login page
                  token = "";
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => new LoginPage()));
                },
                color: Theme.of(context).primaryColorDark,
                child: Text('Log out', style: TextStyle(color: Colors.white))
              )
            ),
          ]
        )
      );
    }
}