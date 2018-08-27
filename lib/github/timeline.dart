import 'pullrequest.dart';

// contains timeline items
class TimelineItem {
  PullRequest pr;
  String id;
  String url;
  String title;
  String author;
  
  TimelineItem({PullRequest pr, String id, String url, String title, String author});

  String toString() => 'Title: $title, ID: $id, URL: $url, Pull Request: $pr, Author: $author';
}

class IssueComment extends TimelineItem {
  String body;

  IssueComment(this.body, {PullRequest pr, String id, String url, String title, String author});
}

class Commit extends TimelineItem {
  String message;
  
  Commit(this.message, {PullRequest pr, String id, String url, String title, String author});
}

class LabeledEvent extends TimelineItem{
  String labelName;

  LabeledEvent(this.labelName, {PullRequest pr, String id, String url, String title, String author});
}