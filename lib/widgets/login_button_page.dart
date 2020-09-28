import 'package:flutter/material.dart';
import '../screens/auth/auth_screen.dart';

class LoginButtonPage extends StatelessWidget {
  void _loginPage(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(AuthScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text('로그인'),
          onPressed: () => _loginPage(context)),
    );
  }
}
