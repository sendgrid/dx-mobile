import 'repository.dart';

class Issue {
  final Repository repo;
  final String id;
  final String url;
  final String title;
  final String author;
  final String issueState;
  final int number;
  
  Issue(this.title, this.id, this.url, this.repo, this.author, this.issueState, this.number);

  String toString() => '$title, $id, $url, $repo, $author, $issueState, $number';
}
