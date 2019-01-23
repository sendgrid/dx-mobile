import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../pages/issuetimelineview.dart';
import '../github/timeline.dart';
import '../github/graphql.dart';
import '../github/issue.dart';
import '../github/repository.dart';
import '../github/label.dart';

import '../widgets/issuetile.dart';
import '../widgets/dialogbox.dart';

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
              List<dynamic> tempList = await issueList;
              final selected = await showSearch(
                context: context,
                delegate: IssueSearchDelegate(context, tempList, widget.repo)
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
  Repository repo;
  dynamic searchLabels = [];
  IssueSearchDelegate(BuildContext context, this.issues, this.repo);

  @override
    List<Widget> buildActions(BuildContext context) {
      return [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            searchLabels = [];
          },
        ),
        IconButton(
          tooltip: "Filter",
          icon: const Icon(Icons.label),
          onPressed: () async {
            query = '';
            _getLabelSearch(context);
          }
        )
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
      if (query != '' && searchLabels.length == 0){
        for (int i = 0; i < issues.length; i++) {
          if (issues[i].runtimeType == Issue){
            Issue issue = issues[i];
            if (issue.title.toLowerCase().contains(query.toLowerCase()) || issue.number == int.tryParse(query)){
              results.add(IssueTile(issue, null));
            }
          }
        }
      }
      else {
        for (int i = 0; i < issues.length; i++) {
          if (issues[i].runtimeType == Issue){
            Issue issue = issues[i];
            if (issue.labels.length != 0){
              for (int j = 0; j < issue.labels.length; j++) {
                if (searchLabels.contains(issue.labels[j].id)) {
                  print('found');
                  results.add(IssueTile(issue, null));
                }
              }
            }
          }
        }
      }
      
      return ListView(
        children: results,
      );
    }

  @override
    Widget buildSuggestions(BuildContext context) {
      return Column();
    }

    void _getLabelSearch(BuildContext context) async {
      final items = <MultiSelectDialogItem<int>>[];
      List<Label> labels = repo.labels;
      for (int i = 0; i < labels.length; i++){
        items.add(MultiSelectDialogItem(i + 1, labels[i]));
      }

      final selectedValues = await showDialog<Set<int>>(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog( // edit the code to render it as a bunch of labels
            items: items
          );
        },
      );

      List<String> labelIds = [];
      if (selectedValues != null) {
        for (int i = 0; i < items.length; i++){
          if (selectedValues.contains(items[i].value)){
            labelIds.add(items[i].label.id);
          }
        }
      }
      
      searchLabels = labelIds;
      buildResults(context);

    }
      
}