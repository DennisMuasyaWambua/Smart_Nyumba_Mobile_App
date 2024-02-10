import 'package:flutter/material.dart';

import '../../widgets/tenant/marketplace_item_tile.dart';

const List<Map<String, dynamic>> services = [
  {
    "category": "Sewing",
    "item_count": "2",
    "items": [
      {
        "name": "Sharon Sewing Services",
      },
      {
        "name": "John's Tailoring",
      },
    ],
  },
  {
    "category": "Baking",
    "item_count": "1",
    "items": [
      {
        "name": "Terry Cakes and Scones",
      },
    ],
  },
  {
    "category": "Child Care",
    "item_count": "2",
    "items": [
      {
        "name": "OneStop ChildCare",
      },
      {
        "name": "Nanny for the Kids",
      },
    ],
  },
];

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
            children: services.map((service) {
              List itemList = service['items'];

              return MarketPlaceItemTile(
                tileTitle: service['category'],
                serviceCount: service['item_count'],
                children: itemList
                    .map(
                      (value) => ListTile(
                        title: Text(value['name']),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.phone),
                        ),
                      ),
                    )
                    .toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
