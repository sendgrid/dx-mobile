import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../pages/issuetimelineview.dart';
import '../github/timeline.dart';
import '../github/graphql.dart';
import '../github/issue.dart';
import '../github/repository.dart';

import '../widgets/issuetile.dart';

class IssueListView extends StatefulWidget {
  final Repository repo;
  final Future<List<Issue>> issueList;

  IssueListView(this.repo, this.issueList);

  @override
  State<StatefulWidget> createState() => IssueListViewState(issueList);
}

class IssueListViewState extends State<IssueListView> {
  Future<List<Issue>> issueList;
  RefreshController rc = RefreshController();

  IssueListViewState(this.issueList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder(future: issueList, builder: _buildIssueList),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: Text('Issue List'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              print("searching");
              List<dynamic> tempList = await issueList;
              final selected = await showSearch(
                context: context,
                delegate: IssueSearchDelegate(context, tempList)
              );
            },
          ),
        ],
      );

  Widget _buildIssueList(
    BuildContext context,
    AsyncSnapshot<List<Issue>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createIssueListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshIssueList,
              controller: rc,
              child: ListView(
                children: <Widget>[Text('No issues for you!')],
              ),
            );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  void _refreshIssueList(bool b) {
    issueList = getIssues(widget.repo);
    //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
    // can look into making this better later on

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondAnimation,
      ) {
        return IssueListView(
          widget.repo,
          issueList,
        );
      }, transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondAnimation,
        Widget child,
      ) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
          child: child,
        );
      }),
    );

    b = true;
  }

  Widget _createIssueListWidget(BuildContext context, List<Issue> issues) {
    return SmartRefresher(
      enablePullDown: true,
      onRefresh: _refreshIssueList,
      controller: rc,
      child: ListView(
        children: issues
            .map(
              (issue) => Container(
              child: IssueTile(issue, null)
            ))
            .toList(),
      ),
    );
  }
}

class IssueSearchDelegate extends SearchDelegate {
  List<dynamic> issues;
  IssueSearchDelegate(BuildContext context, this.issues);

  @override
    List<Widget> buildActions(BuildContext context) {
      return [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      ];
    }

  @override
    Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
    }

  @override
    Widget buildResults(BuildContext context) {
      List<Widget> results = [];
      for (int i = 0; i < issues.length; i++) {
        if (issues[i].runtimeType == Issue){
          Issue issue = issues[i];
          print(issue.title);
          if (issue.title.toLowerCase().contains(query.toLowerCase()) || issue.number == int.tryParse(query)){
            results.add(IssueTile(issue, null));
          }
        }
      }
      print(results);
      return ListView(
        children: results,
      );
    }

  @override
    Widget buildSuggestions(BuildContext context) {
      return Column();
    }
      
}