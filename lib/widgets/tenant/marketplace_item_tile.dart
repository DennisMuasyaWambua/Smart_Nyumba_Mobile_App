import 'package:flutter/material.dart';

class MarketPlaceItemTile extends StatelessWidget {
  final String tileTitle;
  final String serviceCount;
  final List<Widget> children;

  const MarketPlaceItemTile({
    super.key,
    required this.tileTitle,
    required this.serviceCount,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: Colors.white,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTileTheme(
              data: const ExpansionTileThemeData(
                textColor: Colors.black,
                iconColor: Colors.black,
              ),
              child: ExpansionTile(
                title: Text(tileTitle),
                trailing: Text(serviceCount),
                children: children,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
