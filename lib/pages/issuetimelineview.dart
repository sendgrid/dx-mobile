import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/graphql.dart';
import '../github/issue.dart';
import '../github/timeline.dart';
import '../github/label.dart';

import '../common/timeline_widgets.dart';

import '../widgets/dialogbox.dart';
import '../widgets/issuetile.dart';

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
              buildCommentTextbox(
                context: context,
                textEditingController: _textEditingController,
                onChanged: (String c) => comment = c,
                onSubmitted: (String c) {
                  comment = c;
                  addCommentToIssue();
                },
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 12),
              buildSubmitCommentButton(
                context: context,
                onPressed: addCommentToIssue,
              ),
              Padding(padding: EdgeInsets.only(left: 20.0)),
            ],
          ),
        ),
      ]),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: Row(
          children: <Widget>[
            buildAddLabelButton(
              context: context,
              onPressed: (){
                _showMultiSelect(context);
              }
            )
          ],
        )
      ),
    );
  }

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
        itemBuilder: (_, int index) => buildTimelineItem(timeline[index]),
      ),
    );
  }

  void _refreshIssueTimelineList() {
    setState(() {
      issueTimelineList = getIssueTimeline(widget.issue);
      rc.loadComplete();
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
    });
  }

  void addCommentToIssue() {
    if (comment != null) {
      addComment(widget.issue, null, comment).then(
        (IssueComment comment) {
          _refreshIssueTimelineList();
        },
      );
    }
    _textEditingController.clear();
  }

  void _showMultiSelect(BuildContext context) async {
    final items = <MultiSelectDialogItem<int>>[];
    List<Label> labels = widget.issue.repo.labels;
    for (int i = 0; i < labels.length; i++){
      items.add(MultiSelectDialogItem(i + 1, labels[i]));
    }
    print("issue labels");
    print(labels);

    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog( // edit the code to render it as a bunch of labels
          items: items
        );
      },
    );

    print(selectedValues);
    List<String> labelIds = [];
    if (selectedValues != null) {
      for (int i = 0; i < items.length; i++){
        if (selectedValues.contains(items[i].value)){
          labelIds.add("\"" + items[i].label.id + "\”");
        }
      }
      // print(labelIds);
      addLabel(widget.issue, null, labelIds).then(
      (List labels) {
        _refreshIssueTimelineList();
      });
    }

  }
}
