import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'github/graphql.dart' as graphql;
import 'github/user.dart';
import 'github/pullrequest.dart';
import 'github/issue.dart';

import 'review_code.dart';
import 'pages/dashboard.dart';
import 'pages/prlistview.dart';
import 'pages/issuelistview.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
    State<StatefulWidget> createState() {
      return MyAppState();
    }
}
class MyAppState extends State<MyApp> {
  //hard code for now
  String owner = "sendgrid";
  String repoName = "sendgrid-go";


  @override
  Widget build(BuildContext context) {
    Future<List<PullRequest>> prList = graphql.getPRs(owner, repoName);
    Future<List<Issue>> issueList = graphql.getIssues(owner, repoName);
    return MaterialApp(
      title: "DXGo!",
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        accentColor: Colors.black45
      ),
      home: Dashboard(owner, repoName, prList, issueList),
      routes: {
        // probably can't have routes here besides login and home dashboard
        // because you need to update the PRList yourself
        // '/prs': (BuildContext context) => PRListView(owner, repoName, PRList),
        // '/issues': (BuildContext context) => IssueListView(owner, repoName, IssueList)
      }
    );
  }
}

