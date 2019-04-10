import 'package:flutter/material.dart';

import '../github/graphql.dart';
import '../github/token.dart';

import 'userpage.dart';

class LoginPage extends StatefulWidget {
  

  LoginPage();

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController controller = TextEditingController();
  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              Text(
                "Log in to DXGo with your GitHub Token",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0
                )),
              SizedBox(height: 48.0),
              TextFormField(
                keyboardType: TextInputType.text,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Enter Github Authentication Token",
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
                ),
                enableInteractiveSelection: true,
                controller: controller,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Theme.of(context).primaryColorDark,
                  child: Text("Log In", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // store github token
                    print(token);
                    token = controller.text;
                    bool authenticated = true;
                    // attempt to authenticate
                    try {
                      currentUser();
                    }
                    catch (e){
                      authenticated = false;
                      print("invalid token");
                    }
                    
                    if (authenticated) {
                      // clear text form field
                      controller.clear();
                      // navigate to user page
                      Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => new UserPage()));
                    }
                    else {
                      // show toast that asks them to reauthenticate
                    }
                    
                  },
                )
              )
            ]
          )
        )
      );
    }
}