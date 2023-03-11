import 'package:flutter/material.dart';

class ActivityFormWidget extends StatelessWidget {
  final String? title;
  final ValueChanged<String> onChangedTitle;

  const ActivityFormWidget({
    Key? key,
    this.title = '',
    required this.onChangedTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              formSpacing(),
              Text(
                "Record your Log",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              formSpacing(),
              buildTitle(),
              formSpacing(),
              audioDescription(),
              formSpacing(),
              recordAudioButton(),
            ],
          ),
        ),
      );

  Column audioDescription() {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: const Text(
              "Record your thoughts...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        )
      ],
    );
  }

  RawMaterialButton recordAudioButton() {
    return RawMaterialButton(
      onPressed: () {},
      elevation: 2,
      fillColor: Colors.white,
      padding: const EdgeInsets.all(15.0),
      shape: const CircleBorder(),
      child: const Icon(
        Icons.mic,
        size: 40.0,
      ),
    );
  }

  SizedBox formSpacing() => const SizedBox(height: 35);

  Widget buildTitle() => TextFormField(
        maxLines: 1,
        initialValue: title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Enter activity name...',
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'The title cannot be empty' : null,
        onChanged: onChangedTitle,
      );
}
