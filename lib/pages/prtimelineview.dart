import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/graphql.dart';
import '../github/pullrequest.dart';
import '../github/timeline.dart';

class PRTimelineView extends StatefulWidget {
  final Future<List<TimelineItem>> prTimelineList;
  final PullRequest pr;

  PRTimelineView(this.prTimelineList, this.pr);

  @override
  State<StatefulWidget> createState() {
    return PRTimelineViewState(prTimelineList);
  }
}

class PRTimelineViewState extends State<PRTimelineView> {
  Future<List<TimelineItem>> prTimelineList;
  String comment;

  RefreshController rc = new RefreshController();
  TextEditingController _textEditingController = new TextEditingController();

  PRTimelineViewState(this.prTimelineList);

  Widget _createPRTimelineListWidget(
      BuildContext context, List<TimelineItem> timeline) {
    return SmartRefresher(
        enablePullDown: true,
        onRefresh: _refreshPRTimelineList,
        controller: rc,
        child: ListView.builder(
            itemCount: timeline.length,
            itemBuilder: (BuildContext context, int idx) {
              if (timeline[idx].runtimeType == IssueComment) {
                IssueComment tmp = timeline[idx];
                return ListTile(
                  leading: Text(tmp.author),
                  //title: Text(tmp.url),
                  title: Text(tmp.body),
                );
              } else if (timeline[idx].runtimeType == Commit) {
                Commit tmp = timeline[idx];
                return ListTile(
                    leading: Text(tmp.author),
                    //title: Text(tmp.url),
                    title: Text(tmp.message));
              } else if (timeline[idx].runtimeType == LabeledEvent) {
                LabeledEvent tmp = timeline[idx];
                return ListTile(
                    leading: Text(tmp.author),
                    //title: Text(tmp.url),
                    title: Text(tmp.labelName));
              }
            }));
  }

  void _refreshPRTimelineList(bool b) {
    prTimelineList = getPRTimeline(widget.pr);
    //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
    // can look into making this better later on

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(pageBuilder: (BuildContext context,
          Animation<double> animation, Animation<double> secondAnimation) {
        return PRTimelineView(prTimelineList, widget.pr);
      }, transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondAnimation, Widget child) {
        return FadeTransition(
            opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
            child: child);
      }),
    );
    b = true;
  }

  Widget _buildPRTimelineList(
      BuildContext context, AsyncSnapshot<List<TimelineItem>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createPRTimelineListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshPRTimelineList,
              controller: rc,
              child: ListView(
                children: <Widget>[Text('No timeline for this PR!')],
              ));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('${widget.pr.title}')),
        body: Column(children: <Widget>[
          Flexible(
              child: FutureBuilder(
                  future: prTimelineList, builder: _buildPRTimelineList)),
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
                          addComment(null, widget.pr, comment).then(
                            (IssueComment comment) {
                                _refreshPRTimelineList(true);
                            }
                          );
                          _refreshPRTimelineList(true);
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
                    addComment(null, widget.pr, comment).then(
                      (IssueComment comment) {
                          _refreshPRTimelineList(true);
                      }
                    );
                  }
                  _textEditingController.clear();
                },
              )
            ],
          ))
        ]));
  }
}
