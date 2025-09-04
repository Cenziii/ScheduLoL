import 'package:flutter/material.dart';
import 'package:lol_competitive/about_page.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final bool updateAvailable;
  final String apkUrl;
  final void Function(String url) onDownloadPressed;

  const HomeHeader({
    super.key,
    required this.theme,
    required this.updateAvailable,
    required this.apkUrl,
    required this.onDownloadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'ScheduLoL',
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(25),
        ),
      ),
      elevation: 1.0,
      centerTitle: true,
      leading: updateAvailable
    ? Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            color: theme.colorScheme.surface,
            tooltip: 'Download new .apk file',
            onPressed: () => onDownloadPressed(apkUrl),
          ),
          // Badge in alto a destra
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: const Text(
                '1', // oppure vuoto "" se vuoi solo il pallino
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      )
    : null,
      iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      actions: [
        IconButton(
          icon: Icon(Icons.info, color: theme.colorScheme.surface),
          tooltip: 'About',
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const AboutPage()));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
