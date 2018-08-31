// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'repository.dart';

class PullRequest {
  // add PR number to this class 
  final Repository repo;
  final String id;
  final String url;
  final String title;
  final String diffUrl;
  final String author;
  final int number;

  PullRequest(this.id, this.title, String url, this.repo, this.author, this.number)
      : diffUrl = url + '.diff',
        url = url
            .replaceFirst('github.com', 'api.github.com/repos')
            .replaceFirst('/pull/', '/pulls/');

  String toString() => '$title, $id, $url, $repo, $diffUrl, $author, $number';
}
