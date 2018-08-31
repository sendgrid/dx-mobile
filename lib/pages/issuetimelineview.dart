import 'dart:async';
import 'package:flutter/material.dart';
import '../github/issue.dart';
import '../github/timeline.dart';

class IssueTimelineView extends StatelessWidget {
  final Future<List<TimelineItem>> issueTimelineList;
  final Issue issue;

  IssueTimelineView(this.issueTimelineList, this.issue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('${issue.title}')),
        body: FutureBuilder(
            future: issueTimelineList, builder: _buildIssueTimelineList));
  }

  Widget _buildIssueTimelineList(
      BuildContext context, AsyncSnapshot<List<TimelineItem>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? IssueTimelineList(snapshot.data)
          : Center(child: Text('No timeline for this issue!'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class IssueTimelineList extends StatelessWidget {
  final List<TimelineItem> timeline;

  IssueTimelineList(this.timeline);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.timeline.length,
      itemBuilder: (BuildContext context, int idx) {
        if (timeline[idx].runtimeType == IssueComment) {
          IssueComment tmp = timeline[idx];
          return ListTile(
            leading: Text(tmp.author),
            title: Text(tmp.url),
            subtitle: Text(tmp.body)
          );
        }
        else if (timeline[idx].runtimeType == Commit) {
          Commit tmp = timeline[idx];
          return ListTile(
            leading: Text(tmp.author),
            title: Text(tmp.url),
            subtitle: Text(tmp.message)
          );
        }
        else if (timeline[idx].runtimeType == LabeledEvent) {
          LabeledEvent tmp = timeline[idx];
          return ListTile(
            leading: Text(tmp.author),
            title: Text(tmp.url),
            subtitle: Text(tmp.labelName)
          );
        }
      },
    );
  }
}
