import 'package:flutter/material.dart';

import 'package:dx_mobile/github/pullrequest.dart';
import 'package:dx_mobile/github/issue.dart';
import 'package:dx_mobile/github/label.dart';
import 'package:dx_mobile/github/repository.dart';

import 'package:dx_mobile/pages/searchresults.dart';

import 'package:dx_mobile/widgets/dialogbox.dart';
import 'package:dx_mobile/widgets/issuetile.dart';

class SearchPage extends StatefulWidget {
  final List<PullRequest> prList;
  final List<Issue> issueList;
  final Repository repo;

  SearchPage(this.prList, this.issueList, this.repo);

  @override
  State<StatefulWidget> createState() {
    return SearchPageState(prList, issueList, repo);
  }
}

class SearchPageState extends State<SearchPage> {
  List<PullRequest> prList;
  List<Issue> issueList;
  Repository repo;
  List searchLabels = [];
  String hintText, query;
  ListView results;

  SearchPageState(this.prList, this.issueList, this.repo) {
    if (prList == null) {
      hintText = "Search issues...";
    } else {
      hintText = "Search pull requests...";
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white)),
          style: TextStyle(color: Colors.white),
          onFieldSubmitted: (String s) {
            query = s;
            searchLabels =
                []; // right now, only allowing either filter or search at a time
            results = getSearchResults(query, searchLabels);
            transitionToResults();
          },
          controller: controller,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              query = '';
              searchLabels = [];
            },
          ),
          IconButton(
              tooltip: "Filter",
              icon: const Icon(Icons.label),
              onPressed: () async {
                // List<dynamic> tempList = await prList;
                query = '';
                _getLabelSearch(context);
              })
        ],
      ),
      body: Stack(),
    );
  }

  void _getLabelSearch(BuildContext context) async {
    final items = <MultiSelectDialogItem<int>>[];
    List<Label> labels = repo.labels;
    for (int i = 0; i < labels.length; i++) {
      items.add(MultiSelectDialogItem(i + 1, labels[i]));
    }

    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
            // edit the code to render it as a bunch of labels
            items: items);
      },
    );

    List<String> labelIds = [];
    if (selectedValues != null) {
      for (int i = 0; i < items.length; i++) {
        if (selectedValues.contains(items[i].value)) {
          labelIds.add(items[i].label.id);
        }
      }
    }

    searchLabels = labelIds;
    results = getSearchResults(query, searchLabels);
    transitionToResults();
  }

  Widget getSearchResults(String query, List searchLabels) {
    List<Widget> results = [];
    if (prList == null) {
      for (int i = 0; i < issueList.length; i++) {
        if (issueList[i].runtimeType == Issue) {
          Issue issue = issueList[i];
          if (query != '' &&
                  issue.title.toLowerCase().contains(query.toLowerCase()) ||
              issue.number == int.tryParse(query)) {
            results.add(IssueTile(issue, null));
          }

          if (issue.labels.length != 0) {
            for (int j = 0; j < issue.labels.length; j++) {
              if (searchLabels.contains(issue.labels[j].id)) {
                results.add(IssueTile(issue, null));
              }
            }
          }
        }
      }
    } else {
      for (int i = 0; i < prList.length; i++) {
        if (prList[i].runtimeType == PullRequest) {
          PullRequest pr = prList[i];
          if (query != '' &&
                  pr.title.toLowerCase().contains(query.toLowerCase()) ||
              pr.number == int.tryParse(query)) {
            results.add(IssueTile(null, pr));
          }

          if (pr.labels.length != 0) {
            for (int j = 0; j < pr.labels.length; j++) {
              if (searchLabels.contains(pr.labels[j].id)) {
                results.add(IssueTile(null, pr));
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

  void transitionToResults() {
    Navigator.push(
      context,
      PageRouteBuilder(pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondAnimation,
      ) {
        return SearchResultsPage(results, widget.repo, query);
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
  }
}
