import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/multiselect_nested_controller.dart';
import 'models/multiselect_nested_item.dart';
import 'multiselect_nested.dart';


void main() {
  runApp(Directionality(
      textDirection: TextDirection.rtl,
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<MultiSelectNestedItem> options;
  List<MultiSelectNestedItem> selected = [];
  MultiSelectNestedController multiSelectController =
  MultiSelectNestedController();
  bool validationTriggered=false;
  @override
  void initState() {
    super.initState();
    options = _buildOptions();
  }

  List<MultiSelectNestedItem> _buildOptions() {
    List<ModeTree> modeTrees = _buildTree();
    return _convertToMultiSelectNestedItems(modeTrees);
  }

  List<ModeTree> _buildTree() {
    return buildTree(modes);
  }

  List<MultiSelectNestedItem> _convertToMultiSelectNestedItems(
      List<ModeTree> modeTrees) {
    return modeTrees.map((tree) => _convertTreeToItem(tree)).toList();
  }

  MultiSelectNestedItem _convertTreeToItem(ModeTree tree) {
    return MultiSelectNestedItem(
      id: tree.id.toString(),
      name: tree.name,
      children: _convertToMultiSelectNestedItems(tree.children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Center(
                child: MultiSelectNested(
                  controller: multiSelectController,
                  options: options,
                  selectedValues: selected,
                  isAnimatedContainer: false,
                  liveUpdateValues: true,
                  setSelectedValues: (List<MultiSelectNestedItem> newValues) {
                    setState(() {
                      selected = newValues;
                    });
                  }, validationTriggered: validationTriggered,
                  noItemSelect: 'برجاء إختيار المجموعة',
                ),
              ),
              Text('data')
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _validateSelection();
            setState(() {
              validationTriggered=true;

            });
          },
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  void _validateSelection() {
    if (multiSelectController.validateSelection()) {
      // Proceed with your action
      print('Validation passed!');
    } else {
      // Show validation error or take appropriate action
      print('Validation failed! Please select at least one option.');
    }
  }
}

class Mode {
  final int id;
  final String name;
  final int parentId;

  Mode({required this.id, required this.name, required this.parentId});
}

class ModeTree {
  final int id;
  final String name;
  final List<ModeTree> children;

  ModeTree({required this.id, required this.name, this.children = const []});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}

List<Mode> modes = [
  Mode(id: 1, name: 'Item 1', parentId: 0),
  Mode(id: 2, name: 'Item 2', parentId: 0),
  Mode(id: 3, name: 'Item 1.1', parentId: 1),
  Mode(id: 4, name: 'Item 1.2', parentId: 1),
  Mode(id: 5, name: 'Item 1.1.1', parentId: 3),
  Mode(id: 6, name: 'Item 1.1.2', parentId: 3),
  Mode(id: 7, name: 'Item 1.2.1', parentId: 4),
  Mode(id: 8, name: 'Item 1.2.2', parentId: 4),
  Mode(id: 9, name: 'Item 2.1', parentId: 2),
  Mode(id: 10, name: 'Item 2.2', parentId: 2),
  Mode(id: 11, name: 'Item 2.1.1', parentId: 9),
  Mode(id: 12, name: 'Item 2.1.2', parentId: 9),
  Mode(id: 13, name: 'Item 2.2.1', parentId: 10),
  Mode(id: 14, name: 'Item 2.2.2', parentId: 10),
  Mode(id: 15, name: 'Item 3', parentId: 0),
  Mode(id: 16, name: 'Item 3.1', parentId: 15),
  Mode(id: 17, name: 'Item 3.2', parentId: 15),
  Mode(id: 18, name: 'Item 3.1.1', parentId: 16),
  Mode(id: 19, name: 'Item 3.1.2', parentId: 16),
  Mode(id: 20, name: 'Item 3.2.1', parentId: 17),
];

List<ModeTree> buildTree(List<Mode> modes, {int parentId = 0}) {
  List<ModeTree> modeTrees = [];

  for (var mode in modes.where((mode) => mode.parentId == parentId)) {
    modeTrees.add(ModeTree(
      id: mode.id,
      name: mode.name,
      children: buildTree(modes, parentId: mode.id),
    ));
  }

  return modeTrees;
}

