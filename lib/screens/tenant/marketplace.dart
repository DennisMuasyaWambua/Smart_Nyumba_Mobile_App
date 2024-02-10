import 'package:flutter/material.dart';

import '../../widgets/tenant/marketplace_item_tile.dart';

class MarketPlace extends StatelessWidget {
  static const routeName = "/marketplace";

  const MarketPlace({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              MarketPlaceItemTile(
                tileTitle: "Sewing",
                serviceCount: "2",
                children: [
                  ListTile(
                    title: const Text("Sharon Sewing Services"),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                    ),
                  ),
                  ListTile(
                    title: const Text("John's Tailoring"),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                    ),
                  ),
                ],
              ),
              MarketPlaceItemTile(
                tileTitle: "Baking",
                serviceCount: "1",
                children: [
                  ListTile(
                    title: const Text("Terry Cakes and Scones"),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                    ),
                  ),
                ],
              ),
              MarketPlaceItemTile(
                tileTitle: "Child Care",
                serviceCount: "2",
                children: [
                  ListTile(
                    title: const Text("OneStop ChildCare"),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                    ),
                  ),
                  ListTile(
                    title: const Text("Nanny for the Kids"),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
