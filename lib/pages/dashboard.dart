import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/pullrequest.dart';
import '../github/graphql.dart' as graphql;
import '../github/user.dart';
import '../github/issue.dart';

import '../pages/prlistview.dart';
import '../pages/issuelistview.dart';

class Dashboard extends StatefulWidget {
  final String owner;
  final String repoName;
  final Future<List<PullRequest>> prList;
  final Future<List<Issue>> issueList;
  final Future<int> branches;
  final Future<int> releases;

  Dashboard(
    this.owner,
    this.repoName,
    this.prList,
    this.issueList,
    this.branches,
    this.releases,
  );

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<PullRequest>> prList;
  Future<List<Issue>> issueList;
  Future<int> branches;
  Future<int> releases;

  RefreshController rc = RefreshController();

  @override
  void initState() {
    prList = graphql.getPRs(widget.owner, widget.repoName);
    issueList = graphql.getIssues(widget.owner, widget.repoName);
    branches = graphql.getBranches(widget.owner, widget.repoName);
    releases = graphql.getReleases(widget.owner, widget.repoName);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    prList = widget.prList;
    issueList = widget.issueList;
    branches = widget.branches;
    releases = widget.releases;

    return Scaffold(
      appBar: _buildAppBar(),
      body: SmartRefresher(
        enablePullDown: true,
        onRefresh: _refreshDashboard,
        controller: rc,
        child: StaggeredGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            _buildUserAvatar(),
            _buildReleasesTile(),
            _buildPullRequestsTile(),
            _buildIssuesTile(),
            _buildBranchesTile(),
          ],
          staggeredTiles: [
            StaggeredTile.extent(2, 180.0),
            StaggeredTile.extent(2, 110.0),
            StaggeredTile.extent(1, 180.0),
            StaggeredTile.extent(1, 180.0),
            StaggeredTile.extent(2, 110.0),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: Text(
          widget.repoName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 30.0,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      );

  Widget _buildUserAvatar() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder(
          future:
              graphql.currentUser(), // User whose auth token is in token.dart
          builder: _buildUser,
        ),
      ),
    );
  }

  Widget _buildReleasesTile() {
    return _buildTile(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Releases', style: TextStyle(color: Colors.blueAccent)),
                FutureBuilder(
                  future: releases,
                  builder: _buildFutureIntText,
                ),
              ],
            ),
            Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(24.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.label_outline,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPullRequestsTile() {
    return _buildTile(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PRListView(
                    widget.owner,
                    widget.repoName,
                    prList,
                  ),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: Colors.teal,
              shape: CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  const IconData(0xe801, fontFamily: 'GitIcons'), // PR Icon
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 16.0)),
            FutureBuilder(
              future: _getLength(prList),
              builder: _buildPRText,
            ),
            Text(
              'Pull Requests',
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesTile() {
    return _buildTile(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IssueListView(
                    widget.owner,
                    widget.repoName,
                    widget.issueList,
                  ),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: Colors.red,
              shape: CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 16.0)),
            FutureBuilder(
              future: _getLength(issueList),
              builder: _buildIssueText,
            ),
            Text('Issues', style: TextStyle(color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesTile() {
    return _buildTile(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Branches',
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
                FutureBuilder(
                  future: branches,
                  builder: _buildFutureIntText,
                ),
              ],
            ),
            Material(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(24.0),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    const IconData(0xe800, fontFamily: 'GitIcons'),
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({@required Widget child, Function() onTap}) {
    assert(child != null);
    return Material(
      elevation: 14.0,
      borderRadius: BorderRadius.circular(12.0),
      shadowColor: Color(0x802196F3),
      child: InkWell(
        child: child,
        // Do onTap() if it isn't null, otherwise do print()
        onTap: onTap != null
            ? () => onTap()
            : () => print('Not set yet'),
      ),
    );
  }

  Widget _buildUser(BuildContext context, AsyncSnapshot<User> snapshot) {
    if (snapshot.connectionState == ConnectionState.done)
      return UserBanner(snapshot.data);
    else
      return CircularProgressIndicator();
  }

  Widget _buildPRText(BuildContext context, AsyncSnapshot<int> snapshot) {
    return Text(
      "${snapshot.data}",
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 24.0,
      ),
    );
  }

  Widget _buildIssueText(BuildContext context, AsyncSnapshot<int> snapshot) {
    return Text(
      "${snapshot.data}",
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 24.0,
      ),
    );
  }

  //gets length of future list (consider putting into a util file)
  Future<int> _getLength(Future<List<dynamic>> futureList) async {
    // initial length of PR/Issue list
    List<dynamic> list = await futureList;
    return list.length;
  }

  Widget _buildFutureIntText(
      BuildContext context, AsyncSnapshot<int> snapshot) {
    return Text(
      "${snapshot.data}",
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 34.0,
      ),
    );
  }

  void _refreshDashboard(bool b) {
    setState(() {
      prList = graphql.getPRs(widget.owner, widget.repoName);
      issueList = graphql.getIssues(widget.owner, widget.repoName);
      branches = graphql.getBranches(widget.owner, widget.repoName);
      releases = graphql.getReleases(widget.owner, widget.repoName);

      rc.sendBack(true, RefreshStatus.completed);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondAnimation,
          ) =>
              Dashboard(
                widget.owner,
                widget.repoName,
                prList,
                issueList,
                branches,
                releases,
              ),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: Tween(begin: 0.0, end: 10.0).animate(animation),
                child: child,
              ),
        ),
      );
    });

    b = true;
  }
}

/// Displays the user's login and avatar
class UserBanner extends StatelessWidget {
  final User user;
  UserBanner(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl),
          radius: 50.0,
        ),
        Text(
          user.login,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }
}
