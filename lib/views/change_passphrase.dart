// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

// Project imports:
import 'package:safenotes/data/database_handler.dart';
import 'package:safenotes/data/preference_and_config.dart';
import 'package:safenotes/models/safenote.dart';
import 'package:safenotes/models/session.dart';
import 'package:safenotes/utils/passphrase_strength.dart';
import 'package:safenotes/utils/snack_message.dart';

class ChangePassphrase extends StatefulWidget {
  const ChangePassphrase({Key? key}) : super(key: key);
  _ChangePassphraseState createState() => _ChangePassphraseState();
}

class _ChangePassphraseState extends State<ChangePassphrase> {
  final formKey = GlobalKey<FormState>();
  bool _isHiddenOld = true;
  bool _isHiddenNew = true;
  bool _isHiddenNewConfirm = true;
  final _oldPassphraseController = TextEditingController();
  final _newPassphraseController = TextEditingController();
  final _newConfirmPassphraseController = TextEditingController();
  late List<SafeNote> allnotes;
  final _focusOld = FocusNode();
  final _focusNew = FocusNode();
  final _focusNewConfirm = FocusNode();

  @override
  initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _focusOld.dispose();
    _focusNew.dispose();
    _focusNewConfirm.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    this.allnotes = await NotesDatabase.instance.decryptReadAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildPassphraseChangeWorkflow(context),
    );
  }

  Widget _buildPassphraseChangeWorkflow(BuildContext context) {
    final String pageTitleName = 'Change Passphrase';
    final double paddingBetweenInputBox = 25.0;

    return Form(
      key: this.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(15, 40, 15, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.only(top: paddingBetweenInputBox, bottom: 10),
              child: Text(
                pageTitleName,
                style: TextStyle(fontSize: 22),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingBetweenInputBox),
              child: _buildCurrentPassField(),
            ),
            Padding(
              padding: EdgeInsets.only(top: paddingBetweenInputBox),
              child: _buildNewPassField(),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: paddingBetweenInputBox, bottom: paddingBetweenInputBox),
              child: _buildNewConfirmPassField(),
            ),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPassField() {
    final double inputBoxEdgeRadious = 10.0;
    final String inputHintOld = 'Current Passphrase';
    final String validationErrorMsg = 'Wrong passphrase!';

    return TextFormField(
      enableIMEPersonalizedLearning: false,
      controller: this._oldPassphraseController,
      autofocus: true,
      focusNode: _focusOld,
      enableInteractiveSelection: false,
      obscureText: this._isHiddenOld,
      decoration: _inputBoxDecoration(
          context, 'first', inputHintOld, inputBoxEdgeRadious),
      keyboardType: TextInputType.visiblePassword,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(_focusNew);
      },
      textInputAction: TextInputAction.next,
      validator: (passphrase) {
        return sha256.convert(utf8.encode(passphrase!)).toString() !=
                PreferencesStorage.getPassPhraseHash()
            ? validationErrorMsg
            : null;
      },
    );
  }

  Widget _buildNewPassField() {
    final double inputBoxEdgeRadious = 10.0;
    final String inputHintNew = 'New Passphrase';

    return TextFormField(
      enableIMEPersonalizedLearning: false,
      controller: this._newPassphraseController,
      focusNode: _focusNew,
      enableInteractiveSelection: false,
      obscureText: this._isHiddenNew,
      decoration: _inputBoxDecoration(
          context, 'second', inputHintNew, inputBoxEdgeRadious),
      keyboardType: TextInputType.visiblePassword,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(_focusNewConfirm);
      },
      textInputAction: TextInputAction.next,
      validator: _firstInputValidator,
    );
  }

  String? _firstInputValidator(String? passphrase) {
    final int minPassphraseLength = 8;
    final double minPassphraseStrength = 0.5;
    final String minpCharacterMsg = 'Minimum 8 characters long!';
    final String tooWeakMsg = 'Passphrase is too weak!';

    return passphrase == null || passphrase.length < minPassphraseLength
        ? minpCharacterMsg
        : (estimateBruteforceStrength(passphrase) < minPassphraseStrength)
            ? tooWeakMsg
            : null;
  }

  Widget _buildNewConfirmPassField() {
    final double inputBoxEdgeRadious = 10.0;
    final String inputHintConfirm = 'Confirm New Passphrase';
    final String passPhraseMismatchMsg = 'Passphrase Mismatch!';

    return TextFormField(
      enableIMEPersonalizedLearning: false,
      controller: this._newConfirmPassphraseController,
      focusNode: _focusNewConfirm,
      enableInteractiveSelection: false,
      obscureText: this._isHiddenNewConfirm,
      decoration: _inputBoxDecoration(
          context, 'third', inputHintConfirm, inputBoxEdgeRadious),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onEditingComplete: _finalSublmitChange,
      validator: (password) => password != _newPassphraseController.text
          ? passPhraseMismatchMsg
          : null,
    );
  }

  InputDecoration _inputBoxDecoration(BuildContext context, String inputFieldID,
      String inputHintText, double inputBoxEdgeRadious) {
    bool? visibility = null;

    if (inputFieldID == 'first') {
      visibility = this._isHiddenOld;
    } else if (inputFieldID == 'second') {
      visibility = this._isHiddenNew;
    } else {
      visibility = this._isHiddenNewConfirm;
    }

    return InputDecoration(
      hintText: inputHintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBoxEdgeRadious),
      ),
      prefixIcon: Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: !visibility ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
        onPressed: () {
          if (inputFieldID == 'first') {
            return _toggleOldPasswordVisibility();
          } else if (inputFieldID == 'second') {
            return _toggleNewPasswordVisibility();
          } else {
            return _toggleNewConfirmPasswordVisibility();
          }
        },
      ),
    );
  }

  void _toggleOldPasswordVisibility() =>
      setState(() => this._isHiddenOld = !this._isHiddenOld);
  void _toggleNewPasswordVisibility() =>
      setState(() => this._isHiddenNew = !this._isHiddenNew);
  void _toggleNewConfirmPasswordVisibility() =>
      setState(() => this._isHiddenNewConfirm = !this._isHiddenNewConfirm);

  Widget _buildButtons(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 10, top: 25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: PreferencesStorage.getIsThemeDark()
                ? NordColors.snowStorm.lightest
                : NordColors.polarNight.darkest,
            minimumSize: Size(200, 50), //Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5.0, //StadiumBorder(),
          ),
          child: Wrap(
            children: <Widget>[
              Icon(Icons.key, size: 25.0),
              SizedBox(width: 20),
              Text("Confirm", style: TextStyle(fontSize: 20)),
            ],
          ),
          onPressed: _finalSublmitChange,
        ),
      ),
    );
  }

  void _finalSublmitChange() async {
    final form = formKey.currentState!;
    final String passChangedSnackMsg = 'Passphrase changed!';

    // Update SHA256 signature of passphrase
    if (form.validate()) {
      Session.setOrChangePassphrase(_newConfirmPassphraseController.text);
      // Re-encrypt and update all the existing notes
      for (final note in this.allnotes) {
        await NotesDatabase.instance.encryptAndUpdate(note);
      }
      showSnackBarMessage(context, passChangedSnackMsg);
      Navigator.of(context).pop();
    }
  }
}
