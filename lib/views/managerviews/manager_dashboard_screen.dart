import 'dart:async';

import 'package:attendanceapp/views/managerviews/leavescreen.dart';
import 'package:attendanceapp/views/managerviews/regularisation_screen.dart';
import 'package:attendanceapp/views/managerviews/timeline.dart';
import 'package:attendanceapp/widgets/mangerwidgets/manager_drawer.dart';
import 'package:attendanceapp/widgets/mangerwidgets/matrix_counter.dart';
import 'package:attendanceapp/widgets/mangerwidgets/presentdashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendanceapp/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
import 'package:attendanceapp/models/user_model.dart';
import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
import 'package:attendanceapp/widgets/mangerwidgets/attendance_timer.dart';
import 'package:attendanceapp/widgets/mangerwidgets/dashboard_cards.dart';

class ManagerDashboardScreen extends StatefulWidget {
  final User user;

  const ManagerDashboardScreen({super.key, required this.user});

  @override
  _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
    with TickerProviderStateMixin {
  String _currentTime = '';
  Timer? _timer;
  late TabController _tabController;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Notification variables
  int _notificationCount = 3;
  bool _showNotificationBadge = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAnimations();
    _initializeDashboard();
    _startLiveTime();
  }

  // Navigation handle करने का method add करें
  void _handleTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegularisationScreen(user: widget.user),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeaveScreen(user: widget.user)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimelineScreen(user: widget.user),
        ),
      );
    } else {
      _tabController.animateTo(index);
    }
  }

  void _startLiveTime() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = _getLiveTime();
      });
    }
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _initializeDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ManagerDashboardViewModel>(
        context,
        listen: false,
      );
      viewModel.initializeDashboard(widget.user);
    });
  }

  void _showNotifications(BuildContext context) {
    setState(() {
      _notificationCount = 0;
      _showNotificationBadge = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    final notifications = [
      {
        'title': 'Team Meeting',
        'message': 'Scheduled for 3:00 PM today',
        'time': '10 min ago',
        'read': false,
      },
      {
        'title': 'Report Generated',
        'message': 'Monthly attendance report is ready',
        'time': '1 hour ago',
        'read': false,
      },
      {
        'title': 'New Employee',
        'message': 'Rahul joined your team',
        'time': '2 hours ago',
        'read': true,
      },
      {
        'title': 'System Update',
        'message': 'New features available',
        'time': '1 day ago',
        'read': true,
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notification['read'] as bool
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notification['read'] as bool
                          ? Colors.white.withOpacity(0.2)
                          : AppColors.accent.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: notification['read'] as bool
                              ? Colors.transparent
                              : AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['title'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['message'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['time'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Add your logout logic here
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: ManagerDrawer(
        user: widget.user,
        onLogout: () => _showLogoutConfirmation(context),
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
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          // Profile Header
                          _buildProfileHeader(),

                          const SizedBox(height: 5),

                          // Date & Time Section
                          _buildDateTimeSection(),
                          whiteHorizontalLine(),

                          const SizedBox(height: 2),

                          //Present Card Section
                          _buildpresentdashboardCards(),

                          const SizedBox(height: 2),

                          // METRICS COUNTER Cards
                          _buildMetricsCounterCards(),
                          const SizedBox(height: 2),
                          // whiteHorizontalLine(),
                          // whiteHorizontalLine(),
                          // Premium Dashboard Cards
                          _buildDashboardCards(),

                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: _currentIndex,
        onTabChanged: _handleTabChange,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.menu_rounded, color: Colors.white, size: 20),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getUserTypeDisplay(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Notification Icon
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _showNotifications(context),
                ),
              ),
              if (_showNotificationBadge && _notificationCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildDateTimeSection() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     padding: const EdgeInsets.all(20),
  //     // decoration: BoxDecoration(
  //     //   borderRadius: BorderRadius.circular(16),
  //     //   color: Colors.white.withOpacity(0.1),
  //     //   border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
  //     //   boxShadow: [
  //     //     BoxShadow(
  //     //       color: Colors.black.withOpacity(0.2),
  //     //       blurRadius: 10,
  //     //       offset: const Offset(0, 5),
  //     //     ),
  //     //   ],
  //     // ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         // Date and Time
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Date Section
  //               _buildDateTimeItem(
  //                 icon: Icons.calendar_month_rounded,
  //                 title: 'DATE',
  //                 value: _getFormattedDate(),
  //               ),
  //               const SizedBox(height: 16),

  //               // Time Section
  //               _buildDateTimeItem(
  //                 icon: Icons.access_time_filled_rounded,
  //                 title: 'TIME',
  //                 value: _getLiveTime(),
  //                 isLive: true,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDateTimeItem({
  //   required IconData icon,
  //   required String title,
  //   required String value,
  //   bool isLive = false,
  // }) {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 44,
  //         height: 44,
  //         decoration: BoxDecoration(
  //           color: AppColors.primary,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             BoxShadow(
  //               color: AppColors.primary.withOpacity(0.2),
  //               blurRadius: 8,
  //               offset: const Offset(0, 4),
  //             ),
  //           ],
  //         ),
  //         child: Icon(icon, color: Colors.white, size: 20),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: TextStyle(
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.white.withOpacity(0.8),
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               value,
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w700,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       if (isLive)
  //         Container(
  //           width: 8,
  //           height: 8,
  //           decoration: BoxDecoration(
  //             color: AppColors.accent,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildDateTimeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(16),
      //   color: Colors.white.withOpacity(0.1),
      //   border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.2),
      //       blurRadius: 10,
      //       offset: const Offset(0, 5),
      //     ),
      //   ],
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Time Section
                _buildDateTimeItem(value: _getLiveTime(), isLive: true),
                const SizedBox(height: 16),
                // Date Section
                _buildDateTimeItem(value: _getFormattedDate()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeItem({required String value, bool isLive = false}) {
    return Row(
      children: [
        // Container(
        //   width: 44,
        //   height: 44,
        //   decoration: BoxDecoration(
        //     color: AppColors.primary,
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: [
        //       BoxShadow(
        //         color: AppColors.primary.withOpacity(0.2),
        //         blurRadius: 8,
        //         offset: const Offset(0, 4),
        //       ),
        //     ],
        //   ),
        //   // child: Icon(
        //   //   Icons.access_time_filled_rounded,
        //   //   color: Colors.white,
        //   //   size: 20,
        //   // ),
        // ),
        //const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (isLive)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildAttendanceTimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const AttendanceTimerSection(),
    );
  }

  Widget whiteHorizontalLine({
    double height = 1.0,
    double thickness = 1.0,
    Color color = Colors.white,
    double opacity = 0.3,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color.withOpacity(opacity),
            width: thickness,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsCounterCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: MetricsCounter(
        totalAttendance: _calculateDynamicAttendance(),
        teamMembers: _getDynamicTeamSize(),
        projects: _getDynamicProjectCount(),
        timeline: _getCurrentTimeline(),
      ),
    );
  }

  // Helper methods for dynamic data
  int _calculateDynamicAttendance() {
    final now = DateTime.now();
    return (now.day * now.hour) ~/ 2;
  }

  int _getDynamicTeamSize() {
    return 8 + (DateTime.now().day % 5);
  }

  int _getDynamicProjectCount() {
    final now = DateTime.now();
    return 5 + (now.weekday % 3);
  }

  String _getCurrentTimeline() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    return 'Q$quarter ${now.year}';
  }

  Widget _buildDashboardCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const DashboardCardsSection(),
    );
  }

  Widget _buildpresentdashboardCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const PresentDashboardCardSection(),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';
  }

  String _getLiveTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String _getUserTypeDisplay() {
    switch (widget.user.userType.toLowerCase()) {
      case 'manager':
        return 'MANAGER';
      case 'admin':
        return 'ADMIN';
      case 'employee':
        return 'EMPLOYEE';
      case 'supervisor':
        return 'SUPERVISOR';
      default:
        return widget.user.userType.toUpperCase();
    }
  }

  String _getWeekday(int weekday) {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months[month - 1];
  }
}
/* ######################################################################################################################

***********************************************         A I S C R E E N C O D E            *******************************

#############################################################################################################################  */

// /// screens/manager_dashboard_screen.dart
// import 'dart:async';
// import 'dart:math';
// import 'dart:ui';

// import 'package:attendanceapp/views/managerviews/leavescreen.dart';
// import 'package:attendanceapp/views/managerviews/regularisation_screen.dart';
// import 'package:attendanceapp/views/managerviews/timeline.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/manager_drawer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/matrix_counter.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/presentdashboard.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/attendance_timer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/dashboard_cards.dart';

// class ManagerDashboardScreen extends StatefulWidget {
//   final User user;

//   const ManagerDashboardScreen({super.key, required this.user});

//   @override
//   _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
// }

// class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
//     with TickerProviderStateMixin {
//   String _currentTime = '';
//   Timer? _timer;
//   late TabController _tabController;
//   int _currentIndex = 0;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _neuralAnimation;
//   late Animation<double> _particleAnimation;
//   List<Particle> _particles = [];

//   // Notification variables
//   int _notificationCount = 3;
//   bool _showNotificationBadge = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeParticles();
//     _initializeAnimations();
//     _initializeDashboard();
//     _startLiveTime();
//   }

//   // Navigation handle करने का method add करें
//   void _handleTabChange(int index) {
//     setState(() {
//       _currentIndex = index;
//     });

//     if (index == 1) {
//       // Regularisation tab index
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => RegularisationScreen(user: widget.user),
//         ), // ✅ User pass karo
//       );
//     } else if (index == 2) {
//       // Leave tab index
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LeaveScreen(user: widget.user),
//         ), // ✅ User pass karo
//       );
//     } else if (index == 3) {
//       // Timeline tab index
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TimelineScreen(user: widget.user),
//         ), // ✅ User pass karo
//       );
//     } else {
//       _tabController.animateTo(index);
//     }
//   }

//   void _startLiveTime() {
//     _updateTime();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _updateTime();
//     });
//   }

//   void _updateTime() {
//     if (mounted) {
//       setState(() {
//         _currentTime = _getLiveTime();
//       });
//     }
//   }

//   void _initializeParticles() {
//     for (int i = 0; i < 15; i++) {
//       _particles.add(Particle());
//     }
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
//           ),
//         );

//     _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.3, 0.9, curve: Curves.elasticOut),
//       ),
//     );

//     _neuralAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
//       ),
//     );

//     _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _controller.forward();
//   }

//   void _initializeDashboard() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.initializeDashboard(widget.user);
//     });
//   }

//   void _showNotifications(BuildContext context) {
//     setState(() {
//       _notificationCount = 0;
//       _showNotificationBadge = false;
//     });

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => _buildNotificationsSheet(),
//     );
//   }

//   Widget _buildNotificationsSheet() {
//     final notifications = [
//       {
//         'title': 'Team Meeting',
//         'message': 'Scheduled for 3:00 PM today',
//         'time': '10 min ago',
//         'read': false,
//       },
//       {
//         'title': 'Report Generated',
//         'message': 'Monthly attendance report is ready',
//         'time': '1 hour ago',
//         'read': false,
//       },
//       {
//         'title': 'New Employee',
//         'message': 'Rahul joined your team',
//         'time': '2 hours ago',
//         'read': true,
//       },
//       {
//         'title': 'System Update',
//         'message': 'New features available',
//         'time': '1 day ago',
//         'read': true,
//       },
//     ];

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.8,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             QuickAIColors.cyber.primary.withOpacity(0.95),
//             QuickAIColors.cyber.secondary.withOpacity(0.95),
//           ],
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(32),
//           topRight: Radius.circular(32),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(32),
//                 topRight: Radius.circular(32),
//               ),
//             ),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.close_rounded, color: Colors.white),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.notifications_active_rounded,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'NOTIFICATIONS',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notification = notifications[index];
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: notification['read'] as bool
//                         ? Colors.white.withOpacity(0.1)
//                         : QuickAIColors.cyber.accent.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: notification['read'] as bool
//                           ? Colors.white.withOpacity(0.2)
//                           : QuickAIColors.cyber.accent.withOpacity(0.4),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: notification['read'] as bool
//                               ? Colors.transparent
//                               : QuickAIColors.cyber.accent,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               notification['title'] as String,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               notification['message'] as String,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               notification['time'] as String,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.6),
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 QuickAIColors.cyber.primary.withOpacity(0.95),
//                 QuickAIColors.cyber.secondary.withOpacity(0.95),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(28),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.4),
//                 blurRadius: 40,
//                 offset: const Offset(0, 20),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header Icon
//               // Container(
//               //   width: 80,
//               //   height: 80,
//               //   decoration: BoxDecoration(
//               //     color: QuickAIColors.cyber.error.withOpacity(0.2),
//               //     shape: BoxShape.circle,
//               //     border: Border.all(
//               //       color: QuickAIColors.cyber.error.withOpacity(0.4),
//               //       width: 2,
//               //     ),
//               //   ),
//               //   child: Icon(
//               //     Icons.logout_rounded,
//               //     color: QuickAIColors.cyber.error,
//               //     size: 40,
//               //   ),
//               // ),
//               // const SizedBox(height: 20),

//               // Title
//               Text(
//                 'LOGOUT',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Message
//               Text(
//                 'Are you sure you want to logout?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white.withOpacity(0.9),
//                   height: 1.4,
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                         ),
//                       ),
//                       child: TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.white.withOpacity(0.1),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         child: Text(
//                           'CANCEL',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             QuickAIColors.cyber.error,
//                             QuickAIColors.cyber.warning,
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: QuickAIColors.cyber.error.withOpacity(0.4),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           // Add your logout logic here
//                         },
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         child: Text(
//                           'LOGOUT',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);

//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.transparent,
//       drawer: ManagerDrawer(
//         user: widget.user,
//         onLogout: () => _showLogoutConfirmation(context),
//       ),
//       body: Stack(
//         children: [
//           // Background
//           _buildBackground(),

//           // Neural Particles
//           _buildNeuralParticles(),

//           // Main Content
//           SafeArea(
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: ScaleTransition(
//                       scale: _scaleAnimation,
//                       child: SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         padding: const EdgeInsets.only(bottom: 20),
//                         child: Column(
//                           children: [
//                             // Profile Header
//                             _buildProfileHeader(),

//                             const SizedBox(height: 20),

//                             // Date & Time Section
//                             _buildDateTimeSection(),

//                             const SizedBox(height: 20),

//                             // Enhanced Attendance Timer
//                             // _buildAttendanceTimer(),

//                             //Present Card Section
//                             _buildpresentdashboardCards(),

//                             const SizedBox(height: 20),

//                             // METRICS COUNTER Cards
//                             _buildMetricsCounterCards(),
//                             const SizedBox(height: 20),
//                             // Premium Dashboard Cards
//                             _buildDashboardCards(),

//                             const SizedBox(height: 20),

//                             // Quick Actions Section
//                             //_buildQuickActions(),

//                             //const SizedBox(height: 20),

//                             // Team Performance Section
//                             //_buildTeamPerformanceSection(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: _currentIndex,
//         onTabChanged: _handleTabChange,
//       ),
//     );
//   }

//   Widget _buildBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: RadialGradient(
//           center: Alignment.topLeft,
//           radius: 2.0,
//           colors: [
//             QuickAIColors.cyber.primary.withOpacity(0.3),
//             QuickAIColors.cyber.secondary.withOpacity(0.2),
//             // const Color.fromARGB(255, 20, 0, 201),
//             Colors.black,
//           ],
//           stops: const [0.0, 0.5, 1.0],
//         ),
//       ),
//     );
//   }

//   Widget _buildNeuralParticles() {
//     return AnimatedBuilder(
//       animation: _particleAnimation,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: _NeuralParticlePainter(
//             particles: _particles,
//             animationValue: _particleAnimation.value,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfileHeader() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.blue.shade900.withOpacity(0.95),
//             Colors.purple.shade800.withOpacity(0.85),
//             Colors.deepPurple.shade900.withOpacity(0.95),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: QuickAIColors.cyber.primary.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Menu Icon - More Subtle
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.25),
//                 width: 1.2,
//               ),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.menu_rounded, color: Colors.white, size: 20),
//               onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Profile Info - Clean and Professional
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   widget.user.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   widget.user.email,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     _getUserTypeDisplay(),
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // User Avatar - Professional
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 // Profile Picture
//                 ClipOval(
//                   child: Container(
//                     color: Colors.white.withOpacity(0.1),
//                     child: Icon(
//                       Icons.person,
//                       color: Colors.white.withOpacity(0.8),
//                       size: 24,
//                     ),
//                   ),
//                 ),
//                 // Online Status
//                 Positioned(
//                   bottom: 2,
//                   right: 2,
//                   child: Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade500,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 1.5),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Notification Icon - Clean Design
//           Stack(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.25),
//                     width: 1.2,
//                   ),
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.notifications_outlined,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   onPressed: () => _showNotifications(context),
//                 ),
//               ),
//               if (_showNotificationBadge && _notificationCount > 0)
//                 Positioned(
//                   right: 10,
//                   top: 10,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade400,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 1.5),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.red.shade400.withOpacity(0.8),
//                           blurRadius: 4,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // String _getUserRoleDisplay(String userType) {
//   //   switch (userType.toLowerCase()) {
//   //     case 'manager':
//   //       return 'Manager';
//   //     case 'hr':
//   //       return 'HR Manager';
//   //     case 'finance_manager':
//   //       return 'Finance Manager';
//   //     case 'admin':
//   //       return 'Administrator';
//   //     case 'supervisor':
//   //       return 'Supervisor';
//   //     default:
//   //       return 'User';
//   //   }
//   // }

//   // Widget _buildProfileHeader() {
//   //   return Container(
//   //     margin: const EdgeInsets.all(16),
//   //     padding: const EdgeInsets.all(20),
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(24),
//   //       gradient: LinearGradient(
//   //         begin: Alignment.topLeft,
//   //         end: Alignment.bottomRight,
//   //         colors: [
//   //           QuickAIColors.cyber.primary.withOpacity(0.8),
//   //           QuickAIColors.cyber.secondary.withOpacity(0.9),
//   //         ],
//   //       ),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: QuickAIColors.cyber.primary.withOpacity(0.4),
//   //           blurRadius: 25,
//   //           offset: const Offset(0, 12),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         // Menu Icon
//   //         Container(
//   //           width: 50,
//   //           height: 50,
//   //           decoration: BoxDecoration(
//   //             color: Colors.white.withOpacity(0.2),
//   //             borderRadius: BorderRadius.circular(14),
//   //             border: Border.all(
//   //               color: Colors.white.withOpacity(0.3),
//   //               width: 1.5,
//   //             ),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: Colors.black.withOpacity(0.2),
//   //                 blurRadius: 10,
//   //                 offset: const Offset(0, 4),
//   //               ),
//   //             ],
//   //           ),
//   //           child: IconButton(
//   //             icon: Icon(Icons.menu_rounded, color: Colors.white, size: 22),
//   //             onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//   //           ),
//   //         ),
//   //         const SizedBox(width: 16),

//   //         // Profile Info
//   //         Expanded(
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 'WELCOME' + ' ' + widget.user.name,
//   //                 style: TextStyle(
//   //                   color: Colors.white.withOpacity(0.9),
//   //                   fontSize: 12,
//   //                   fontWeight: FontWeight.w700,
//   //                   letterSpacing: 1.5,
//   //                 ),
//   //               ),
//   //               // const SizedBox(height: 6),
//   //               // Text(
//   //               //   widget.user.name,
//   //               //   style: const TextStyle(
//   //               //     color: Colors.white,
//   //               //     fontSize: 20,
//   //               //     fontWeight: FontWeight.w800,
//   //               //     letterSpacing: 0.8,
//   //               //   ),
//   //               //   maxLines: 1,
//   //               //   overflow: TextOverflow.ellipsis,
//   //               // ),
//   //               const SizedBox(height: 4),
//   //               Text(
//   //                 widget.user.email,
//   //                 style: TextStyle(
//   //                   color: Colors.white.withOpacity(0.8),
//   //                   fontSize: 13,
//   //                   fontWeight: FontWeight.w500,
//   //                 ),
//   //                 maxLines: 1,
//   //                 overflow: TextOverflow.ellipsis,
//   //               ),
//   //             ],
//   //           ),
//   //         ),

//   //         // Notification Icon with Badge
//   //         Stack(
//   //           children: [
//   //             Container(
//   //               width: 50,
//   //               height: 50,
//   //               decoration: BoxDecoration(
//   //                 color: Colors.white.withOpacity(0.2),
//   //                 borderRadius: BorderRadius.circular(14),
//   //                 border: Border.all(
//   //                   color: Colors.white.withOpacity(0.3),
//   //                   width: 1.5,
//   //                 ),
//   //                 boxShadow: [
//   //                   BoxShadow(
//   //                     color: Colors.black.withOpacity(0.2),
//   //                     blurRadius: 10,
//   //                     offset: const Offset(0, 4),
//   //                   ),
//   //                 ],
//   //               ),
//   //               child: IconButton(
//   //                 icon: Icon(
//   //                   Icons.notifications_rounded,
//   //                   color: Colors.white,
//   //                   size: 22,
//   //                 ),
//   //                 onPressed: () => _showNotifications(context),
//   //               ),
//   //             ),
//   //             if (_showNotificationBadge && _notificationCount > 0)
//   //               Positioned(
//   //                 right: 8,
//   //                 top: 8,
//   //                 child: Container(
//   //                   padding: const EdgeInsets.all(4),
//   //                   decoration: BoxDecoration(
//   //                     color: QuickAIColors.cyber.accent,
//   //                     shape: BoxShape.circle,
//   //                     border: Border.all(color: Colors.white, width: 1.5),
//   //                     boxShadow: [
//   //                       BoxShadow(
//   //                         color: QuickAIColors.cyber.accent.withOpacity(0.8),
//   //                         blurRadius: 8,
//   //                         spreadRadius: 2,
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   constraints: const BoxConstraints(
//   //                     minWidth: 18,
//   //                     minHeight: 18,
//   //                   ),
//   //                   child: Text(
//   //                     _notificationCount > 9
//   //                         ? '9+'
//   //                         : _notificationCount.toString(),
//   //                     textAlign: TextAlign.center,
//   //                     style: const TextStyle(
//   //                       color: Colors.white,
//   //                       fontSize: 10,
//   //                       fontWeight: FontWeight.w800,
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //           ],
//   //         ),
//   //         const SizedBox(width: 12),

//   //         // User Avatar
//   //         Stack(
//   //           children: [
//   //             Container(
//   //               width: 56,
//   //               height: 56,
//   //               decoration: BoxDecoration(
//   //                 gradient: LinearGradient(
//   //                   colors: [
//   //                     Colors.white.withOpacity(0.3),
//   //                     Colors.white.withOpacity(0.1),
//   //                   ],
//   //                 ),
//   //                 shape: BoxShape.circle,
//   //                 border: Border.all(
//   //                   color: Colors.white.withOpacity(0.4),
//   //                   width: 2,
//   //                 ),
//   //                 boxShadow: [
//   //                   BoxShadow(
//   //                     color: Colors.black.withOpacity(0.2),
//   //                     blurRadius: 10,
//   //                     offset: const Offset(0, 4),
//   //                   ),
//   //                 ],
//   //               ),
//   //               child: Icon(
//   //                 Icons.person_rounded,
//   //                 color: Colors.white,
//   //                 size: 28,
//   //               ),
//   //             ),
//   //             // Online Status Indicator
//   //             Positioned(
//   //               right: 2,
//   //               bottom: 2,
//   //               child: Container(
//   //                 width: 14,
//   //                 height: 14,
//   //                 decoration: BoxDecoration(
//   //                   color: QuickAIColors.cyber.accent,
//   //                   shape: BoxShape.circle,
//   //                   border: Border.all(color: Colors.white, width: 2),
//   //                   boxShadow: [
//   //                     BoxShadow(
//   //                       color: QuickAIColors.cyber.accent.withOpacity(0.8),
//   //                       blurRadius: 8,
//   //                       spreadRadius: 2,
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildDateTimeSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Date and Time
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Date Section
//                 _buildDateTimeItem(
//                   icon: Icons.calendar_month_rounded,
//                   title: 'DATE',
//                   value: _getFormattedDate(),
//                 ),
//                 const SizedBox(height: 16),

//                 // Time Section
//                 _buildDateTimeItem(
//                   icon: Icons.access_time_filled_rounded,
//                   title: 'TIME',
//                   value: _getLiveTime(),
//                   isLive: true,
//                 ),
//               ],
//             ),
//           ),

//           // Role Badge
//           // Container(
//           //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           //   decoration: BoxDecoration(
//           //     gradient: LinearGradient(
//           //       begin: Alignment.topLeft,
//           //       end: Alignment.bottomRight,
//           //       colors: [
//           //         QuickAIColors.cyber.primary,
//           //         QuickAIColors.cyber.secondary,
//           //       ],
//           //     ),
//           //     borderRadius: BorderRadius.circular(18),
//           //     boxShadow: [
//           //       BoxShadow(
//           //         color: QuickAIColors.cyber.primary.withOpacity(0.3),
//           //         blurRadius: 15,
//           //         offset: const Offset(0, 6),
//           //       ),
//           //     ],
//           //   ),
//           //   child: Column(
//           //     mainAxisSize: MainAxisSize.min,
//           //     children: [
//           //       Icon(
//           //         Icons.verified_user_rounded,
//           //         color: Colors.white,
//           //         size: 24,
//           //       ),
//           //       const SizedBox(height: 8),
//           //       Text(
//           //         _getUserTypeDisplay().toUpperCase(),
//           //         style: const TextStyle(
//           //           color: Colors.white,
//           //           fontSize: 12,
//           //           fontWeight: FontWeight.w800,
//           //           letterSpacing: 1.0,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateTimeItem({
//     required IconData icon,
//     required String title,
//     required String value,
//     bool isLive = false,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 44,
//           height: 44,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 QuickAIColors.cyber.primary,
//                 QuickAIColors.cyber.secondary,
//               ],
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: QuickAIColors.cyber.primary.withOpacity(0.2),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Icon(icon, color: Colors.white, size: 20),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white.withOpacity(0.8),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (isLive)
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: QuickAIColors.cyber.accent,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: QuickAIColors.cyber.accent.withOpacity(0.8),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAttendanceTimer() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const AttendanceTimerSection(),
//     );
//   }

//   Widget _buildMetricsCounterCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: MetricsCounter(
//         totalAttendance: _calculateDynamicAttendance(),
//         teamMembers: _getDynamicTeamSize(),
//         projects: _getDynamicProjectCount(),
//         timeline: _getCurrentTimeline(),
//       ),
//     );
//   }

//   // Helper methods for dynamic data
//   int _calculateDynamicAttendance() {
//     final now = DateTime.now();
//     return (now.day * now.hour) ~/ 2; // Dynamic calculation based on date/time
//   }

//   int _getDynamicTeamSize() {
//     // You can replace this with actual team data later
//     return 8 + (DateTime.now().day % 5); // Varies between 8-12
//   }

//   int _getDynamicProjectCount() {
//     final now = DateTime.now();
//     return 5 + (now.weekday % 3); // Varies between 5-7
//   }

//   String _getCurrentTimeline() {
//     final now = DateTime.now();
//     final quarter = ((now.month - 1) ~/ 3) + 1;
//     return 'Q$quarter ${now.year}';
//   }

//   // Widget _buildMetricsCounterCards() {
//   //   return Container(
//   //     margin: const EdgeInsets.symmetric(horizontal: 16),
//   //     child: Consumer<ManagerDashboardViewModel>(
//   //       builder: (context, viewModel, child) {
//   //         // Dynamic data calculation based on your ViewModel
//   //         final dashboardData = viewModel.dashboardData;

//   //         return MetricsCounter(
//   //           totalAttendance: dashboardData?.totalAttendanceRecords ?? _calculateTotalAttendance(),
//   //           teamMembers: viewModel.teamMembers?.length ?? _getTeamMembersCount(),
//   //           projects: dashboardData?.activeProjectsCount ?? _getProjectsCount(),
//   //           timeline: _getCurrentTimeline(),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }

//   Widget _buildDashboardCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const DashboardCardsSection(),
//     );
//   }

//   Widget _buildpresentdashboardCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const PresentDashboardCardSection(),
//     );
//   }

//   Widget _buildQuickActions() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'ACTIONS',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 1.2,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildActionItem(
//                 icon: Icons.people_alt_rounded,
//                 label: 'TEAM',
//                 color: QuickAIColors.cyber.primary,
//               ),
//               _buildActionItem(
//                 icon: Icons.analytics_rounded,
//                 label: 'REPORTS',
//                 color: QuickAIColors.cyber.accent,
//               ),
//               _buildActionItem(
//                 icon: Icons.settings_rounded,
//                 label: 'SETTINGS',
//                 color: QuickAIColors.cyber.secondary,
//               ),
//               _buildActionItem(
//                 icon: Icons.help_rounded,
//                 label: 'HELP',
//                 color: QuickAIColors.cyber.warning,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTeamPerformanceSection() {
//     final teamData = [
//       {
//         'name': 'Design Team',
//         'progress': 0.85,
//         'members': 8,
//         'color': QuickAIColors.cyber.primary,
//       },
//       {
//         'name': 'Development',
//         'progress': 0.72,
//         'members': 12,
//         'color': QuickAIColors.cyber.accent,
//       },
//       {
//         'name': 'Marketing',
//         'progress': 0.68,
//         'members': 6,
//         'color': QuickAIColors.cyber.secondary,
//       },
//       {
//         'name': 'QA Team',
//         'progress': 0.91,
//         'members': 5,
//         'color': QuickAIColors.cyber.warning,
//       },
//     ];

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.leaderboard_rounded, color: Colors.white, size: 24),
//               const SizedBox(width: 12),
//               Text(
//                 'TEAM PERFORMANCE',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 'VIEW ALL',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: QuickAIColors.cyber.accent,
//                   letterSpacing: 1.0,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           ...teamData.map((team) => _buildTeamProgressItem(team)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTeamProgressItem(Map<String, dynamic> team) {
//     final double progress = team['progress'] as double;
//     final Color color = team['color'] as Color;
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double progressWidth =
//         (screenWidth - 112) * progress; // Adjusted for padding

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 team['name'] as String,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 '${(progress * 100).toInt()}%',
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Stack(
//             children: [
//               Container(
//                 height: 8,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               Container(
//                 height: 8,
//                 width: progressWidth,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [color, color.withOpacity(0.7)],
//                   ),
//                   borderRadius: BorderRadius.circular(4),
//                   boxShadow: [
//                     BoxShadow(
//                       color: color.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${team['members']} members',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.7),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionItem({
//     required IconData icon,
//     required String label,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: color.withOpacity(0.4)),
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Colors.white.withOpacity(0.9),
//             letterSpacing: 0.8,
//           ),
//         ),
//       ],
//     );
//   }

//   String _getFormattedDate() {
//     final now = DateTime.now();
//     return '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';
//   }

//   String _getLiveTime() {
//     final now = DateTime.now();
//     return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//   }

//   String _getUserTypeDisplay() {
//     switch (widget.user.userType.toLowerCase()) {
//       case 'manager':
//         return 'MANAGER';
//       case 'admin':
//         return 'ADMIN';
//       case 'employee':
//         return 'EMPLOYEE';
//       case 'supervisor':
//         return 'SUPERVISOR';
//       default:
//         return widget.user.userType.toUpperCase();
//     }
//   }

//   String _getWeekday(int weekday) {
//     const days = [
//       'MONDAY',
//       'TUESDAY',
//       'WEDNESDAY',
//       'THURSDAY',
//       'FRIDAY',
//       'SATURDAY',
//       'SUNDAY',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'JANUARY',
//       'FEBRUARY',
//       'MARCH',
//       'APRIL',
//       'MAY',
//       'JUNE',
//       'JULY',
//       'AUGUST',
//       'SEPTEMBER',
//       'OCTOBER',
//       'NOVEMBER',
//       'DECEMBER',
//     ];
//     return months[month - 1];
//   }
// }

// // Neural Particle System
// class _NeuralParticlePainter extends CustomPainter {
//   final List<Particle> particles;
//   final double animationValue;

//   _NeuralParticlePainter({
//     required this.particles,
//     required this.animationValue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (final particle in particles) {
//       final paint = Paint()
//         ..color = QuickAIColors.cyber.accent.withOpacity(
//           particle.opacity * animationValue * 0.5,
//         )
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

//       final x = particle.x * size.width;
//       final y =
//           (particle.y + animationValue * particle.speed) % 1.0 * size.height;

//       canvas.drawCircle(Offset(x, y), particle.size * animationValue, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class Particle {
//   double x = Random().nextDouble();
//   double y = Random().nextDouble();
//   double speed = 0.5 + Random().nextDouble() * 0.5;
//   double size = 2 + Random().nextDouble() * 4;
//   double opacity = 0.1 + Random().nextDouble() * 0.3;
// }

/*  #####################################################################################################################

***************************************         A I S C R E E N C O D E             *****************************************

############################################################################################################################ */

// // screens/manager_dashboard_screen.dart
// import 'package:attendanceapp/widgets/mangerwidgets/manager_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/attendance_timer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/dashboard_cards.dart';

// class ManagerDashboardScreen extends StatefulWidget {
//   final User user;

//   const ManagerDashboardScreen({super.key, required this.user});

//   @override
//   _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
// }

// class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentIndex = 0;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeDashboard();
//   }

//   void _initializeDashboard() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.initializeDashboard(widget.user);
//     });
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         backgroundColor:
//             Provider.of<AppTheme>(context).themeMode == ThemeMode.dark
//             ? AppColors.grey800
//             : AppColors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header Icon
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: AppColors.error.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.logout_rounded,
//                   color: AppColors.error,
//                   size: 40,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Title
//               Text(
//                 'Logout Confirmation',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color:
//                       Provider.of<AppTheme>(context).themeMode == ThemeMode.dark
//                       ? AppColors.textInverse
//                       : AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Message
//               Text(
//                 'Are you sure you want to logout from your account?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color:
//                       Provider.of<AppTheme>(context).themeMode == ThemeMode.dark
//                       ? AppColors.grey400
//                       : AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: AppColors.textSecondary,
//                         side: BorderSide(color: AppColors.grey300),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         // Add your logout logic here
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.error,
//                         foregroundColor: AppColors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 2,
//                       ),
//                       child: const Text('Logout'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);

//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       drawer: ManagerDrawer(
//         user: widget.user,
//         onLogout: () => _showLogoutConfirmation(context),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Profile Header with Menu Icon
//             _buildEnhancedProfileHeader(theme),

//             // Main Content - YEH SCROLLABLE HONA CHAHIYE
//             Expanded(
//               // ← YEH ADD KIYA SABSE IMPORTANT
//               child: SingleChildScrollView(
//                 // ← SCROLLABLE CONTENT
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     // Enhanced Date & Time Display
//                     _buildAmazingDateTimeSection(theme),
//                     const SizedBox(height: 16),

//                     // Attendance Timer with improved styling
//                     const AttendanceTimerSection(),
//                     const SizedBox(height: 10),

//                     // Enhanced Dashboard Cards
//                     const DashboardCardsSection(),
//                     const SizedBox(height: 20), // Bottom padding
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: _currentIndex,
//         onTabChanged: (index) {
//           setState(() => _currentIndex = index);
//           _tabController.animateTo(index);
//         },
//       ),
//     );
//   }

//   Widget _buildEnhancedProfileHeader(AppTheme theme) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: AppColors.gradientColors,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Menu Icon with better design
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.menu_rounded, color: AppColors.white, size: 24),
//               onPressed: () {
//                 _scaffoldKey.currentState?.openDrawer();
//               },
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Enhanced Profile Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.8),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   widget.user.name,
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   widget.user.email,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.8),
//                     fontSize: 12,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),

//           // User Avatar
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//             ),
//             child: Icon(Icons.person_rounded, color: AppColors.white, size: 24),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAmazingDateTimeSection(AppTheme theme) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: theme.themeMode == ThemeMode.dark
//             ? AppColors.grey800
//             : AppColors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(
//           color: theme.themeMode == ThemeMode.dark
//               ? AppColors.grey700
//               : AppColors.grey200,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Date and Time with amazing design
//           StreamBuilder(
//             stream: Stream.periodic(const Duration(seconds: 1)),
//             builder: (context, snapshot) {
//               final now = DateTime.now();
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Date with icon
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: AppColors.gradientColors,
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(
//                           Icons.calendar_today_rounded,
//                           color: AppColors.white,
//                           size: 16,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Today',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: theme.themeMode == ThemeMode.dark
//                                   ? AppColors.grey400
//                                   : AppColors.textSecondary,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: theme.themeMode == ThemeMode.dark
//                                   ? AppColors.textInverse
//                                   : AppColors.textPrimary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   // Time with icon
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: AppColors.gradientColors,
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(
//                           Icons.access_time_rounded,
//                           color: AppColors.white,
//                           size: 16,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Current Time',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: theme.themeMode == ThemeMode.dark
//                                   ? AppColors.grey400
//                                   : AppColors.textSecondary,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: theme.themeMode == ThemeMode.dark
//                                   ? AppColors.textInverse
//                                   : AppColors.textPrimary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             },
//           ),

//           // User Type Badge with amazing design
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: AppColors.gradientColors,
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.3),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.verified_rounded, color: AppColors.white, size: 20),
//                 const SizedBox(height: 4),
//                 Text(
//                   _getUserTypeDisplay(),
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // UserType ke hisab se display text
//   String _getUserTypeDisplay() {
//     switch (widget.user.userType.toLowerCase()) {
//       case 'manager':
//         return 'Manager';
//       case 'admin':
//         return 'Admin';
//       case 'employee':
//         return 'Employee';
//       case 'supervisor':
//         return 'Supervisor';
//       default:
//         return widget.user.userType;
//     }
//   }

//   String _getWeekday(int weekday) {
//     const days = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/attendance_timer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/dashboard_cards.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/manager_profile_header.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ManagerDashboardScreen extends StatefulWidget {
//   final User user;

//   const ManagerDashboardScreen({super.key, required this.user});

//   @override
//   _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
// }

// class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeDashboard();
//   }

//   void _initializeDashboard() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.initializeDashboard(widget.user);
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Profile Header
//             ManagerProfileHeader(user: widget.user),

//             // Enhanced Date & Time Display
//             _buildEnhancedDateTimeSection(),

//             // Attendance Timer with improved styling
//             const AttendanceTimerSection(),

//             // Enhanced Dashboard Cards
//             const Expanded(child: DashboardCardsSection()),
//           ],
//         ),
//       ),

//       // Bottom Navigation
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: _currentIndex,
//         onTabChanged: (index) {
//           setState(() => _currentIndex = index);
//           _tabController.animateTo(index);
//         },
//       ),
//     );
//   }

//   Widget _buildEnhancedDateTimeSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary.withOpacity(0.15),
//             AppColors.primary.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.primary.withOpacity(0.1)),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Date and Time with improved design
//           StreamBuilder(
//             stream: Stream.periodic(const Duration(seconds: 1)),
//             builder: (context, snapshot) {
//               final now = DateTime.now();
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Date Row
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           Icons.calendar_today_rounded,
//                           size: 16,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   // Time Row
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           Icons.access_time_rounded,
//                           size: 16,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             },
//           ),

//           // Manager Badge with enhanced design
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.verified_user_rounded,
//                   color: AppColors.white,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Manager',
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getWeekday(int weekday) {
//     const days = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/attendance_timer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/dashboard_cards.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/manager_profile_header.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ManagerDashboardScreen extends StatefulWidget {
//   final User user;

//   const ManagerDashboardScreen({super.key, required this.user});

//   @override
//   _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
// }

// class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeDashboard();
//   }

//   void _initializeDashboard() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.initializeDashboard(widget.user);
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Profile Header
//             ManagerProfileHeader(user: widget.user),

//             // Date & Time Display
//             _buildDateTimeSection(),

//             // Attendance Timer
//             const AttendanceTimerSection(),

//             // Dashboard Cards
//             const Expanded(child: DashboardCardsSection()),
//           ],
//         ),
//       ),

//       // Bottom Navigation
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: _currentIndex,
//         onTabChanged: (index) {
//           setState(() => _currentIndex = index);
//           _tabController.animateTo(index);
//         },
//       ),
//     );
//   }

//   Widget _buildDateTimeSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           StreamBuilder(
//             stream: Stream.periodic(const Duration(seconds: 1)),
//             builder: (context, snapshot) {
//               final now = DateTime.now();
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   Text(
//                     '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               'Manager',
//               style: const TextStyle(
//                 color: AppColors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getWeekday(int weekday) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }
// }
