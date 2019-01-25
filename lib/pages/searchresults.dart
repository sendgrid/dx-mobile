import 'package:flutter/material.dart';

import 'package:dx_mobile/github/repository.dart';

class SearchResultsPage extends StatefulWidget {
  final ListView results;
  final Repository repo;
  final dynamic query;

  SearchResultsPage(this.results, this.repo, this.query);
  @override
  State<StatefulWidget> createState() {
    return SearchResultsPageState(results, repo, query);
  }
}

class SearchResultsPageState extends State<SearchResultsPage> {
  final ListView results;
  final Repository repo;
  final dynamic query;

  SearchResultsPageState(this.results, this.repo, this.query);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search results")),
      body: results,
    );
  }
}
