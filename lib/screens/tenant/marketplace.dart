import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/utils/constants/colors.dart';

import '../../utils/models/marketplace_item.dart';
import '../../utils/providers/marketplace_provider.dart';
import '../../widgets/tenant/marketplace_item_tile.dart';

class MarketPlace extends StatefulWidget {
  static const routeName = "/marketplace";

  const MarketPlace({super.key});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().fetchPublishedGoods();
    });
  }

  void _showItemDetails(MarketplaceItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(item.description),
            if (item.offer.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.local_offer, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.offer)),
                ],
              ),
            ],
            if (item.ownerEmail != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.ownerEmail!)),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddGoodsDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final offerController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Offer Goods or Services'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g. Sewing, Baking)',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: offerController,
                decoration: const InputDecoration(labelText: 'Any offer?'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and description are required'),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              final error =
                  await context.read<MarketplaceProvider>().addGoods(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        quantity: quantityController.text.trim().isEmpty
                            ? '1'
                            : quantityController.text.trim(),
                        offer: offerController.text.trim().isEmpty
                            ? 'None'
                            : offerController.text.trim(),
                        category: categoryController.text.trim().isEmpty
                            ? 'General'
                            : categoryController.text.trim(),
                      );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error ?? 'Goods added to the marketplace'),
                  backgroundColor: error == null ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoodsDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: lightGrey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchPublishedGoods,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final grouped = provider.itemsByCategory;

          if (grouped.isEmpty) {
            return const Center(
              child: Text(
                "No Services Available",
                style: TextStyle(
                  color: lightGrey,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchPublishedGoods,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: grouped.entries.map((entry) {
                    return MarketPlaceItemTile(
                      tileTitle: entry.key,
                      serviceCount: entry.value.length.toString(),
                      children: entry.value
                          .map(
                            (item) => ListTile(
                              title: Text(item.name),
                              subtitle: item.offer.isNotEmpty &&
                                      item.offer != 'None'
                                  ? Text(item.offer)
                                  : null,
                              trailing: IconButton(
                                onPressed: () => _showItemDetails(item),
                                icon: const Icon(Icons.info_outline),
                              ),
                              onTap: () => _showItemDetails(item),
                            ),
                          )
                          .toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
