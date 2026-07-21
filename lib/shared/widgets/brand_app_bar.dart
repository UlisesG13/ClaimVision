import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      foregroundColor: context.textPrimaryColor,
      elevation: 0,
      centerTitle: false,
      leading: leading,
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/images/logo.svg',
            width: 24,
            height: 24,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: title ?? const SizedBox.shrink(),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
