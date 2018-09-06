import 'dart:async';
import 'package:flutter/material.dart';
import '../github/graphql.dart';
import '../github/issue.dart';
import '../github/timeline.dart';

class IssueTimelineView extends StatefulWidget {
  final Future<List<TimelineItem>> issueTimelineList;
  final Issue issue;

  IssueTimelineView(this.issueTimelineList, this.issue);

  @override
    State<StatefulWidget> createState() {
      return IssueTimelineViewState();
    }
}


class IssueTimelineViewState extends State<IssueTimelineView> {
  String comment;
  TextEditingController _textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    String comment;
    return Scaffold(
        appBar: AppBar(title: Text('${widget.issue.title}')),
        body:
          Column (
            children: <Widget> [
              Flexible(child: FutureBuilder(
                future: widget.issueTimelineList,
                builder: _buildIssueTimelineList
              )),
              Divider(height: 1.0),
              Container(
                child: new Row(
                  children: <Widget>[
                    new Expanded (
                      child: Container(
                      padding: EdgeInsets.only(left: 10.0),
                      child:
                      TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(labelText: "Enter comment here"),
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
                        if (comment != null) {
                          addComment(widget.issue, null, comment);
                        }
                        _textEditingController.clear();
                      },
                    )
                  ], 
              ))
            ]
          )
      );
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
