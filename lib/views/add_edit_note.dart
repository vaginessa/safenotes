// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';

// Project imports:
import 'package:safenotes/data/database_handler.dart';
import 'package:safenotes/data/preference_and_config.dart';
import 'package:safenotes/models/safenote.dart';
import 'package:safenotes/widgets/note_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final SafeNote? note;

  const AddEditNotePage({Key? key, this.note}) : super(key: key);

  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String description;

  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSizeProvider(
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                actions: [buildButton()],
              ),
              body: Consumer<ScreenHeight>(builder: (context, _res, child) {
                return Form(
                  key: _formKey,
                  child: NoteFormWidget(
                    title: title,
                    description: description,
                    onChangedTitle: (title) =>
                        setState(() => this.title = title),
                    onChangedDescription: (description) =>
                        setState(() => this.description = description),
                  ),
                );
              }),
            )));
  }

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && description.isNotEmpty;
    final double buttonFontSize = 17.0;
    final String buttonText = 'Save';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid
              ? (PreferencesStorage.getIsThemeDark()
                  ? null
                  : NordColors.polarNight.darkest)
              : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNote,
        child: Text(
          buttonText,
          style:
              TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      // if AddEditNotePage() was instantiated with SafeNotes object
      final isUpdating = widget.note != null;

      if (isUpdating) {
        if (widget.note!.title != this.title ||
            widget.note!.description != this.description) await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      title: title,
      description: description,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.encryptAndUpdate(note);
  }

  Future addNote() async {
    final note = SafeNote(
      title: title,
      description: description,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.encryptAndStore(note);
  }
}
