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
  State<StatefulWidget> createState() =>
      IssueTimelineViewState(issueTimelineList);
}

class IssueTimelineViewState extends State<IssueTimelineView> {
  Future<List<TimelineItem>> issueTimelineList;
  String comment;

  RefreshController rc = RefreshController();
  TextEditingController _textEditingController = TextEditingController();

  IssueTimelineViewState(this.issueTimelineList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.issue.title}')),
      body: Column(children: <Widget>[
        Flexible(
          child: FutureBuilder(
            future: issueTimelineList,
            builder: _buildIssueTimelineList,
          ),
        ),
        Divider(height: 1.0),
        Container(
          child: Row(
            children: <Widget>[
              _buildCommentTextbox(),
              SizedBox(width: MediaQuery.of(context).size.width / 12),
              _buildSubmitCommentButton(),
              Padding(padding: EdgeInsets.only(left: 20.0)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildCommentTextbox() => Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 10.0),
          width: MediaQuery.of(context).size.width * 5 / 8,
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: " Enter comment here",
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            onChanged: (String c) => comment = c,
            onSubmitted: (String c) {
              comment = c;
              if (comment != null) {
                addComment(widget.issue, null, comment).then(
                  (IssueComment comment) {
                    _refreshIssueTimelineList(true);
                  },
                );
              }
              _textEditingController.clear();
            },
          ),
        ),
      );

  Widget _buildSubmitCommentButton() => RaisedButton(
        child: Text("Comment"),
        color: Theme.of(context).primaryColorLight,
        onPressed: () {
          if (comment != null) {
            addComment(widget.issue, null, comment).then(
              (IssueComment comment) {
                _refreshIssueTimelineList(true);
              },
            );
          }
          _textEditingController.clear();
        },
      );

  Widget _buildIssueTimelineList(
    BuildContext context,
    AsyncSnapshot<List<TimelineItem>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createIssueTimelineListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshIssueTimelineList,
              controller: rc,
              child: ListView(
                  children: <Widget>[Text('No timeline for this issue!')]),
            );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Widget _createIssueTimelineListWidget(
    BuildContext context,
    List<TimelineItem> timeline,
  ) {
    return SmartRefresher(
      enablePullDown: true,
      onRefresh: _refreshIssueTimelineList,
      controller: rc,
      child: ListView.builder(
        itemCount: timeline.length,
        itemBuilder: (_, int index) => _buildTimelineItem(timeline[index]),
      ),
    );
  }

  void _refreshIssueTimelineList(bool b) {
    setState(() {
      issueTimelineList = getIssueTimeline(widget.issue);
      //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
      // can look into making this better later on

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondAnimation,
          ) =>
              IssueTimelineView(
                issueTimelineList,
                widget.issue,
              ),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
                child: child,
              ),
        ),
      );
      b = true;
    });
  }

  Widget _buildTimelineItem(TimelineItem timelineItem) {
    switch (timelineItem.runtimeType) {
      case IssueComment:
        IssueComment temp = timelineItem;
        return ListTile(
          leading: Text(temp.author),
          title: Text(temp.body),
        );
      case Commit:
        Commit temp = timelineItem;
        return ListTile(
          leading: Text(temp.author),
          title: Text(temp.message),
        );
      case LabeledEvent:
        LabeledEvent temp = timelineItem;
        return ListTile(
          leading: Text(temp.author),
          title: Text(temp.labelName),
        );
      default:
        return ErrorWidget(Exception("Unknown TimelineItem type"));
    }
  }
}
