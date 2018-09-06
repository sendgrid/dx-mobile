// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ALL QUERIES IN HERE

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'parsers.dart';
import 'pullrequest.dart';
import 'issue.dart';
import 'timeline.dart';
import 'repository.dart';
import 'token.dart';
import 'user.dart';


final url = 'https://api.github.com/graphql';
final headers = {'Authorization': 'bearer $token'};
final postHeaders = {'Authorization': 'token $token'};

/// Fetches the details of the specified user
Future<User> user(String login) async {
  final query = '''
    query {
      user(login:"$login") {
        login
        name
        avatarUrl
      }
    }
  ''';

  final result = await _query(query);
  return parseUser(result);
}

/// Fetches user data for the auth'd user
Future<User> currentUser() async {
  const query = '''
    query {
      viewer {
        login
        name
        avatarUrl
      }
    }''';
  final result = await _query(query);
  return parseUser(result);
}

/// Fetches all PR review requests for the logged in user
Future<List<PullRequest>> openPullRequestReviews(String login) async {
  final query = '''
    query GetOpenReviewRequests {
      search(query: "type:pr state:open review-requested:$login", type: ISSUE, first: 100) {
        issueCount
        pageInfo {
          endCursor
          startCursor
        }
        edges {
          node {
            ... on PullRequest {
              repository {
                name
                url
                stargazers(first: 1) {
                  totalCount
                }
              }
              title
              id
              url
            }
          }
        }
      }
    }''';
  final result = await _query(query);
  return parseOpenPullRequestReviews(result);
}

addEmoji(String id, String reaction) async {
  var query = '''
    mutation AddReactionToIssue {
      addReaction(input:{subjectId:"$id", content:$reaction}) {
        reaction {
          content
        }
        subject {
          id
        }
      }
    }
    ''';
  await _query(query);
}

acceptPR(String reviewUrl) async {
  var response = await http.put('$reviewUrl/merge', headers: postHeaders);
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode} ${response.body}');
}

closePR(String reviewUrl) async {
  var response = await http.patch(reviewUrl,
      headers: postHeaders, body: '{"state": "closed"}');
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode} ${response.body}');
}

getDiff(PullRequest pullRequest) async {
  var response = await http.get(pullRequest.diffUrl);
  return response.body;
}

// retrieves number of branches in a repo
Future<int> getBranches(String owner, String repoName) async {
  final query = '''
    query {
      repository(name: "$repoName", owner: "$owner") {
        refs(last: 100 , refPrefix:"refs/heads/") {
          totalCount
        }
      }
    }
  ''';

  final result = await _query(query);
  return parseBranches(result);
}

// retrieves number of releases in a repo
Future<int> getReleases(String owner, String repoName) async {
  final query = '''
    query {
      repository(name: "$repoName", owner: "$owner") {
        refs(refPrefix:"refs/tags/") {
          totalCount
        }
      }
    }
  ''';

  final result = await _query(query);
  return parseReleases(result);

}

// query for obtaining PRs for an organization
Future<List<PullRequest>> getPRs(String owner, String repoName) async {
  final query = '''
      query {
        repository(owner: "$owner", name: "$repoName") {
          pullRequests(last: 100, states: [OPEN], orderBy: {field: CREATED_AT, direction: DESC}) {
            nodes {
              author {
                login
              }
              title
              url
              id
              number
            }
          }
          name
          url
          stargazers(first: 1) {
            totalCount
          }
        }
      }
  ''';
  final result = await _query(query);
  // print(result.toString());
  return parsePullRequests(result, owner);
}

// query to get issues for an organization's repo
Future<List<Issue>> getIssues(String owner, String repoName) async {
  final query = '''
      query {
        repository(owner: "$owner", name: "$repoName") {
          issues(last: 100, states: [OPEN], orderBy: {field: CREATED_AT, direction: DESC}) {
            nodes {
              author {
                login
              }
              title
              url
              id
              state
              number
            }
          }
          name
          url
          stargazers(first: 1) {
            totalCount
          }
        }
      }
  ''';
  final result = await _query(query);
  return parseIssues(result, owner);
}

// query to get timeline from a specific PR of an organization's repo
Future<List<TimelineItem>> getPRTimeline(PullRequest pullRequest) async {
  final query = '''
    query {
      repository(owner: "${pullRequest.repo.organization}", name: "${pullRequest.repo.name}") {
        pullRequest(number: ${pullRequest.number}) {
          timeline(last: 100) {
            edges {
              node {
                ... on IssueComment {
                  bodyText
                  id
                  url
                  author {
                    login
                  }
                }
                ... on Commit {
                  message
                  id
                  url
                  author {
                    user {
                      login
                    }
                  }
                }
                ... on LabeledEvent {
                  id
                  label {
                    name
                    url
                  }
                  actor {
                    login
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
  final result = await _query(query);
  return parsePRTimeline(result, pullRequest);
}

// retrieves timeline for a specific issue
Future<List<TimelineItem>> getIssueTimeline(Issue issue) async {
  final query = '''
    query {
      repository(owner: "${issue.repo.organization}", name: "${issue.repo.name}") {
        issue(number: ${issue.number}) {
          timeline(last: 100) {
            edges {
              node {
                ... on IssueComment {
                  bodyText
                  id
                  url
                  author {
                    login
                  }
                }
                ... on Commit {
                  message
                  id
                  url
                  author {
                    user {
                      login
                    }
                  }
                }
                ... on LabeledEvent {
                  id
                  label {
                    name
                    url
                  }
                  actor {
                    login
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';
  final result = await _query(query);
  return parseIssueTimeline(result, issue);
}

// adds a comment to an issue or PR
Future<String> addComment(Issue issue, PullRequest pr, String commentBody) async {
  // issue will be null if it's for a PullRequest
  // pr will be null if it's for an Issue
  String id = "";
  if (issue == null) {
    id = pr.id;
  }
  else {
    id = issue.id;
  }
  final mutation = '''
  mutation {
    addComment(input:{subjectId: "[$id]", body: "$commentBody"}) {
      commentEdge {
        node {
          bodyText
          author {
            login
          }
        }
      }
      subject {
        id
      }
    }
  }
  ''';

  final result = await _query(mutation);
  print(result);

}

/// Sends a GraphQL query to Github and returns raw response
Future<String> _query(String query) async {
  final gqlQuery = json.encode({'query': _removeSpuriousSpacing(query)});
  final response = await http.post(url, headers: headers, body: gqlQuery);
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode}');
}

_removeSpuriousSpacing(String str) => str.replaceAll(RegExp(r'\s+'), ' ');
