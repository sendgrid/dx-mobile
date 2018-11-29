// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. (https://github.com/efortuna/dwmpr/blob/master/LICENSE)

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
import 'label.dart';

final url = 'https://api.github.com/graphql';
// updated this to allow use of preview stuff in the GraphQL API
final headers = {'Authorization': 'bearer $token', 'Accept': 'application/vnd.github.starfire-preview+json'};
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
// Future<List<PullRequest>> openPullRequestReviews(String login) async {
//   final query = '''
//     query GetOpenReviewRequests {
//       search(query: "type:pr state:open review-requested:$login", type: ISSUE, first: 100) {
//         issueCount
//         pageInfo {
//           endCursor
//           startCursor
//         }
//         edges {
//           node {
//             ... on PullRequest {
//               repository {
//                 name
//                 url
//                 stargazers(first: 1) {
//                   totalCount
//                 }
//               }
//               title
//               id
//               url
//             }
//           }
//         }
//       }
//     }''';
//   final result = await _query(query);
//   return parseOpenPullRequestReviews(result);
// }

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

/// Sends a GraphQL query to Github and returns raw response
Future<String> _query(String query) async {
  final gqlQuery = json.encode({'query': _removeSpuriousSpacing(query)});
  final response = await http.post(url, headers: headers, body: gqlQuery);
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode}');
}

_removeSpuriousSpacing(String str) => str.replaceAll(RegExp(r'\s+'), ' ');


// -------------------------------------------------------------------------------------
// NON CHROMIUM AUTHOR CODE BELOW (the code below is under MIT license)

// getBranches retrieves the number of branches in a repo
Future<int> getBranches(Repository repo) async {
  final query = '''
    query {
      repository(name: "${repo.name}", owner: "${repo.owner}") {
        refs(last: 100 , refPrefix:"refs/heads/") {
          totalCount
        }
      }
    }
  ''';

  final result = await _query(query);
  return parseBranches(result);
}

// getReleases retrieves the number of releases in a repo
Future<int> getReleases(Repository repo) async {
  final query = '''
    query {
      repository(name: "${repo.name}", owner: "${repo.owner}") {
        refs(refPrefix:"refs/tags/") {
          totalCount
        }
      }
    }
  ''';

  final result = await _query(query);
  return parseReleases(result);
}

// getPRs retrieves pull requests from a given repo/owner
Future<List<PullRequest>> getPRs(Repository repo) async {
  final query =
  '''
  query {
    search (query: "type:pr state:open repo:${repo.nameWithOwner}", type: ISSUE, first: 100){
      edges {
        node {
          ... on PullRequest {
            url
            title
            id
            number
            labels (first: 30) {
              nodes {
                name
                color
                id
              }
            }
            author {
              login
            }
          }
        }
      }
    }
  }
  ''';

  final result = await _query(query);
  // print(result);
  return parsePullRequests(result, repo);
}

// getIssues retrieves the open issues for a given repo
Future<List<Issue>> getIssues(Repository repo) async {
  final query =
  '''
  query {
    search (query: "type:issue state:open repo:${repo.nameWithOwner}", type: ISSUE, first: 100){
      edges {
        node {
          ... on Issue {
            url
            title
            id
            number
            state
            labels (first: 30){
              nodes {
                name
                color
                id
              }
            }
            author {
              login
            }
          }
        }
      }
    }
  }
  ''';
  final result = await _query(query);
  // print(result);
  return parseIssues(result, repo);
}

// getPRTimeline retrieves timeline from a specific PR of an organization's repo
Future<List<TimelineItem>> getPRTimeline(PullRequest pullRequest) async {
  String owner = pullRequest.repo.nameWithOwner.split("/")[0];
  final query = '''
    query {
      repository(owner: "$owner", name: "${pullRequest.repo.name}") {
        pullRequest(number: ${pullRequest.number}) {
          body
          author {
            login
          }
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
                    color
                    id
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

// getIssueTimeline retrieves a timeline for a specific issue
Future<List<TimelineItem>> getIssueTimeline(Issue issue) async {
  String owner = issue.repo.nameWithOwner.split("/")[0];
  final query = '''
    query {
      repository(owner: "$owner", name: "${issue.repo.name}") {
        issue(number: ${issue.number}) {
          body
          author {
            login
          }
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
                    color
                    id
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

// addComment adds a comment to an issue/pr
Future<IssueComment> addComment(Issue issue, PullRequest pr, String commentBody) async {
  // issue will be null if it's for a PullRequest
  // pr will be null if it's for an Issue
  String id = "";
  if (issue == null) {
    id = pr.id;
  } else {
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
          url
        }
      }
      subject {
        id
      }
    }
  }
  ''';

  final result = await _query(mutation);
  return parseAddedComment(result, pr, issue);

}

// addLabel adds a label to an issue/pr
Future<List> addLabel(Issue issue, PullRequest pr, List<String> labelIds) async {
  // issue will be null if it's for a PullRequest
  // pr will be null if it's for an Issue
  String id = "";
  if (issue == null) {
    id = pr.id;
  } else {
    id = issue.id;
  }

  var result;
  if (issue == null) {
    final mutationPR = '''
    mutation {
      addLabelsToLabelable(input:{labelIds:$labelIds, labelableId:$id}) {
        labelable {
          ... on PullRequest {
            labels (first: 30){
              nodes {
                name
                color
                id
              }
            }
          }
        }
      }
    }
    ''';
    result = await _query(mutationPR);
  }
  else {
    id = id.substring(0, id.length - 1);
    print("issue id: " +  id);
    final mutationIss = '''
    mutation {
      addLabelsToLabelable(input:{labelIds:$labelIds, labelableId:$id}) {
        labelable {
          ... on Issue {
            labels (first: 30){
              nodes {
                name
                color
                id
              }
            }
          }
        }
      }
    }
    ''';
    result = await _query(mutationIss);
    print('issue');
  }
  print(result);
  return parseAddedLabels(result, pr, issue);
}

// fetchUserRepos retrieves the repositories that the viewer has contributed to
Future<List<Repository>> fetchUserRepos() async{
  final query = '''
  query {
    viewer {
      login
      repositories(last:100) {
        nodes {
          name
          url
          nameWithOwner
          owner {
            login
          }
          labels(last: 100){
            nodes {
              color
              name
              id
            }
          }
        }
      }
    }
  }
  ''';
  final result = await _query(query);
  return parseUserRepos(result);
}

