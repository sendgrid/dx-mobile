import 'package:flutter/material.dart';
import '../github/timeline.dart';

Widget buildTimelineItem(TimelineItem timelineItem) {
  switch (timelineItem.runtimeType) {
    case IssueComment:
      IssueComment temp = timelineItem;
      return ListTile(
        leading: Text(temp.author),
        title: Text(temp.body),
      );
    case Commit:
      Commit temp = timelineItem;
      return ListTile(
        leading: Text(temp.author),
        title: Text(temp.message),
      );
    case LabeledEvent:
      LabeledEvent temp = timelineItem;
      return ListTile(
        leading: Text(temp.author),
        title: Text(temp.labelName),
      );
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
      padding: EdgeInsets.only(left: 10.0),
      width: MediaQuery.of(context).size.width * 5 / 8,
      child: TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: " Enter comment here",
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
    RaisedButton(
      child: Text("Comment"),
      color: Theme.of(context).primaryColorLight,
      onPressed: onPressed,
    );
