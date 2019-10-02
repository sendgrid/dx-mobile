// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. (https://github.com/efortuna/dwmpr/blob/master/LICENSE)

/// Set of hand-crafted JSON parsers for GraphQL responses

import 'dart:convert';
import 'pullrequest.dart';
import 'issue.dart';
import 'repository.dart';
import 'timeline.dart';
import 'user.dart';
import 'label.dart';

/// Parses a Github GraphQL user response
User parseUser(Map<String,dynamic> jsonRes) {
  final userJson = jsonRes['viewer'] ?? jsonRes['user'];
  return User(userJson['login'], userJson['name'], userJson['avatarUrl']);
}

/// Parses a Github GraphQL pull request reviews response
/// NOT USED
// List<PullRequest> parseOpenPullRequestReviews(String resBody) {
//   List jsonRes = json.decode(resBody)['data']['search']['edges'];
//   return jsonRes.map((edge) {
//     final node = edge['node'];
//     final orgName = node['organization']['login'];
//     final repoName = node['repository']['name'];
//     final repoUrl = node['repository']['url'];
//     final repoStarCount = node['repository']['stargazers']['totalCount'];
//     final repo = Repository(repoName, repoUrl, orgName, repoStarCount);

//     final prId = node['id'];
//     final prTitle = node['title'];
//     final prUrl = node['url'];
//     final pr = PullRequest(prId, prTitle, prUrl, repo, '', 0);

//     return pr;
//   }).toList();
// }

// -------------------------------------------------------------------------------------
// NON CHROMIUM AUTHOR CODE BELOW (the code below is under MIT license)

// parseBranches parses the result from the GraphQL query for fetching the # of branches
int parseBranches(Map<String,dynamic> resBody) {
  int jsonRes =
      resBody['repository']['refs']['totalCount'];
  return jsonRes;
}

// parseReleases parses the result from the GraphQL query for fetching the # of releases
int parseReleases(Map<String,dynamic> resBody) {
  int jsonRes =
      resBody['repository']['refs']['totalCount'];
  return jsonRes;
}

// parsePullRequests parses the result from the GraphQL query for fetching the PRs for a repo
List<PullRequest> parsePullRequests(
    Map<String,dynamic> resBody, Repository repo) {
  List jsonRes = resBody['search']['edges'];


  List<PullRequest> prs = [];
  for (var i = 0; i < jsonRes.length; i++) {
    try {
      List<Label> labels = [];
      if (jsonRes[i]['node']['labels']['nodes'].length != 0) {
        for (var j = 0; j < jsonRes[i]['node']['labels']['nodes'].length; j++) {
          var id = jsonRes[i]['node']['labels']['nodes'][j]['id'];
          id = id.substring(0, id.length - 1);
          labels.add(Label(jsonRes[i]['node']['labels']['nodes'][j]['name'],
              jsonRes[i]['node']['labels']['nodes'][j]['color'],
              id));
        }
      }

      prs.add(PullRequest(
          jsonRes[i]['node']['id'],
          jsonRes[i]['node']['title'],
          jsonRes[i]['node']['url'],
          repo,
          jsonRes[i]['node']['author']['login'],
          jsonRes[i]['node']['number'],
          labels));
    } catch (e) {
      if (e == NoSuchMethodError) {
        List<Label> labels = [];
        if (jsonRes[i]['node']['labels']['nodes'].length != 0) {
          for (var j = 0;
              j < jsonRes[i]['node']['labels']['nodes'].length;
              j++) {
            var id = jsonRes[i]['node']['labels']['nodes'][j]['id'];
            id = id.substring(0, id.length - 1);
            labels.add(Label(jsonRes[i]['node']['labels']['nodes'][j]['name'],
                jsonRes[i]['node']['labels']['nodes'][j]['color'],
                id));
          }
        }
        prs.add(PullRequest(
            jsonRes[i]['node']['id'],
            jsonRes[i]['node']['title'],
            jsonRes[i]['node']['url'],
            repo,
            "ghost",
            jsonRes[i]['node']['number'],
            labels));
      }
    }
  }
  return prs;
}

// parseIssues parses the result from the GraphQL query for fetching the issues for a repo
List<Issue> parseIssues(Map<String,dynamic> resBody, Repository repo) {
  List jsonRes = resBody['search']['edges'];

  List<Issue> issues = [];
  for (var i = 0; i < jsonRes.length; i++) {
    try {
      List<Label> labels = [];
      if (jsonRes[i]['node']['labels']['nodes'].length != 0) {
        for (var j = 0; j < jsonRes[i]['node']['labels']['nodes'].length; j++) {
          var id = jsonRes[i]['node']['labels']['nodes'][j]['id'];
          id = id.substring(0, id.length - 1);
          labels.add(Label(jsonRes[i]['node']['labels']['nodes'][j]['name'],
              jsonRes[i]['node']['labels']['nodes'][j]['color'],
              id));
        }
      }

      issues.add(Issue(
          jsonRes[i]['node']['title'],
          jsonRes[i]['node']['id'],
          jsonRes[i]['node']['url'],
          repo,
          jsonRes[i]['node']['author']['login'],
          jsonRes[i]['node']['state'],
          jsonRes[i]['node']['number'],
          labels));
    } catch (e) {
      if (e == NoSuchMethodError) {
        List<Label> labels = [];
        if (jsonRes[i]['node']['labels']['nodes'].length != 0) {
          for (var j = 0;
              j < jsonRes[i]['node']['labels']['nodes'].length;
              j++) {
            var id = jsonRes[i]['node']['labels']['nodes'][j]['id'];
            id = id.substring(0, id.length - 1);
            labels.add(Label(jsonRes[i]['node']['labels']['nodes'][j]['name'],
                jsonRes[i]['node']['labels']['nodes'][j]['color'],
                id));
          }
        }

        issues.add(Issue(
            jsonRes[i]['node']['title'],
            jsonRes[i]['node']['id'],
            jsonRes[i]['node']['url'],
            repo,
            "ghost",
            jsonRes[i]['node']['state'],
            jsonRes[i]['node']['number'],
            labels));
      }
    }
  }
  return issues;
}

// parsePRTimeline parses the result from the GraphQL query for fetching the timeline for a PR
List<TimelineItem> parsePRTimeline(Map<String,dynamic> resBody, PullRequest pr) {
  List jsonRes = resBody['repository']['pullRequest']
      ['timeline']['edges'];

  List<TimelineItem> prTimeline = [];
  Map tmp = resBody['repository']['pullRequest'];
  prTimeline.add(
      IssueComment(pr, null, "", "", "", tmp['author']['login'], tmp['body']));
  for (var i = 0; i < jsonRes.length; i++) {
    Map temp = jsonRes[i]['node'];
    if (temp.keys.contains('bodyText')) {
      prTimeline.add(IssueComment(pr, null, temp['id'], temp['url'], "",
          temp['author']['login'], temp['bodyText']));
    } else if (temp.keys.contains('message')) {
      if (temp['author']['user'] == null) {
        prTimeline.add(Commit(
          pr,
          null,
          temp['id'],
          temp['url'],
          "",
          "",
          temp['message'],
        ));
      } else {
        prTimeline.add(Commit(
          pr,
          null,
          temp['id'],
          temp['url'],
          "",
          temp['author']['user']['login'],
          temp['message'],
        ));
      }
    } else if (temp.keys.contains('label')) {
      prTimeline.add(LabeledEvent(
          pr,
          null,
          temp['id'],
          temp['label']['url'],
          "",
          temp['actor']['login'],
          Label(temp['label']['name'], temp['label']['color'],
          temp['label']['id'])));
    }
  }
  return prTimeline;
}

// parseIssueTimeline parses the result from the GraphQL query for fetching the timeline for an issue
List<TimelineItem> parseIssueTimeline(Map<String,dynamic> resBody, Issue issue) {
  List jsonRes =
      resBody['repository']['issue']['timeline']['edges'];

  List<TimelineItem> issueTimeline = [];
  Map tmp = resBody['repository']['issue'];
  issueTimeline.add(IssueComment(
      null, issue, "", "", "", tmp['author']['login'], tmp['body']));
  for (var i = 0; i < jsonRes.length; i++) {
    Map temp = jsonRes[i]['node'];
    if (temp.keys.contains('bodyText')) {
      issueTimeline.add(IssueComment(null, issue, temp['id'], temp['url'], "",
          temp['author']['login'], temp['bodyText']));
    } else if (temp.keys.contains('message')) {
      if (temp['author']['user'] == null) {
        issueTimeline.add(Commit(
          null,
          issue,
          temp['id'],
          temp['url'],
          "",
          "",
          temp['message'],
        ));
      } else {
        issueTimeline.add(Commit(
          null,
          issue,
          temp['id'],
          temp['url'],
          "",
          temp['author']['user']['login'],
          temp['message'],
        ));
      }
    } else if (temp.keys.contains('label')) {
      issueTimeline.add(LabeledEvent(
          null,
          issue,
          temp['id'],
          temp['label']['url'],
          "",
          temp['actor']['login'],
          Label(temp['label']['name'], temp['label']['color'],
          temp['label']['id'])));
    }
  }
  return issueTimeline;
}

// parseUserRepos parses the result from the GraphQL query for fetching the repositories for a user
List<Repository> parseUserRepos(Map<String,dynamic> resBody) {
  List jsonRes =
      resBody['viewer']['repositories']['nodes'];

  List<Repository> repos = [];

  for (var i = 0; i < jsonRes.length; i++) {
    List<Label> labels = [];
    List nodes = jsonRes[i]['labels']['nodes'];
    for (var j = 0; j < nodes.length; j++){
      var id = nodes[j]['id'];
      id = id.substring(0, id.length - 1);
      labels.add(Label(nodes[j]['name'], nodes[j]['color'], id));
    }
    repos.add(Repository(jsonRes[i]['name'], jsonRes[i]['owner']['login'],jsonRes[i]['nameWithOwner'], labels));
  }

  return repos;
}

// parseAddedComment parses the response received after calling addComment mutation
IssueComment parseAddedComment(Map<String,dynamic> resBody, PullRequest pr, Issue issue) {
  Map jsonRes =
      resBody['addComment']['commentEdge']['node'];
  Map jsonTemp = resBody['addComment'];

  return IssueComment(pr, issue, "", jsonRes['url'], jsonTemp['subject']['id'],
      jsonRes['author']['login'], jsonRes['bodyText']);
}

List parseAddedLabels(Map<String,dynamic> resBody, PullRequest pr, Issue issue) {
  List labels =
      resBody['addLabelsToLabelable']['labelable']['labels']['nodes'];
  return labels;
}