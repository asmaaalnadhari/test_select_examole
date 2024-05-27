import 'package:flutter/material.dart';

import '../constants/colors.dart';

class SelectedValueItem extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color dividerColor;
  final GestureTapCallback gestureTapCallback;

  const SelectedValueItem({
    Key? key,
    required this.label,
    required this.gestureTapCallback,
    required this.backgroundColor,
    required this.dividerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(

          color: backgroundColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: MultiSelectNestedColors.PRIMARY_LIGHT_COLOR
            ),
          borderRadius: BorderRadius.circular(20),

        )
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label,)),
            VerticalDivider(
              color: dividerColor,
              thickness: 2,
            ),
            GestureDetector(
              onTap: gestureTapCallback,
              child: const Icon(
                Icons.close,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
