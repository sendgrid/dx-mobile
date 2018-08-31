import 'pullrequest.dart';
import 'issue.dart';

// contains timeline items
class TimelineItem {
  PullRequest pr;
  Issue issue;
  String id;
  String url;
  String title;
  String author;

  TimelineItem(this.pr, this.issue, this.id, this.url, this.title, this.author);

  String toString() {
    if (pr != null) {
      return 'Title: $title, ID: $id, URL: $url, Pull Request: $pr, Author: $author';
    }
    else if (issue != null) {
      return 'Title: $title, ID: $id, URL: $url, Issue: $issue, Author: $author';
    }
  }
}

class IssueComment extends TimelineItem {
  String body;

  IssueComment(PullRequest pr, Issue issue, String id, String url, String title,
      String author, this.body) : super(pr, issue, id, url, title, author);
  String toString() =>
      super.toString() + "Body: $body";
}

class Commit extends TimelineItem {
  String message;

  Commit(PullRequest pr, Issue issue, String id, String url, String title, String author,
      this.message)
      : super(pr, issue, id, url, title, author);
  String toString() =>
      super.toString() + "Message: $message";
}

class LabeledEvent extends TimelineItem {
  String labelName;

  LabeledEvent(PullRequest pr, Issue issue, String id, String url, String title,
      String author, this.labelName)
      : super(pr, issue, id, url, title, author);
  String toString() =>
      super.toString() + "Label Name: $labelName";
}
