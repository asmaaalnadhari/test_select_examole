
import 'multiselect_nested_item.dart';

class MultiSelectNestedController {
  late List<MultiSelectNestedItem> Function() getSelectedItems;
  late void Function() expandContainer;
  late void Function() clearValues;
  late bool Function() validateSelection; // Add this line
}

