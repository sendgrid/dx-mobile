import 'dart:async';
import 'package:flutter/material.dart';

import '../github/pullrequest.dart';

class PRListView extends StatelessWidget {
  final Future<List<PullRequest>> prList;
  
  PRListView(this.prList);
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Pull Request List')),
      body: FutureBuilder(
        future: prList, 
        builder: _buildPRList
      )
    );
  }

  Widget _buildPRList (BuildContext context, AsyncSnapshot<List<PullRequest>> snapshot) {
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
          .map((pullRequest) => ListTile(
                title: Text(pullRequest.title),
                subtitle: Text(pullRequest.author),
                onTap: () {
                  
                },
                //trailing: StarWidget(pullRequest.repo.starCount),
              ))
          .toList(),
    );
  }
}