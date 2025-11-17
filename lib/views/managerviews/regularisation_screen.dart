import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
import 'package:attendanceapp/models/user_model.dart';
import 'package:attendanceapp/views/managerviews/leavescreen.dart';
import 'package:attendanceapp/views/managerviews/manager_dashboard_screen.dart';
import 'package:attendanceapp/views/managerviews/timeline.dart';
import 'package:flutter/material.dart';
import 'package:attendanceapp/core/view_models/theme_view_model.dart';

class RegularisationScreen extends StatelessWidget {
  final User user; // ✅ User parameter add karo

  const RegularisationScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Regularisation',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        backgroundColor: AppColors.grey300,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.secondary.withOpacity(0.1),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Stats
              _buildHeaderStats(),
              const SizedBox(height: 20),

              // Quick Actions
              // _buildQuickActions(),
              // const SizedBox(height: 20),

              // Pending Requests
              _buildPendingRequests(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: 1,
        onTabChanged: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerDashboardScreen(user: user),
              ), // ✅ Yahan user use karo
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaveScreen(user: user),
              ), // ✅ User pass karo
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimelineScreen(user: user),
              ), // ✅ User pass karo
            );
          }
        },
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Column(
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.pending_actions_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 10),
            const Text(
              'Regularisation Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending',
                '8',
                AppColors.warning,
                Icons.pending_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Approved',
                '15',
                AppColors.success,
                Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Rejected',
                '3',
                AppColors.error,
                Icons.cancel_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                'New Request',
                Icons.add_circle_outline_rounded,
                AppColors.primary,
              ),
              _buildActionButton(
                'My Requests',
                Icons.history_rounded,
                AppColors.success,
              ),
              _buildActionButton(
                'Team Requests',
                Icons.people_alt_rounded,
                AppColors.warning,
              ),
              _buildActionButton(
                'Policy',
                Icons.description_rounded,
                AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPendingRequests() {
    final regularisationRequests = [
      RegularisationRequest(
        employeeName: 'Raj Sharma',
        date: '15 Mar 2024',
        type: 'Late Arrival',
        reason: 'Traffic jam due to accident',
        inTime: '10:30 AM',
        outTime: '7:00 PM',
        status: 'pending',
        profileColor: AppColors.primary,
      ),
      RegularisationRequest(
        employeeName: 'Priya Singh',
        date: '16 Mar 2024',
        type: 'Early Departure',
        reason: 'Medical appointment',
        inTime: '9:00 AM',
        outTime: '4:00 PM',
        status: 'approved',
        profileColor: AppColors.success,
      ),
      RegularisationRequest(
        employeeName: 'Amit Kumar',
        date: '17 Mar 2024',
        type: 'Missing Punch',
        reason: 'Forgot to punch out',
        inTime: '9:15 AM',
        outTime: '6:45 PM',
        status: 'pending',
        profileColor: AppColors.warning,
      ),
      RegularisationRequest(
        employeeName: 'Neha Patel',
        date: '18 Mar 2024',
        type: 'Work From Home',
        reason: 'Family emergency',
        inTime: '9:30 AM',
        outTime: '6:30 PM',
        status: 'rejected',
        profileColor: AppColors.secondary,
      ),
      RegularisationRequest(
        employeeName: 'Suresh Verma',
        date: '19 Mar 2024',
        type: 'Late Arrival',
        reason: 'Vehicle breakdown',
        inTime: '11:00 AM',
        outTime: '7:30 PM',
        status: 'pending',
        profileColor: AppColors.error,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pending_actions_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                'Pending Approvals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${regularisationRequests.where((req) => req.status == 'pending').length} Pending',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...regularisationRequests.map(
            (request) => _buildRequestCard(request),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RegularisationRequest request) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (request.status) {
      case 'approved':
        statusColor = AppColors.success;
        statusText = 'APPROVED';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'REJECTED';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusText = 'PENDING';
        statusIcon = Icons.pending_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Profile Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: request.profileColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(request.employeeName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.employeeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.date,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Request Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.work_history_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      request.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request.inTime} - ${request.outTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  request.reason,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons (for pending requests)
          if (request.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(color: AppColors.success),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
  }
}

class RegularisationRequest {
  final String employeeName;
  final String date;
  final String type;
  final String reason;
  final String inTime;
  final String outTime;
  final String status;
  final Color profileColor;

  RegularisationRequest({
    required this.employeeName,
    required this.date,
    required this.type,
    required this.reason,
    required this.inTime,
    required this.outTime,
    required this.status,
    required this.profileColor,
  });
}

// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/views/managerviews/leavescreen.dart';
// import 'package:attendanceapp/views/managerviews/manager_dashboard_screen.dart';
// import 'package:attendanceapp/views/managerviews/timeline.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';

// class RegularisationScreen extends StatelessWidget {
//   final User user; // ✅ User parameter add karo

//   const RegularisationScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text(
//           'Regularisation',
//           style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
//         ),
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           // ✅ Gradient decoration add kiya
//           gradient: RadialGradient(
//             center: Alignment.topLeft,
//             radius: 2.0,
//             colors: [
//               QuickAIColors.cyber.primary.withOpacity(0.3),
//               QuickAIColors.cyber.secondary.withOpacity(0.2),
//               Colors.black,
//             ],
//             stops: const [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             children: [
//               // Header Stats
//               _buildHeaderStats(),
//               const SizedBox(height: 20),

//               // Quick Actions
//               _buildQuickActions(),
//               const SizedBox(height: 20),

//               // Pending Requests
//               _buildPendingRequests(),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: 1,
//         onTabChanged: (index) {
//           if (index == 0) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ManagerDashboardScreen(user: user),
//               ), // ✅ Yahan user use karo
//               (route) => false,
//             );
//           } else if (index == 2) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => LeaveScreen(user: user),
//               ), // ✅ User pass karo
//             );
//           } else if (index == 3) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TimelineScreen(user: user),
//               ), // ✅ User pass karo
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildHeaderStats() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Header
//           Row(
//             children: [
//               Icon(
//                 Icons.pending_actions_rounded,
//                 color: AppColors.primary,
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Regularisation Overview',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Stats Cards
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'Pending',
//                   '8',
//                   Colors.orange.shade600,
//                   Icons.pending_rounded,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard(
//                   'Approved',
//                   '15',
//                   Colors.green.shade600,
//                   Icons.check_circle_rounded,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard(
//                   'Rejected',
//                   '3',
//                   Colors.red.shade600,
//                   Icons.cancel_rounded,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String count,
//     Color color,
//     IconData icon,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w800,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 24),
//               const SizedBox(width: 10),
//               const Text(
//                 'Quick Actions',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildActionButton(
//                 'New Request',
//                 Icons.add_circle_outline_rounded,
//                 Colors.blue.shade600,
//               ),
//               _buildActionButton(
//                 'My Requests',
//                 Icons.history_rounded,
//                 Colors.green.shade600,
//               ),
//               _buildActionButton(
//                 'Team Requests',
//                 Icons.people_alt_rounded,
//                 Colors.orange.shade600,
//               ),
//               _buildActionButton(
//                 'Policy',
//                 Icons.description_rounded,
//                 Colors.purple.shade600,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(String label, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade700,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildPendingRequests() {
//     final regularisationRequests = [
//       RegularisationRequest(
//         employeeName: 'Raj Sharma',
//         date: '15 Mar 2024',
//         type: 'Late Arrival',
//         reason: 'Traffic jam due to accident',
//         inTime: '10:30 AM',
//         outTime: '7:00 PM',
//         status: 'pending',
//         profileColor: Colors.blue.shade600,
//       ),
//       RegularisationRequest(
//         employeeName: 'Priya Singh',
//         date: '16 Mar 2024',
//         type: 'Early Departure',
//         reason: 'Medical appointment',
//         inTime: '9:00 AM',
//         outTime: '4:00 PM',
//         status: 'approved',
//         profileColor: Colors.green.shade600,
//       ),
//       RegularisationRequest(
//         employeeName: 'Amit Kumar',
//         date: '17 Mar 2024',
//         type: 'Missing Punch',
//         reason: 'Forgot to punch out',
//         inTime: '9:15 AM',
//         outTime: '6:45 PM',
//         status: 'pending',
//         profileColor: Colors.orange.shade600,
//       ),
//       RegularisationRequest(
//         employeeName: 'Neha Patel',
//         date: '18 Mar 2024',
//         type: 'Work From Home',
//         reason: 'Family emergency',
//         inTime: '9:30 AM',
//         outTime: '6:30 PM',
//         status: 'rejected',
//         profileColor: Colors.purple.shade600,
//       ),
//       RegularisationRequest(
//         employeeName: 'Suresh Verma',
//         date: '19 Mar 2024',
//         type: 'Late Arrival',
//         reason: 'Vehicle breakdown',
//         inTime: '11:00 AM',
//         outTime: '7:30 PM',
//         status: 'pending',
//         profileColor: Colors.red.shade600,
//       ),
//     ];

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.pending_actions_rounded,
//                 color: AppColors.primary,
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Pending Approvals',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${regularisationRequests.where((req) => req.status == 'pending').length} Pending',
//                   style: TextStyle(
//                     color: Colors.orange.shade700,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...regularisationRequests.map(
//             (request) => _buildRequestCard(request),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequestCard(RegularisationRequest request) {
//     Color statusColor;
//     String statusText;
//     IconData statusIcon;

//     switch (request.status) {
//       case 'approved':
//         statusColor = Colors.green;
//         statusText = 'APPROVED';
//         statusIcon = Icons.check_circle_rounded;
//         break;
//       case 'rejected':
//         statusColor = Colors.red;
//         statusText = 'REJECTED';
//         statusIcon = Icons.cancel_rounded;
//         break;
//       default:
//         statusColor = Colors.orange;
//         statusText = 'PENDING';
//         statusIcon = Icons.pending_rounded;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row
//           Row(
//             children: [
//               // Profile Avatar
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: request.profileColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     _getInitials(request.employeeName),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),

//               // Employee Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       request.employeeName,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       request.date,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Status Badge
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: statusColor.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(statusIcon, size: 12, color: statusColor),
//                     const SizedBox(width: 4),
//                     Text(
//                       statusText,
//                       style: TextStyle(
//                         color: statusColor,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           // Request Details
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.work_history_rounded,
//                       size: 14,
//                       color: Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       request.type,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.access_time_rounded,
//                       size: 12,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${request.inTime} - ${request.outTime}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   request.reason,
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//                 ),
//               ],
//             ),
//           ),

//           // Action Buttons (for pending requests)
//           if (request.status == 'pending') ...[
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.green,
//                       side: BorderSide(color: Colors.green.shade300),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('Approve'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.red,
//                       side: BorderSide(color: Colors.red.shade300),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('Reject'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   String _getInitials(String name) {
//     return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
//   }
// }

// class RegularisationRequest {
//   final String employeeName;
//   final String date;
//   final String type;
//   final String reason;
//   final String inTime;
//   final String outTime;
//   final String status;
//   final Color profileColor;

//   RegularisationRequest({
//     required this.employeeName,
//     required this.date,
//     required this.type,
//     required this.reason,
//     required this.inTime,
//     required this.outTime,
//     required this.status,
//     required this.profileColor,
//   });
// }
