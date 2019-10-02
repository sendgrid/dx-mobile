import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/pullrequest.dart';
import '../github/graphql.dart';
import '../github/repository.dart';

import './searchpage.dart';

import '../widgets/issuetile.dart';

class PRListView extends StatefulWidget {
  final Repository repo;
  final Future<List<PullRequest>> prList;

  PRListView(
    this.repo,
    this.prList,
  );

  @override
  State<StatefulWidget> createState() => PRListViewState(prList);
}

class PRListViewState extends State<PRListView> {
  Future<List<PullRequest>> prList;
  RefreshController rc = RefreshController();

  PRListViewState(this.prList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pull Request List'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () async {
                List<dynamic> tempList = await prList;
                Navigator.push(
                  context,
                  PageRouteBuilder(pageBuilder: (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondAnimation,
                  ) {
                    return SearchPage(tempList, null, widget.repo);
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
              },
            )
          ],
        ),
        body: FutureBuilder(future: prList, builder: _buildPRList));
  }

  Widget _buildPRList(
    BuildContext context,
    AsyncSnapshot<List<PullRequest>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createPRListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshPRList,
              controller: rc,
              child: ListView(
                children: <Widget>[Text('No PRs for you!')],
              ),
            );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Widget _createPRListWidget(BuildContext context, List<PullRequest> prs) {
    return SmartRefresher(
      enablePullDown: true,
      onRefresh: _refreshPRList,
      controller: rc,
      child: ListView(
        children: prs
            .map(
                (pullRequest) => Container(child: IssueTile(null, pullRequest)))
            .toList(),
      ),
    );
  }

  void _refreshPRList() {
    prList = getPRs(widget.repo);
    rc.loadComplete();
    //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
    // can look into making this better later on

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondAnimation,
      ) {
        return PRListView(
          widget.repo,
          prList,
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
  }
}
