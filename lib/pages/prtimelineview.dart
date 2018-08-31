import 'dart:async';
import 'package:flutter/material.dart';
import '../github/pullrequest.dart';
import '../github/timeline.dart';

class PRTimelineView extends StatelessWidget {
  final Future<List<TimelineItem>> prTimelineList;
  final PullRequest pr;

  PRTimelineView(this.prTimelineList, this.pr);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('${pr.title}')),
        body: FutureBuilder(
            future: prTimelineList, builder: _buildPRTimelineList));
  }

  Widget _buildPRTimelineList(
      BuildContext context, AsyncSnapshot<List<TimelineItem>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? PRTimelineList(snapshot.data)
          : Center(child: Text('No timeline for this PR!'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class PRTimelineList extends StatelessWidget {
  final List<TimelineItem> timeline;

  PRTimelineList(this.timeline);

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
