import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'package:safe_notes/page/safe_notes_page.dart';
import 'package:safe_notes/widget/login_widget/login_button_widget.dart';
import 'package:safe_notes/databaseAndStorage/prefrence_sotorage_and_state_controls.dart';

class SetEncryptionPhrasePage extends StatefulWidget {
  @override
  _SetEncryptionPhrasePageState createState() =>
      _SetEncryptionPhrasePageState();
}

class _SetEncryptionPhrasePageState extends State<SetEncryptionPhrasePage> {
  final formKey = GlobalKey<FormState>();

  final passPhraseController1 = TextEditingController();
  final passPhraseController2 = TextEditingController();
  bool isHidden = false;

  @override
  void dispose() {
    passPhraseController1.dispose();
    passPhraseController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(AppInfo.getFirstLoginPageName()),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 90.0),
              child: Center(
                child: Container(
                    width: 200,
                    height: 200,
                    child: Image.asset(AppInfo.getAppLogoPath())),
              ),
            ),
            Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    inputFieldFirst(node),
                    //const SizedBox(height: 16),
                    inputFieldSecond(),
                    buildForgotPassword(),
                    //const SizedBox(height: 16),
                    buildButton(),
                    //buildNoAccount(),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget inputFieldFirst(node) => TextFormField(
        controller: passPhraseController1,
        autofocus: true,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Encryption Phrase',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          prefixIcon: Icon(Icons.lock),
        ),
        keyboardType: TextInputType.visiblePassword,
        //autofillHints: [AutofillHints.password],
        onEditingComplete: () => node.nextFocus(),
        validator: (password) => password != null && password.length < 8
            ? 'Enter min. 8 characters'
            : null,
      );

  Widget inputFieldSecond() => TextFormField(
      controller: passPhraseController2,
      //autofocus: autoFocus,
      //onFieldSubmitted: (value) => loginController(),
      obscureText: isHidden,
      decoration: InputDecoration(
          hintText: 'Confirm Encryption Phrase',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: (isHidden
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility)),
            onPressed: togglePasswordVisibility,
          )),
      keyboardType: TextInputType.visiblePassword,
      //autofillHints: [AutofillHints.password],
      onEditingComplete:
          loginController, //() => TextInput.finishAutofillContext(),
      validator: (password) => password != passPhraseController1.text
          ? 'Encryption Phrase mismatch!'
          : null);
  void togglePasswordVisibility() => setState(() => isHidden = !isHidden);

  Widget buildButton() => ButtonWidget(
        text: 'LOGIN',
        onClicked: () async {
          loginController();
        },
      );

  void loginController() async {
    final form = formKey.currentState!;

    if (form.validate()) {
      final phrase1 = passPhraseController1.text;
      final phrase2 = passPhraseController2.text;
      if (phrase2 == phrase1) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Encryption Phrase set!'),
          ));
        // Setting passhash phrase in share prefrences

        AppSecurePreferencesStorage.setPassPhraseHash(
            sha256.convert(utf8.encode(phrase2)).toString());
        PhraseHandler.initPass(phrase2);

        UnDecryptedLoginControl.setNoDecryptionFlag(false);

        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NotesPage()));
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Encryption Phrase missmach!'),
          ));
      }
    }
  }
/*   Widget buildNoAccount() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Don\'t have an account?'),
          TextButton(
            child: Text('SIGN UP'),
            onPressed: () {},
          ),
        ],
      ); */

  Widget buildForgotPassword() => Container(
        alignment: Alignment.centerRight,
        child: TextButton(
          child: Text('Use Strong Phrase!'),
          onPressed: () {},
        ),
      );
}
