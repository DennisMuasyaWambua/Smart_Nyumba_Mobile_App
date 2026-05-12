import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/colors.dart';

class RepairRequestsScreen extends StatefulWidget {
  static const routeName = "/repair-requests";

  const RepairRequestsScreen({super.key});

  @override
  State<RepairRequestsScreen> createState() => _RepairRequestsScreenState();
}

class _RepairRequestsScreenState extends State<RepairRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Placeholder data - will be replaced with actual API calls
  final List<Map<String, dynamic>> pendingRequests = [];
  final List<Map<String, dynamic>> inProgressRequests = [];
  final List<Map<String, dynamic>> completedRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestList(pendingRequests, 'pending'),
                  _buildRequestList(inProgressRequests, 'in_progress'),
                  _buildRequestList(completedRequests, 'completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requests, String status) {
    if (requests.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request, status);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String status) {
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
        onTap: () {
          // Navigate to repair details
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Repair details screen coming soon'),
            ),
          );
        },
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
                      request['title'] ?? 'Repair Request',
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
                    request['house'] ?? 'Block A - House 1',
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request['description'] ?? 'No description provided',
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
                        request['date'] ?? 'Today',
                        style: GoogleFonts.hind(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (status == 'pending')
                    ElevatedButton(
                      onPressed: () {
                        // Mark as in progress
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Marking request as in progress'),
                          ),
                        );
                      },
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
                      onPressed: () {
                        // Mark as completed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Marking request as completed'),
                          ),
                        );
                      },
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
