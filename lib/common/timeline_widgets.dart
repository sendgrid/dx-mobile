import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../github/user.dart';
import '../github/timeline.dart';
import '../github/graphql.dart';

Widget buildTimelineItem(TimelineItem timelineItem) {
  switch (timelineItem.runtimeType) {
    case IssueComment:
      IssueComment temp = timelineItem;
      return Card(
        child: Column(
          children: <Widget>[
            buildLeadingIconBar(temp.author, "commented"),
            ListTile(
              // leading: buildLeadingIcon(temp.author, "commented"),
              title: new MarkdownBody(data: temp.body),
            )
          ],
        ));
    case Commit:
      Commit temp = timelineItem;
      return Card(
        child: Column(
          children: <Widget>[
            buildLeadingIconBar(temp.author, "committed"),
            ListTile(
              // leading: buildLeadingIcon(temp.author, "commented"),
              title: Text(temp.message),
            )
          ],
        ));
    case LabeledEvent:
      LabeledEvent temp = timelineItem;
      return Card(
        child: Column(
          children: <Widget>[
            buildLeadingIconBar(temp.author, "added label"),
            ListTile(
              // leading: buildLeadingIcon(temp.author, "added label"),
              title: Chip(label: Text(temp.label.labelName, style: TextStyle(fontWeight: FontWeight.bold),), backgroundColor: Color(int.parse(temp.label.colorHex, radix: 16)).withOpacity(1.0),)
            )
          ],
        ));

    default:
      return ErrorWidget(Exception("Unknown TimelineItem type"));
  }
}

Widget buildCommentTextbox({
  @required BuildContext context,
  @required TextEditingController textEditingController,
  @required Function onChanged,
  @required Function onSubmitted,
}) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.only(left: 10.0, bottom: 5.0, top:5.0),
      width: MediaQuery.of(context).size.width * 5 / 8,
      child: TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: " Enter comment here",
          border: OutlineInputBorder(borderSide: BorderSide()),
          contentPadding: EdgeInsets.all(5.0),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 2,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    ),
  );
}

Widget buildSubmitCommentButton({
  @required BuildContext context,
  @required Function onPressed,
}) =>
    Container(
      padding: EdgeInsets.only(right:10.0, bottom: 5.0, top: 5.0),
      child: RaisedButton(
        child: Text("Comment"),
        color: Theme.of(context).primaryColorLight,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
    );


Widget buildAddLabelButton({
  @required BuildContext context,
  @required Function onPressed,
}) =>
  Container(
    padding: EdgeInsets.only(left: 10.0),
    child: RaisedButton(
      child: Text("Add labels", style: TextStyle(color: Colors.white),),
      color: Theme.of(context).primaryColorDark,
      onPressed: onPressed,
    )
  );

Widget buildLeadingIconBar(String login, String trailingText){
  return Row(
    children: <Widget>[
      buildUserIcon(login, trailingText),
      Text("  $login $trailingText: ")
    ],);
    
}

Widget buildUserIcon(String login, String trailingText){
  return FutureBuilder(
    future: user(login), 
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.done){
          if (snapshot.data == null){
            return CircleAvatar();
          }
          return CircleAvatar(
            backgroundImage: NetworkImage(snapshot.data.avatarUrl),
            radius: 15.0,
          );
        }else {
          return Text("...");
        }
    });
}