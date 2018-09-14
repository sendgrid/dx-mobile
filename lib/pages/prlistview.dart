import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/pullrequest.dart';
import '../github/timeline.dart';
import '../github/graphql.dart';
import './prtimelineview.dart';

class PRListView extends StatefulWidget {
  final String owner;
  final String repoName;
  final Future<List<PullRequest>> prList;

  PRListView(this.owner, this.repoName, this.prList);
  @override
  State<StatefulWidget> createState() {
    return PRListViewState(prList);
  }
}

class PRListViewState extends State<PRListView> {
  Future<List<PullRequest>> prList;
  RefreshController rc = new RefreshController();

  PRListViewState(this.prList);

  Widget _createPRListWidget(BuildContext context, List<PullRequest> prs) {
    return SmartRefresher(
        enablePullDown: true,
        onRefresh: _refreshPRList,
        controller: rc,
        child: ListView(
          children: prs
              .map((pullRequest) => Container(
                      child: ListTile(
                    title: Text("${pullRequest.title} #${pullRequest.number}"),
                    subtitle: Text("${pullRequest.author}"),
                    onTap: () {
                      // call query that displays page with the PR's info
                      Future<List<TimelineItem>> timelines =
                          getPRTimeline(pullRequest);
                      // display them
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PRTimelineView(timelines, pullRequest),
                          ));
                    },
                    //trailing: StarWidget(pullRequest.repo.starCount),
                  )))
              .toList(),
        ));
  }

  void _refreshPRList(bool b) {
    prList = getPRs(widget.owner, widget.repoName);
    //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
    // can look into making this better later on

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(pageBuilder: (BuildContext context,
          Animation<double> animation, Animation<double> secondAnimation) {
        return PRListView(widget.owner, widget.repoName, prList);
      }, transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondAnimation, Widget child) {
        return FadeTransition(
            opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
            child: child);
      }),
    );
    b = true;
  }

  Widget _buildPRList(
      BuildContext context, AsyncSnapshot<List<PullRequest>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createPRListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshPRList,
              controller: rc,
              child: ListView(
                children: <Widget>[Text('No PRs for you!')],
              ));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Pull Request List'),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: FutureBuilder(future: prList, builder: _buildPRList));
  }
}
