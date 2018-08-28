import 'dart:async';
import 'package:flutter/material.dart';

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
    return PRListViewState();
  }
}

class PRListViewState extends State<PRListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Pull Request List')),
        body: FutureBuilder(future: widget.prList, builder: _buildPRList));
  }

// TO-DO later on: pull-down refresh should update PR list and also send it back to dashboard. or
// do it in dashboard and update it again, might need to do some research to see which is better
  _refreshPRList() async {
    // have to add any new PRs one by one
    // call getPRs
    List<PullRequest> newPRs = await getPRs(widget.owner, widget.repoName);
  }

  Widget _buildPRList(
      BuildContext context, AsyncSnapshot<List<PullRequest>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? PRList(snapshot.data)
          : Center(child: Text('No PRs for you!'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class PRList extends StatelessWidget {
  final List<PullRequest> prs;

  PRList(this.prs);

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }
}
