import 'repository.dart';
import 'label.dart';

class Issue {
  final Repository repo;
  final String id;
  final String url;
  final String title;
  final String author;
  final String issueState;
  final int number;
  final List<Label> labels;

  Issue(
    this.title,
    this.id,
    this.url,
    this.repo,
    this.author,
    this.issueState,
    this.number,
    this.labels
  );

  String toString() =>
      '$title, $id, $url, $repo, $author, $issueState, $number, $labels';
}
