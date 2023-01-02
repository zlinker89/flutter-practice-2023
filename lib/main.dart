import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyStateHomePage();
}

class MyStateHomePage extends State<MyHomePage> {
  // created the ScaffoldState key
  final scaffoldState = GlobalKey<ScaffoldState>();
  // The key to be used when accessing SliverAnimatedListState
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  TextEditingController taskController = TextEditingController();
  FocusNode fTask = FocusNode();
  bool selected = false;
  double _expandedHeight = 250.0;
  String _title = "Playa";
  List<String> tasks = [];

  void _showModalSheet(context) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 300,
            child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    const Text("Por favor ingresa una tarea"),
                    Container(
                      child: TextFormField(
                        onSaved: ((newValue) => _addTask()),
                        focusNode: fTask,
                        controller: taskController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Ingresa una tarea',
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.blue.withOpacity(0.04);
                            if (states.contains(MaterialState.focused) ||
                                states.contains(MaterialState.pressed))
                              return Colors.blue.withOpacity(0.12);
                            return null; // Defer to the widget's default.
                          },
                        ),
                      ),
                      onPressed: () {
                        _addTask();
                      },
                      child: Text('Añadir Tarea'),
                    ),
                  ],
                )),
          );
        });
  }

  void _addTask() {
    String task = taskController.value.text;
    if (task.length > 0) {
      taskController.clear();
      fTask.unfocus();
      Navigator.pop(context);
      setState(() {
        tasks.add(task);
      });
      _listKey.currentState?.insertItem(tasks.length - 1,
          duration: const Duration(milliseconds: 400));
    } else {
      FocusScope.of(context).requestFocus(fTask);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Debe ingresar una tarea"),
      ));
    }
  }

  _showAlertDialog(BuildContext context, String task, int indexTask) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Elimnar"),
      onPressed: () {
        Navigator.pop(context);
        setState(() {
          _listKey.currentState?.removeItem(
              indexTask,
              (context, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: _buildItem(context, indexTask, animation)),
              duration: const Duration(milliseconds: 400));
          tasks.removeAt(indexTask);
        });
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Atención"),
      content: Text("¿Desea eliminar la tarea: $task?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _buildItem(context, index, animation) {
    String task = tasks.isNotEmpty ? tasks[index] : "";
    return SizeTransition(
        sizeFactor: animation,
        child: Card(
          child: ListTile(
            title: Text("$task"),
            leading: const Icon(Icons.person),
            onTap: (() {
              _showAlertDialog(context, task, index);
            }),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedHeight,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  Builder(builder: (context) {
                    return IconButton(
                        tooltip: "Nueva tarea",
                        color: Colors.white,
                        onPressed: (() {
                          _showModalSheet(context);
                        }),
                        icon: Icon(Icons.add));
                  }),
                  Text(_title, textScaleFactor: 1.0)
                ],
              ),
              background: Image.asset(
                'assets/images/playa.jpg',
                fit: BoxFit.fill,
              ),
            ),
            pinned: true,
            snap: false,
            floating: true,
          ),
          SliverAnimatedList(
            key: _listKey,
            initialItemCount: tasks.length,
            itemBuilder: (context, index, animation) =>
                _buildItem(context, index, animation),
          )
        ],
      ),
    );
  }
}
