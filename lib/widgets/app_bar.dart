import 'package:flutter/material.dart';
import '../widgets/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final double elevation;
  final double borderRadius;
  final IconButton? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.elevation = 4,
    this.borderRadius = 20,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(AppConstants.appBarHieght(context)),
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
          child: AppBar(
            leading: leading,
            title: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            ),
            backgroundColor: AppColors.primaryColor,
            centerTitle: true,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}