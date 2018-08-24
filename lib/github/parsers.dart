// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Set of hand-crafted JSON parsers for GraphQL responses

import 'dart:convert';
import 'pullrequest.dart';
import 'issue.dart';
import 'repository.dart';
import 'user.dart';

/// Parses a Github GraphQL user response
User parseUser(String resBody) {
  final jsonRes = json.decode(resBody)['data'];
  final userJson = jsonRes['viewer'] ?? jsonRes['user'];
  return User(userJson['login'], userJson['name'], userJson['avatarUrl']);
}

/// Parses a Gtihub GraphQL pull request reviews response
List<PullRequest> parseOpenPullRequestReviews(String resBody) {
  List jsonRes = json.decode(resBody)['data']['search']['edges'];
  return jsonRes.map((edge) {
    final node = edge['node'];
    final repoName = node['repository']['name'];
    final repoUrl = node['repository']['url'];
    final repoStarCount = node['repository']['stargazers']['totalCount'];
    final repo = Repository(repoName, repoUrl, repoStarCount);

    final prId = node['id'];
    final prTitle = node['title'];
    final prUrl = node['url'];
    final pr = PullRequest(prId, prTitle, prUrl, repo, '');

    return pr;
  }).toList();
}

List<PullRequest> parsePullRequests(String resBody) {
  List jsonRes = json.decode(resBody)['data']['organization']['repository']['pullRequests']['nodes'];
  // print('json');
  // print(jsonRes.toString());

  Map repoInfo = json.decode(resBody)['data']['organization']['repository'];
  Repository repo = Repository(repoInfo['name'], repoInfo['url'], repoInfo['stargazers']['totalCount']);

  List<PullRequest> prs = [];
  for (var i = 0; i < jsonRes.length; i++){
    prs.add(PullRequest(jsonRes[i]['id'], jsonRes[i]['title'], jsonRes[i]['url'], 
    repo, jsonRes[i]['author']['login']));
  }

  return prs;

}

List<Issue> parseIssues(String resBody) {
  List jsonRes = json.decode(resBody)['data']['organization']['repository']['issues']['nodes'];

  Map repoInfo = json.decode(resBody)['data']['organization']['repository'];
  Repository repo = Repository(repoInfo['name'], repoInfo['url'], repoInfo['stargazers']['totalCount']);

  List<Issue> issues = [];
  for (var i = 0; i < jsonRes.length; i++){
    issues.add(Issue(jsonRes[i]['title'], jsonRes[i]['id'], jsonRes[i]['url'], 
    repo, jsonRes[i]['author']['login'], jsonRes[i]['state']));
  }
  print (issues.toString());
  return issues;
}