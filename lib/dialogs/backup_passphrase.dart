// Dart imports:
import 'dart:convert';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

// Project imports:
import 'package:safenotes/data/preference_and_config.dart';

class ImportPassPhraseDialog extends StatefulWidget {
  @override
  _ImportPassPhraseDialogState createState() => _ImportPassPhraseDialogState();
}

class _ImportPassPhraseDialogState extends State<ImportPassPhraseDialog> {
  bool _isHiddenImport = true;
  final importPassphraseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double importDataPassDialogRadious = 10.0;

    return BackdropFilter(
      filter: ImageFilter.blur(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(importDataPassDialogRadious),
        ),
        child: _buildImportPassDialog(context),
      ),
    );
  }

  Widget _buildImportPassDialog(BuildContext context) {
    final double paddingAllAround = 15.0;
    final double paddingTextTop = 12.0;
    final double titleFontSize = 20.0;
    final double descriptionFontSize = 15.0;
    final String titleHeading = 'Import Data is Encrypted';
    final String description =
        'Enter the passphrase of the device that generated this file.';

    return Padding(
      padding: EdgeInsets.all(paddingAllAround),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: paddingTextTop),
            child: Text(
              titleHeading,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingTextTop),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: descriptionFontSize,
              ),
            ),
          ),
          _buildPassField(context),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildPassField(BuildContext context) {
    final double inputBoxRadius = 10.0;
    final double paddingTextBox = 15.0;
    final String inputBoxHint = 'Encrypton Phrase';

    return Padding(
      padding: EdgeInsets.only(top: paddingTextBox, bottom: paddingTextBox),
      child: Form(
        key: _formKey,
        child: TextFormField(
          enableIMEPersonalizedLearning: false,
          controller: importPassphraseController,
          autofocus: true,
          enableInteractiveSelection: false,
          obscureText: this._isHiddenImport,
          decoration: InputDecoration(
            hintText: inputBoxHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(inputBoxRadius),
            ),
            prefixIcon: Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: !this._isHiddenImport
                  ? Icon(Icons.visibility_off)
                  : Icon(Icons.visibility),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          keyboardType: TextInputType.visiblePassword,
          validator: _passphraseValidator,
          onEditingComplete: _onEditonComplete,
        ),
      ),
    );
  }

  void _onEditonComplete() {
    final form = this._formKey.currentState!;
    if (form.validate()) {
      ImportPassPhraseHandler.setImportPassPhrase(
          importPassphraseController.text);
      Navigator.of(context).pop();
    }
  }

  String? _passphraseValidator(String? passphrase) {
    final wrongPhraseMsg = 'Wrong Passphrase!';

    return sha256.convert(utf8.encode(passphrase!)).toString() !=
            ImportPassPhraseHandler.getImportPassPhraseHash()
        ? wrongPhraseMsg
        : null;
  }

  Widget _buildButtons(BuildContext context) {
    final double paddingAroundButtonRow = 15.0;
    final String formSubmitButtonText = 'Submit';
    final String formCancelButtonText = 'Cancel';

    return Container(
      padding: EdgeInsets.fromLTRB(paddingAroundButtonRow,
          paddingAroundButtonRow, paddingAroundButtonRow, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(NordColors.aurora.red),
            ),
            child: Text(formCancelButtonText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(formSubmitButtonText),
            onPressed: _onEditonComplete,
          ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() =>
      setState(() => this._isHiddenImport = !this._isHiddenImport);
}
