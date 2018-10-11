import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/graphql.dart';
import '../github/issue.dart';
import '../github/timeline.dart';

class IssueTimelineView extends StatefulWidget {
  final Future<List<TimelineItem>> issueTimelineList;
  final Issue issue;

  IssueTimelineView(this.issueTimelineList, this.issue);

  @override
  State<StatefulWidget> createState() {
    return IssueTimelineViewState(issueTimelineList);
  }
}

class IssueTimelineViewState extends State<IssueTimelineView> {
  Future<List<TimelineItem>> issueTimelineList;
  String comment;

  RefreshController rc = new RefreshController();
  TextEditingController _textEditingController = new TextEditingController();

  IssueTimelineViewState(this.issueTimelineList);

  Widget _createIssueTimelineListWidget(
      BuildContext context, List<TimelineItem> timeline) {
    return SmartRefresher(
        enablePullDown: true,
        onRefresh: _refreshIssueTimelineList,
        controller: rc,
        child: ListView.builder(
          itemCount: timeline.length,
          itemBuilder: (BuildContext context, int idx) {
            if (timeline[idx].runtimeType == IssueComment) {
              IssueComment tmp = timeline[idx];
              return ListTile(
                  leading: Text(tmp.author),
                  // title: Text(tmp.url),
                  title: Text(tmp.body));
            } else if (timeline[idx].runtimeType == Commit) {
              Commit tmp = timeline[idx];
              return ListTile(
                  leading: Text(tmp.author),
                  // title: Text(tmp.url),
                  title: Text(tmp.message));
            } else if (timeline[idx].runtimeType == LabeledEvent) {
              LabeledEvent tmp = timeline[idx];
              return ListTile(
                  leading: Text(tmp.author),
                  // title: Text(tmp.url),
                  title: Text(tmp.labelName));
            }
          },
        ));
  }

  void _refreshIssueTimelineList(bool b) {
    setState(() {
      issueTimelineList = getIssueTimeline(widget.issue);
      //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
      // can look into making this better later on

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(pageBuilder: (BuildContext context,
            Animation<double> animation, Animation<double> secondAnimation) {
          return IssueTimelineView(issueTimelineList, widget.issue);
        }, transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondAnimation, Widget child) {
          return FadeTransition(
              opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
              child: child);
        }),
      );
      b = true;   
      });
  }

  Widget _buildIssueTimelineList(
      BuildContext context, AsyncSnapshot<List<TimelineItem>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createIssueTimelineListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshIssueTimelineList,
              controller: rc,
              child: ListView(
                  children: <Widget>[Text('No timeline for this issue!')]));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    String comment;
    return Scaffold(
        appBar: AppBar(title: Text('${widget.issue.title}')),
        body: Column(children: <Widget>[
          Flexible(
              child: FutureBuilder(
                  future: issueTimelineList, builder: _buildIssueTimelineList)),
          Divider(height: 1.0),
          Container(
              child: new Row(
            children: <Widget>[
              new Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: TextField(
                      controller: _textEditingController,
                      decoration:
                          InputDecoration(labelText: "Enter comment here"),
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
                      onChanged: (String c) {
                        comment = c;
                      },
                      onSubmitted: (String c) {
                        comment = c;
                        if (comment != null) {
                          addComment(widget.issue, null, comment);
                        }
                        _textEditingController.clear();
                      }),
                  width: MediaQuery.of(context).size.width * 5 / 8,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 10,
              ),
              RaisedButton(
                child: Text("Comment"),
                color: Theme.of(context).primaryColorLight,
                onPressed: () {
                  if (comment != null) {
                    addComment(widget.issue, null, comment);
                    // setState(() {
                    //   issueTimelineList = getIssueTimeline(widget.issue);
                    //   //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
                    //   // can look into making this better later on

                    //   Navigator.pushReplacement(
                    //     context,
                    //     PageRouteBuilder(pageBuilder: (BuildContext context,
                    //         Animation<double> animation, Animation<double> secondAnimation) {
                    //       return IssueTimelineView(issueTimelineList, widget.issue);
                    //     }, transitionsBuilder: (BuildContext context, Animation<double> animation,
                    //         Animation<double> secondAnimation, Widget child) {
                    //       return FadeTransition(
                    //           opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
                    //           child: child);
                    //     }),
                    //   );
                    //   });
                  }
                  _textEditingController.clear();
                },
              )
            ],
          ))
        ]));
  }
}

class IssueTimelineList extends StatelessWidget {
  final List<TimelineItem> timeline;

  IssueTimelineList(this.timeline);

  @override
  Widget build(BuildContext context) {
    return;
  }
}
