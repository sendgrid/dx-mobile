import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../github/pullrequest.dart';
import '../github/graphql.dart' as graphql;
import '../github/user.dart';
import '../github/issue.dart';

import '../pages/prlistview.dart';
import '../pages/issuelistview.dart';

class Dashboard extends StatefulWidget {
  final String owner;
  final String repoName;
  final Future<List<PullRequest>> prList;
  final Future<List<Issue>> issueList;

  Dashboard(this.owner, this.repoName, this.prList, this.issueList);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white,
          title: Text('DXGo!',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0)),
        ),
        body: StaggeredGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: FutureBuilder(
                        future: graphql
                            .currentUser(), // grabs user whose auth token is in token.dart
                        builder: _buildUser))),
            _buildTile(
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
                          Text('Releases',
                              style: TextStyle(color: Colors.blueAccent)),
                          Text('25',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 34.0))
                        ],
                      ),
                      Material(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(24.0),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(Icons.timeline,
                                color: Colors.white, size: 30.0),
                          )))
                    ]),
              ),
            ),
            _buildTile(
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Material(
                            color: Colors.teal,
                            shape: CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.settings_applications,
                                  color: Colors.white, size: 30.0),
                            )),
                        FutureBuilder(
                            future: _getLength(widget
                                .prList), // grabs user whose auth token is in token.dart
                            builder: _buildPRText)
                      ]),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PRListView(
                              widget.owner, widget.repoName, widget.prList)));
                }
            ),
            _buildTile(
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: <Widget> [
                            SizedBox(width: 55.0,),
                            Material(
                              color: Colors.amber,
                              shape: CircleBorder(),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Icon(Icons.notifications,
                                    color: Colors.white, size: 30.0),
                            ))]),
                        FutureBuilder(
                            future: _getLength(widget
                                .issueList), // grabs user whose auth token is in token.dart
                            builder: _buildIssueText)
                      ]),
                ), onTap: () {
                            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IssueListView(
                          widget.owner, widget.repoName, widget.issueList)));
            }),
            _buildTile(
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
                          Text('Branches',
                              style: TextStyle(color: Colors.redAccent)),
                          Text('25',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 34.0))
                        ],
                      ),
                      Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(24.0),
                          child: Center(
                              child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(Icons.store,
                                color: Colors.white, size: 30.0),
                          )))
                    ]),
              ),
              onTap: () {},
            )
          ],
          staggeredTiles: [
            StaggeredTile.extent(2, 180.0),
            StaggeredTile.extent(2, 110.0),
            StaggeredTile.extent(1, 180.0),
            StaggeredTile.extent(1, 180.0),
            StaggeredTile.extent(2, 110.0),
          ],
        ));
  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Color(0x802196F3),
        child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null
                ? () => onTap()
                : () {
                    print('Not set yet');
                  },
            child: child));
  }

  Widget _buildUser(BuildContext context, AsyncSnapshot<User> snapshot) {
    if (snapshot.connectionState == ConnectionState.done)
      return UserBanner(snapshot.data);
    else
      return CircularProgressIndicator();
  }

  Widget _buildPRText(BuildContext context, AsyncSnapshot<int> snapshot) {
    return Column(children: <Widget>[
      Padding(padding: EdgeInsets.only(bottom: 16.0)),
      Row(children: <Widget>[
        Text("${snapshot.data}",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 24.0))
      ]),
      Row(children: <Widget>[
        Text('Pull Requests', style: TextStyle(color: Colors.black45)),
      ]),
    ]);
  }

  Widget _buildIssueText(BuildContext context, AsyncSnapshot<int> snapshot) {
    return Column(children: <Widget>[
      Padding(padding: EdgeInsets.only(bottom: 16.0)),
      Row(children: <Widget>[
        SizedBox(width: 85.0),
        Text("${snapshot.data}",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 24.0))
      ]),
      Row(children: <Widget>[
        SizedBox(width: 75.0),
        Text('Issues', style: TextStyle(color: Colors.black45)),
      ]),
    ]);
  }

  //gets length of future list (consider putting into a util file)
  Future<int> _getLength(Future<List<dynamic>> futureList) async {
    // initial length of PR/Issue list
    List<dynamic> list = await futureList;
    return list.length;
  }
}

// Displays the user's login and avatar
class UserBanner extends StatelessWidget {
  final User user;
  UserBanner(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl), radius: 50.0),
      Text(
        user.login,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
      ),
    ]);
  }
}
