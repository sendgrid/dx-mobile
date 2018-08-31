import 'dart:async';
import 'package:flutter/material.dart';

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
    return IssueListViewState();
  }
}

class IssueListViewState extends State<IssueListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Issue List')),
        body:
            FutureBuilder(future: widget.issueList, builder: _buildIssueList));
  }

  Widget _buildIssueList(
      BuildContext context, AsyncSnapshot<List<Issue>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? IssueList(snapshot.data)
          : Center(child: Text('No issues for you!'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class IssueList extends StatelessWidget {
  final List<Issue> issues;

  IssueList(this.issues);

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }
}
