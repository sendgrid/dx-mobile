import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/graphql.dart';
import '../github/pullrequest.dart';
import '../github/timeline.dart';
import '../github/label.dart';

import '../common/timeline_widgets.dart';

import '../widgets/issuetile.dart';
import '../widgets/dialogbox.dart';

class PRTimelineView extends StatefulWidget {
  final Future<List<TimelineItem>> prTimelineList;
  final PullRequest pr;

  PRTimelineView(this.prTimelineList, this.pr);

  @override
  State<StatefulWidget> createState() => PRTimelineViewState(prTimelineList);
}

class PRTimelineViewState extends State<PRTimelineView> {
  Future<List<TimelineItem>> prTimelineList;
  String comment;

  RefreshController rc = RefreshController();
  TextEditingController _textEditingController = TextEditingController();

  PRTimelineViewState(this.prTimelineList);

  Widget _createPRTimelineListWidget(
      BuildContext context, List<TimelineItem> timeline) {
    return SmartRefresher(
      enablePullDown: true,
      onRefresh: _refreshPRTimelineList,
      controller: rc,
      child: ListView.builder(
        itemCount: timeline.length,
        itemBuilder: (_, int index) => buildTimelineItem(timeline[index]),
      ),
    );
  }

  void _refreshPRTimelineList(bool b) {
    prTimelineList = getPRTimeline(widget.pr);
    //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
    // can look into making this better later on

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondAnimation,
        ) {
          return PRTimelineView(prTimelineList, widget.pr);
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondAnimation,
          Widget child,
        ) {
          return FadeTransition(
              opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
              child: child);
        },
      ),
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
              ),
            );
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
            future: prTimelineList,
            builder: _buildPRTimelineList,
          ),
        ),
        Divider(height: 1.0),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: <Widget>[
        //     FloatingActionButton(
        //       child: Text("Add Label", textAlign: TextAlign.center,),
        //       backgroundColor: Colors.blueGrey,
        //     ),
        //   ],
        // ),
        Container(
          child: Row(
            children: <Widget>[
              buildCommentTextbox(
                context: context,
                textEditingController: _textEditingController,
                onChanged: (String c) => comment = c,
                onSubmitted: (String c) {
                  comment = c;
                  addCommentToPR();
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 15,
              ),
              buildSubmitCommentButton(
                context: context,
                onPressed: addCommentToPR,
              ),
            ],
          ),
        )
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

  void addCommentToPR() {
    if (comment != null) {
      addComment(null, widget.pr, comment).then(
        (IssueComment comment) {
          _refreshPRTimelineList(true);
        },
      );
      _refreshPRTimelineList(true);
    }
    _textEditingController.clear();
  }

  void addLabelToPR() {

  }

  void _showMultiSelect(BuildContext context) async {
    final items = <MultiSelectDialogItem<int>>[];
    List<Label> labels = widget.pr.repo.labels;
    for (int i = 0; i < labels.length; i++){
      items.add(MultiSelectDialogItem(i + 1, labels[i]));
    }
    print("pr labels");
    print(labels);

    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog( // edit the code to render it as a bunch of labels
          items: items
        );
      },
    );

    // print(selectedValues);
    List<String> labelIds = [];
    if (selectedValues != null) {
      for (int i = 0; i < items.length; i++){
        if (selectedValues.contains(items[i].value)){
          labelIds.add(items[i].label.id);
        }
      }
      // print(labelIds);
      addLabel(null, widget.pr, labelIds).then(
      (List labels) {
        _refreshPRTimelineList(true);
      });
    }
  }
}