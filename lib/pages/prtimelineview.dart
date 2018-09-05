import 'dart:async';
import 'package:flutter/material.dart';
import '../github/graphql.dart';
import '../github/pullrequest.dart';
import '../github/timeline.dart';

class PRTimelineView extends StatelessWidget {
  final Future<List<TimelineItem>> prTimelineList;
  final PullRequest pr;

  PRTimelineView(this.prTimelineList, this.pr);

  @override
  Widget build(BuildContext context) {
    String comment;
    return Scaffold(
        appBar: AppBar(title: Text('${pr.title}')),
        body:
            FutureBuilder(
            future: prTimelineList, builder: _buildPRTimelineList),      
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Theme.of(context).primaryColorDark,
        //   child: Icon(Icons.add_comment),
        //   foregroundColor: Colors.white,
        //   elevation: 5.0,
        //   onPressed: () {
        //       showBottomSheet(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return Column(
        //             children: <Widget>[
        //               TextField(
        //                 decoration: InputDecoration(labelText: "Enter comment here"),
        //                 keyboardType: TextInputType.multiline,
        //               )
        //             ],
        //           );
        //         });
        //   },
        // ),
        bottomNavigationBar: BottomAppBar(
          child: new Row(
            children: <Widget>[
              new Expanded (
                child: Container(
                padding: EdgeInsets.only(left: 10.0),
                child:
                TextField(
                  decoration: InputDecoration(labelText: "Enter comment here"),
                  keyboardType: TextInputType.multiline,
                  onChanged: (String c) {
                    comment = c;
                  },
                  onSubmitted: (String c) {
                    comment = c;
                  }
                ),
                width: MediaQuery.of(context).size.width*5/8,
              ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width/10,
              ),
              RaisedButton(
                child: Text("Comment"),
                color: Theme.of(context).primaryColorLight,
                onPressed: () {
                  addComment(null, pr, comment);
                },
              )
            ],
          )
        ),
        );
  }

  Widget _buildPRTimelineList(
      BuildContext context, AsyncSnapshot<List<TimelineItem>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? PRTimelineList(snapshot.data, this.pr)
          : Center(child: Text('No timeline for this PR!'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class PRTimelineList extends StatelessWidget {
  final List<TimelineItem> timeline;
  final PullRequest pr;

  PRTimelineList(this.timeline, this.pr);

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
              subtitle: Text(tmp.body),
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
        });
  }
}
