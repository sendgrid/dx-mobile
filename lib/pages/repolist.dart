import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/graphql.dart';
import '../github/repository.dart';

import 'dashboard.dart';

class RepoListView extends StatefulWidget {
  final Future<List<Repository>> repoList;

  RepoListView(this.repoList);

  @override
  State<StatefulWidget> createState() => RepoListViewState(repoList);
}

class RepoListViewState extends State<RepoListView> {
  Future<List<Repository>> repoList;
  RefreshController rc = RefreshController();

  RepoListViewState(this.repoList);

  Widget _createRepoListWidget(BuildContext context, List<Repository> repos) {
    return SmartRefresher(
        enablePullDown: true,
        onRefresh: _refreshRepoList,
        controller: rc,
        child: ListView(
          children: repos
              .map((repo) => Container(
                    child: ListTile(
                      title: Text("${repo.name}"),
                      subtitle: Text("${repo.nameWithOwner}"),
                      onTap: () {
                        String owner = repo.nameWithOwner.split("/")[0];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Dashboard(
                                  owner,
                                  repo.name,
                                  getPRs(owner, repo.name),
                                  getIssues(owner, repo.name),
                                  getBranches(owner, repo.name),
                                  getReleases(owner, repo.name))),
                        );
                      },
                      // TODO: Add a trailing widget indicating star count of
                      // the repo. Something like-
                      // trailing: StarWidget(pullRequest.repo.starCount),
                    ),
                  ))
              .toList(),
        ));
  }

  void _refreshRepoList(bool b) {
    repoList = fetchUserRepos();
    //rc.sendBack(true, RefreshStatus.completed); // makes it break, but works without.
    // can look into making this better later on

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondAnimation,
        ) {
          return RepoListView(repoList);
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondAnimation,
          Widget child,
        ) {
          return FadeTransition(
              opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
              child: child);
        },
      ),
    );
    b = true;
  }

  Widget _buildRepoList(
    BuildContext context,
    AsyncSnapshot<List<Repository>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? _createRepoListWidget(context, snapshot.data)
          : SmartRefresher(
              enablePullDown: true,
              onRefresh: _refreshRepoList,
              controller: rc,
              child: ListView(
                children: <Widget>[Text('You have no repositories!')],
              ),
            );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your Repositories')),
        body: FutureBuilder(future: repoList, builder: _buildRepoList));
  }
}
