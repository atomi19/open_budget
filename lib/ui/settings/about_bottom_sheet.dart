import 'package:flutter/material.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutBottomSheet extends StatelessWidget {
  final PackageInfo appInfo;
  final Function(Uri url) openWebsite;

  const AboutBottomSheet({
    super.key,
    required this.appInfo,
    required this.openWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // header
        CustomHeader(
          children: [
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ), 
            const CustomHeaderTitle(title: 'About'),
            const SizedBox(width: 48),
          ],
        ),
        // content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              spacing: 10,
              children: [
                // app icon
                Image.asset(
                  width: 150,
                  'assets/icon/openbudget_icon.png'
                ),
                // app name
                const Text(
                  'Open Budget',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // app version container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    appInfo.version,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                // github link
                CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer, 
                  title: 'GitHub',
                  trailing: const Icon(Icons.launch),
                  onTap: () => openWebsite(Uri.parse('https://github.com/atomi19/open_budget')),
                ),
                // license link
                CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer, 
                  title: 'License',
                  trailing: const Icon(Icons.launch),
                  onTap: () => openWebsite(Uri.parse('https://github.com/atomi19/open_budget/blob/main/LICENSE.txt')),
                ),
                // open source licenses used in project 
                CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer, 
                  title: 'Open Source Licenses',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    showLicensePage(
                      context: context,
                      applicationName: 'Open Budget',
                    );
                  }
                ),
              ],
            ),
          )
        )
      ],
    );
  }
}