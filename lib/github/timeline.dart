import 'pullrequest.dart';

// contains timeline items
class TimelineItem {
  PullRequest pr;
  String id;
  String url;
  String title;
  String author;

  TimelineItem(this.pr, this.id, this.url, this.title, this.author);

  String toString() =>
      'Title: $title, ID: $id, URL: $url, Pull Request: $pr, Author: $author';
}

class IssueComment extends TimelineItem {
  String body;

  IssueComment(PullRequest pr, String id, String url, String title,
      String author, this.body)
      : super(pr, id, url, title, author);
  String toString() =>
      'Title: $title, ID: $id, URL: $url, Pull Request: $pr, Author: $author, Body: $body';
}

class Commit extends TimelineItem {
  String message;

  Commit(PullRequest pr, String id, String url, String title, String author,
      this.message)
      : super(pr, id, url, title, author);
  String toString() =>
      'Title: $title, ID: $id, URL: $url, Pull Request: $pr, Author: $author, Message: $message';
}

class LabeledEvent extends TimelineItem {
  String labelName;

  LabeledEvent(PullRequest pr, String id, String url, String title,
      String author, this.labelName)
      : super(pr, id, url, title, author);
  String toString() =>
      'Title: $title, ID: $id, URL: $url, Pull Request: $pr, Author: $author, Label: $labelName';
}
