import 'package:app_team1/widgets/utils/app_color.dart';
import 'package:flutter/material.dart';
import '../../utils/app_constant.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String _title;
  final List<Widget>? _actions;
  final double _elevation;
  final double _borderRadius;
  final IconButton? _leading;

  const CustomAppBar({
    super.key,
    required String title,
    List<Widget>? actions,
    double elevation = 4,
    double borderRadius = 20,
    IconButton? leading,
  })  : _title = title,
        _actions = actions,
        _elevation = elevation,
        _borderRadius = borderRadius,
        _leading = leading;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(AppConstant.appBarHieght(context)),
      child: Material(
        elevation: _elevation,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(_borderRadius)),
        child: ClipRRect(
          borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(_borderRadius)),
          child: AppBar(
            leading: _leading,
            title: Text(
              _title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w300),
            ),
            backgroundColor: AppColor.primaryColor,
            centerTitle: true,
            actions: _actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}