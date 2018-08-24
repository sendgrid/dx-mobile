import 'dart:async';
import 'package:flutter/material.dart';

import '../github/issue.dart';

class IssueListView extends StatelessWidget {
  final Future<List<Issue>> issueList;
  
  IssueListView(this.issueList);
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue List')),
      body: FutureBuilder(
        future: issueList, 
        builder: _buildIssueList
      )
    );
  }

  Widget _buildIssueList (BuildContext context, AsyncSnapshot<List<Issue>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
        ? IssueList(snapshot.data)
        : Center(child: Text('No PRs for you!'));
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
          .map((issue) => ListTile(
                title: Text(issue.title),
                subtitle: Text(issue.author),
                onTap: () {
                  
                },
              ))
          .toList(),
    );
  }
}