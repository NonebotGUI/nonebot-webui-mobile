import 'package:flutter/material.dart';


class Template extends StatefulWidget {
  const Template({super.key});

  @override
  State<Template> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Template> {

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoneBot WebUI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: myController,
            ),
            ElevatedButton(
              onPressed: () {
                print(myController.text);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

