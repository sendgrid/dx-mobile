import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../github/graphql.dart' as graphql;
import '../github/user.dart';

class RepoList extends StatelessWidget {
  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: ListView(
          children: <Widget>[
            Text("Repositories here")
          ],
        )
      );
    }
}
