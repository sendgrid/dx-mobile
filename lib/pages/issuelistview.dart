import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../pages/issuetimelineview.dart';
import '../github/timeline.dart';
import '../github/graphql.dart';
import '../github/issue.dart';

class IssueListView extends StatefulWidget {
  final String owner;
  final String repoName;
  final Future<List<Issue>> issueList;

  IssueListView(this.owner, this.repoName, this.issueList);

  @override
  State<StatefulWidget> createState() {
    return IssueListViewState(issueList);
  }
}

class IssueListViewState extends State<IssueListView> {
  Future<List<Issue>> issueList;
  RefreshController rc = new RefreshController();

  IssueListViewState(this.issueList);

  Widget _createIssueListWidget(BuildContext context, List<Issue> issues) {
    return SmartRefresher(
        enablePullDown: true,
        onRefresh: _refreshIssueList,
        controller: rc,
        child: ListView(
          children: issues
              .map((issue) => Container(
                      child: ListTile(
                    title: Text("${issue.title} #${issue.number}"),
                    subtitle: Text(issue.author),
                    onTap: () {
                      Future<List<TimelineItem>> timelines =
                          getIssueTimeline(issue);
                      // display them
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IssueTimelineView(timelines, issue),
                          ));
                    },
                  )))
              .toList(),
        ));
  }

  void _refreshIssueList(bool b) {
    issueList = getIssues(widget.owner, widget.repoName);
    //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
    // can look into making this better later on

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(pageBuilder: (BuildContext context,
          Animation<double> animation, Animation<double> secondAnimation) {
        return IssueListView(widget.owner, widget.repoName, issueList);
      }, transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondAnimation, Widget child) {
        return FadeTransition(
            opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
            child: child);
      }),
    );
    b = true;
  }

  Widget _buildIssueList(
      BuildContext context, AsyncSnapshot<List<Issue>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createIssueListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshIssueList,
              controller: rc,
              child: ListView(
                children: <Widget>[Text('No issues for you!')],
              ));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Issue List'),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: FutureBuilder(future: issueList, builder: _buildIssueList));
  }
}
