import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/models/repair.dart';
import '../../utils/providers/repairs_provider.dart';

class RepairRequestsScreen extends StatefulWidget {
  static const routeName = "/repair-requests";

  const RepairRequestsScreen({super.key});

  @override
  State<RepairRequestsScreen> createState() => _RepairRequestsScreenState();
}

class _RepairRequestsScreenState extends State<RepairRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepairsProvider>().fetchAllRepairs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(Repair repair, String newStatus) async {
    final error =
        await context.read<RepairsProvider>().updateStatus(repair.id, newStatus);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ??
            (newStatus == 'in_progress'
                ? 'Repair marked as in progress'
                : 'Repair marked as completed')),
        backgroundColor: error == null ? Colors.green : Colors.red,
      ),
    );
  }

  void _showRepairDetails(Repair repair) {
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
              repair.brokenProperty,
              style: GoogleFonts.hind(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: royalBlue,
              ),
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.home, repair.location),
            const SizedBox(height: 8),
            _detailRow(Icons.person, repair.email),
            if (repair.createdAt != null) ...[
              const SizedBox(height: 8),
              _detailRow(
                Icons.calendar_today,
                DateFormat('dd MMM yyyy, HH:mm').format(repair.createdAt!),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Description',
              style: GoogleFonts.hind(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              repair.description,
              style: GoogleFonts.hind(fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.hind(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Repair Requests',
                style: GoogleFonts.hind(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: royalBlue,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: royalBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: royalBlue,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'In Progress'),
                Tab(text: 'Completed'),
              ],
            ),
            Expanded(
              child: Consumer<RepairsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.repairs.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null && provider.repairs.isEmpty) {
                    return _buildErrorState(provider);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestList(provider.pendingRepairs, 'pending'),
                      _buildRequestList(
                          provider.inProgressRepairs, 'in_progress'),
                      _buildRequestList(
                          provider.completedRepairs, 'completed'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(RepairsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.fetchAllRepairs,
            style: ElevatedButton.styleFrom(backgroundColor: royalBlue),
            child: Text(
              'Retry',
              style: GoogleFonts.hind(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<Repair> requests, String status) {
    return RefreshIndicator(
      onRefresh: () => context.read<RepairsProvider>().fetchAllRepairs(),
      child: requests.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: _buildEmptyState(status),
                ),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(requests[index], status);
              },
            ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            status == 'pending'
                ? Icons.pending_actions
                : status == 'in_progress'
                    ? Icons.build
                    : Icons.check_circle,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            status == 'pending'
                ? 'No pending requests'
                : status == 'in_progress'
                    ? 'No requests in progress'
                    : 'No completed requests',
            style: GoogleFonts.hind(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Repair requests will appear here',
            style: GoogleFonts.hind(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Repair repair, String status) {
    Color statusColor = status == 'pending'
        ? Colors.orange
        : status == 'in_progress'
            ? Colors.blue
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showRepairDetails(repair),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      repair.brokenProperty,
                      style: GoogleFonts.hind(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status == 'pending'
                          ? 'Pending'
                          : status == 'in_progress'
                              ? 'In Progress'
                              : 'Completed',
                      style: GoogleFonts.hind(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.home,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repair.location,
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                repair.description,
                style: GoogleFonts.hind(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        repair.createdAt != null
                            ? DateFormat('dd MMM yyyy')
                                .format(repair.createdAt!)
                            : 'Date unavailable',
                        style: GoogleFonts.hind(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (status == 'pending')
                    ElevatedButton(
                      onPressed: () => _updateStatus(repair, 'in_progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Start Work',
                        style: GoogleFonts.hind(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (status == 'in_progress')
                    ElevatedButton(
                      onPressed: () => _updateStatus(repair, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Complete',
                        style: GoogleFonts.hind(
                          fontSize: 12,
                          color: Colors.white,
                        ),
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
