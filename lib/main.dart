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

class MyApp extends StatelessWidget {
  final Future<List<PullRequest>> prList = graphql.getPRs("sendgrid","sendgrid-go");
  final Future<List<Issue>> issueList = graphql.getIssues("sendgrid","sendgrid-go");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DXGo!",
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        accentColor: Colors.black45
      ),
      home: Dashboard(),
      routes: {
        '/prs': (BuildContext context) => PRListView(prList),
        '/issues': (BuildContext context) => IssueListView(issueList)
      }
    );
  }
}