library multiselect_nested_options;
import 'package:flutter/material.dart';

import 'components/selected_value_item.dart';
import 'constants/colors.dart';
import 'models/multiselect_nested_controller.dart';
import 'models/multiselect_nested_item.dart';

class MultiSelectNested extends StatefulWidget {
  ///
  /// The options which a user can see and select
  ///
  final List<MultiSelectNestedItem> options;
  final bool validationTriggered;

  ///
  /// Preselected options
  ///
  final List<MultiSelectNestedItem> selectedValues;

  ///
  /// Callback to pass the selectedValues to the parent
  /// It's triggered when you add or remove elements from the selected items
  /// Only works with the liveUpdateValues set to true
  ///
  final Function(List<MultiSelectNestedItem>)? setSelectedValues;

  ///
  /// Set to true if you want a live update of the values
  /// Be careful because it will trigger e rebuild on every
  /// added or removed element from the selectedValues
  /// which remove the smooth effect from the dropdown container.
  ///
  final bool liveUpdateValues;

  ///
  /// Add a partial check to the parent when one of his child is selected
  /// Be careful this works only with not multi hierarchical child
  ///
  final bool checkParentWhenChildIsSelected;

  ///
  /// Use this controller to get access to internal state of the Multiselect
  ///
  final MultiSelectNestedController? controller;

  ///
  /// Padding Dropdown content
  ///
  final EdgeInsets paddingDropdown;

  ///
  /// Padding Row Selected Items
  ///
  final EdgeInsets paddingSelectedItems;

  ///
  /// Set to true to use an Animated container which can accept Curve's effects
  ///
  final bool isAnimatedContainer;

  ///
  /// Customize the effect of the animated container
  ///
  final Curve effectAnimatedContainer;

  ///
  /// Duration of the Effect of the Animated Container
  ///
  final Duration durationEffect;

  ///
  /// Height of the Animated Container
  /// This value is only read with the Animated Container set to true because it requires a specific height to work.
  /// If it is not set, will be used the default height as value.
  ///
  final double heightDropdownContainer;

  ///
  /// Overwrite the default height of the animated container
  ///
  final double heightDropdownContainerDefault;

  ///
  /// Background Color of the Collapsible Dropdown
  ///
  final Color dropdownContainerColor;

  ///
  /// Background Color of the Selected Items
  ///
  final Color selectedItemColor;

  ///
  /// Color of the divider between the selected items
  ///
  final Color selectedItemDividerColor;

  ///
  /// Color of icon when items are collapsed
  ///
  final Color collapsedIconColor;

  ///
  /// Color of the row of the selected items
  ///
  final Color selectedItemsRowColor;

  ///
  /// Text to display in case of no items are provided
  ///
  final String noItemsText;

  final String noItemSelect;

  ///
  /// Text Style of noItemsText
  ///
  final TextStyle noItemsTextStyle;

  ///
  /// Text Style of the labels inside the dropdown
  ///
  final TextStyle styleDropdownItemName;

  const MultiSelectNested({
    super.key,
    required this.options,
    this.controller,
    this.setSelectedValues,
    this.selectedValues = const <MultiSelectNestedItem>[],
    this.isAnimatedContainer = false,
    this.liveUpdateValues = false,
    this.checkParentWhenChildIsSelected = false,
    this.paddingDropdown = const EdgeInsets.all(8),
    this.paddingSelectedItems = const EdgeInsets.all(8),
    this.effectAnimatedContainer = Curves.fastOutSlowIn,
    this.durationEffect = const Duration(seconds: 1),
    this.heightDropdownContainer = 0,
    this.heightDropdownContainerDefault = 200,
    this.dropdownContainerColor = MultiSelectNestedColors.SECONDARY_LIGHT_COLOR,
    this.collapsedIconColor = MultiSelectNestedColors.PRIMARY,
    this.selectedItemColor = MultiSelectNestedColors.TERTIARY_COLOR,
    this.selectedItemDividerColor = MultiSelectNestedColors.SECONDARY_COLOR,
    this.noItemsText = 'لايوجد عنصر مُختار...',
    this.selectedItemsRowColor = MultiSelectNestedColors.SECONDARY_LIGHT_COLOR,
    this.noItemsTextStyle = const TextStyle(
      fontSize: 12,
      color: MultiSelectNestedColors.PRIMARY_LIGHT_COLOR_01,
    ),
    this.styleDropdownItemName = const TextStyle(
      fontSize: 15,
      color: MultiSelectNestedColors.PRIMARY,
    ), required this.validationTriggered, required this.noItemSelect,
  });

  @override
  State<MultiSelectNested> createState() => _MultiSelectNestedState();
}
class _MultiSelectNestedState extends State<MultiSelectNested> {
  bool isExpanded = false;
  late double _height;
  final List<MultiSelectNestedItem> _localSelectedOptions = [];
  final Set<MultiSelectNestedItem> _checkedParent = <MultiSelectNestedItem>{};
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _height = widget.heightDropdownContainer;
    _focusNode = FocusNode();

    _localSelectedOptions.addAll(widget.selectedValues);
    if (widget.controller != null) {
      widget.controller!.getSelectedItems = getSelectedItems;
      widget.controller!.expandContainer = expandContainer;
      widget.controller!.clearValues = clearValues;
      widget.controller!.validateSelection = validateSelection;
    }

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        isExpanded = false;
        _height = 0;
        _removeOverlay();
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 2.0,
          child: Container(
            padding: widget.paddingDropdown,
            color: widget.dropdownContainerColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300, // Set a maximum height
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildContentDropdown(widget.options, 0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  List<MultiSelectNestedItem> getSelectedItems() {
    return _localSelectedOptions;
  }

  void clearValues() {
    setState(() {
      for (MultiSelectNestedItem element in _localSelectedOptions) {
        element.setSelected(false);
      }
      _localSelectedOptions.clear();
      _checkedParent.clear();
      updateValues();
    });
  }

  void removeSelectedItem(String label) {
    setState(() {
      _localSelectedOptions.removeWhere((MultiSelectNestedItem value) => value.name == label);
      updateValues();
    });
  }

  void updateValues() {
    if (widget.liveUpdateValues) {
      widget.setSelectedValues!(_localSelectedOptions);
    }
  }

  void expandContainer() {
    setState(() {
      isExpanded = !isExpanded;

      if (isExpanded) {
        _height = widget.heightDropdownContainer > 0
            ? widget.heightDropdownContainer
            : widget.heightDropdownContainerDefault;
        _focusNode.requestFocus();
        _createOverlay();
      } else {
        _height = 0;
        _removeOverlay();
      }
    });
  }

  bool validateSelection() {
    return _localSelectedOptions.isNotEmpty;
  }

  void _selectItem(MultiSelectNestedItem item) {
    setState(() {
      if (_localSelectedOptions.isNotEmpty) {
        _localSelectedOptions.first.setSelected(false);
        _localSelectedOptions.clear();
      }
      item.setSelected(true);
      _localSelectedOptions.add(item);

      isExpanded = false;
      _height = 0;
      _removeOverlay();
    });
    updateValues();
  }

  void onChangeMultiChildrenElement(List<MultiSelectNestedItem> options, MultiSelectNestedItem item) {
    setState(() {
      _selectItem(item);
    });
  }

  Future<void> _onChangeElement(List<MultiSelectNestedItem> options, MultiSelectNestedItem item, int level) async {
    setState(() {
      _selectItem(item);
    });
  }

  List<Widget> _buildChildren(List<MultiSelectNestedItem> children, int level) {
    if (children.isEmpty) {
      return _buildContentDropdown(children, 0);
    } else {
      return _buildContentDropdown(children, ++level);
    }
  }

  List<Widget> _buildContentDropdown(List<MultiSelectNestedItem> options, int level) {
    return options.map((MultiSelectNestedItem item) {
      if (item.children.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.only(left: level * 10),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Set dividerColor to transparent
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(0),
              iconColor: widget.collapsedIconColor,
              leading: Radio<MultiSelectNestedItem>(
                value: item,
                groupValue: _localSelectedOptions.isEmpty ? null : _localSelectedOptions.first,
                onChanged: (MultiSelectNestedItem? value) => onChangeMultiChildrenElement(options, item),
              ),
              title: Text(
                item.name,
                style: widget.styleDropdownItemName,
              ),
              children: _buildChildren(item.children, level),
            ),
          ),
        );
      } else {
        return Padding(
          padding: EdgeInsets.only(left: level * 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(
              item.name,
              style: widget.styleDropdownItemName,
            ),
            leading: Radio<MultiSelectNestedItem>(
              value: item,
              groupValue: _localSelectedOptions.isEmpty ? null : _localSelectedOptions.first,
              onChanged: (MultiSelectNestedItem? value) => _onChangeElement(
                options,
                item,
                level,
              ),
            ),
          ),
        );
      }
    }).toList();
  }

  Widget _isEmptyItem() {
    return Text(
      widget.noItemSelect,
      style: const TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (isExpanded) {
          _focusNode.unfocus(); // Unfocus the node when tapped outside
        }
      },
      child: FocusScope(
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              _handleFocusChange();
            }
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                if (isExpanded) {
                  _focusNode.requestFocus();
                }
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.validationTriggered && !widget.controller!.validateSelection()
                          ? Colors.red
                          : MultiSelectNestedColors.PRIMARY_LIGHT_COLOR,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        color: widget.selectedItemsRowColor,
                        child: Padding(
                          padding: widget.paddingSelectedItems,
                          child: Row(
                            children: [
                              Expanded(
                                child: _localSelectedOptions.isNotEmpty
                                    ? Wrap(
                                  spacing: 10.0,
                                  runSpacing: 8.0,
                                  children: _localSelectedOptions.map(
                                        (item) => SelectedValueItem(
                                      label: item.name,
                                      gestureTapCallback: () => removeSelectedItem(item.name),
                                      backgroundColor: widget.selectedItemColor,
                                      dividerColor: widget.selectedItemDividerColor,
                                    ),
                                  ).toList(),
                                )
                                    : Text(
                                  widget.noItemsText,
                                  style: widget.noItemsTextStyle,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  expandContainer();
                                  _focusNode.requestFocus();
                                },
                                child: isExpanded
                                    ? const Icon(Icons.arrow_drop_up)
                                    : const Icon(Icons.arrow_drop_down),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.validationTriggered && !widget.controller!.validateSelection())
                  _isEmptyItem(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}