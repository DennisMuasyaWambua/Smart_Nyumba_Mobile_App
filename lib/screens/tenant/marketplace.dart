import 'package:flutter/material.dart';
import 'package:smart_nyumba/utils/constants/colors.dart';

const services = [
  {
    "name": "Sewing Services",
    "description":
        "I provide sewing services including cloth repairs, making costumes and creating new garments for all ocassions.",
    "image_src":
        "https://s3.envato.com/files/229420162/Colorful%20threads%20for%20needlework13G.jpg",
  },
  {
    "name": "Baking Services",
    "description":
        "I bake cakes, pastries and desserts at an affordable price.",
    "image_src": "https://www.imarcgroup.com/blogs/files/c196a056-e13c-4316-9b6f-a471d5a4a27aphoto-1608198093002-ad4e005484ec.webp",
  },
  {
    "name": "Child Care Services",
    "description":
        "I provid child care to parents who are busy and need someone to take car eof their children.",
    "image_src": "https://dcf.wisconsin.gov/files/images/400/illustration-children-garden.png",
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
            children: services
                .map(
                  (service) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            padding: EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              // color: lightGold,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Image.network(
                              service['image_src']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            height: 120,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  service["description"]!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
