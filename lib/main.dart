import 'package:attendanceapp/core/view_models/button_view_model.dart';
import 'package:attendanceapp/core/view_models/common_view_model.dart';
import 'package:attendanceapp/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'package:attendanceapp/view_models/auth_view_model.dart';
import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
import 'package:attendanceapp/view_models/projectviewmodels/project_analytics_view_model.dart';
import 'package:attendanceapp/views/employeeviews/employee_dashboard.dart';
import 'package:attendanceapp/views/financeviews/finance_dashboard_screen.dart';
import 'package:attendanceapp/views/hrviews/hrdashboard_screen.dart';
import 'package:attendanceapp/views/login_screen.dart';
import 'package:attendanceapp/views/managerviews/manager_dashboard_screen.dart';
import 'package:attendanceapp/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/navigation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core ViewModels
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => ButtonState()),
        ChangeNotifierProvider(create: (_) => CommonState()),

        // Feature ViewModels
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ManagerDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AttendanceAnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => EmployeeDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectAnalyticsViewModel()),
      ],
      child: Consumer<AppTheme>(
        builder: (context, theme, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService().navigatorKey,
            routes: {
              '/login': (context) => const LoginScreen(),
              '/manager_dashboard': (context) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                if (authViewModel.currentUser == null) {
                  // If somehow user is null, go back to login
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/login');
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return ManagerDashboardScreen(user: authViewModel.currentUser!);
              },
              '/employee_dashboard': (context) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                if (authViewModel.currentUser == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/login');
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return EmployeeDashboardScreen(
                  user: authViewModel.currentUser!,
                );
              },
              '/hr_dashboard': (context) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                if (authViewModel.currentUser == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/login');
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return HRDashboardScreen(user: authViewModel.currentUser!);
              },
              '/finance_dashboard': (context) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                if (authViewModel.currentUser == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/login');
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return FinanceDashboardScreen(user: authViewModel.currentUser!);
              },
            },
          );
        },
      ),
    );
  }
}

// import 'package:attendanceapp/core/view_models/button_view_model.dart';
// import 'package:attendanceapp/core/view_models/common_view_model.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:attendanceapp/view_models/auth_view_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/views/employeeviews/employee_dashboard.dart';
// import 'package:attendanceapp/views/financeviews/finance_dashboard_screen.dart';
// import 'package:attendanceapp/views/hrviews/hrdashboard_screen.dart';
// import 'package:attendanceapp/views/login_screen.dart';
// import 'package:attendanceapp/views/managerviews/manager_dashboard_screen.dart';
// import 'package:attendanceapp/views/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'core/services/navigation_service.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Core ViewModels
//         ChangeNotifierProvider(create: (_) => AppTheme()),
//         ChangeNotifierProvider(create: (_) => ButtonState()),
//         ChangeNotifierProvider(create: (_) => CommonState()),

//         // Feature ViewModels
//         ChangeNotifierProvider(create: (_) => AuthViewModel()),
//         ChangeNotifierProvider(create: (_) => ManagerDashboardViewModel()),
//         ChangeNotifierProvider(create: (_) => AttendanceAnalyticsViewModel()),
//         ChangeNotifierProvider(create: (_) => EmployeeDetailsViewModel()),
//         ChangeNotifierProvider(create: (_) => ProjectViewModel()),
//       ],
//       child: Consumer<AppTheme>(
//         builder: (context, theme, child) {
//           return MaterialApp(
//             title: AppConstants.appName,
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: theme.themeMode,
//             home: const SplashScreen(),
//             debugShowCheckedModeBanner: false,
//             navigatorKey: NavigationService().navigatorKey,
//             routes: {
//               '/login': (context) => const LoginScreen(),
//               '/manager_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   // If somehow user is null, go back to login
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return ManagerDashboardScreen(user: authViewModel.currentUser!);
//               },
//               '/employee_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return EmployeeDashboardScreen(
//                   user: authViewModel.currentUser!,
//                 );
//               },
//               '/hr_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return HRDashboardScreen(user: authViewModel.currentUser!);
//               },
//               '/finance_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return FinanceDashboardScreen(user: authViewModel.currentUser!);
//               },
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:attendanceapp/core/view_models/button_view_model.dart';
// import 'package:attendanceapp/core/view_models/common_view_model.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:attendanceapp/view_models/auth_view_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:attendanceapp/views/login_screen.dart';
// import 'package:attendanceapp/views/managerviews/manager_dashboard_screen.dart';
// import 'package:attendanceapp/views/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'core/services/navigation_service.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Core ViewModels
//         ChangeNotifierProvider(create: (_) => AppTheme()),
//         ChangeNotifierProvider(create: (_) => ButtonState()),
//         ChangeNotifierProvider(create: (_) => CommonState()),

//         // Feature ViewModels
//         ChangeNotifierProvider(create: (_) => AuthViewModel()),
//         ChangeNotifierProvider(create: (_) => ManagerDashboardViewModel()),
//         ChangeNotifierProvider(create: (_) => AttendanceAnalyticsViewModel()),
//         ChangeNotifierProvider(create: (_) => EmployeeDetailsViewModel()),
//         ChangeNotifierProvider(create: (_) => ProjectViewModel()),
//       ],
//       child: Consumer<AppTheme>(
//         builder: (context, theme, child) {
//           return MaterialApp(
//             title: AppConstants.appName,
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: theme.themeMode,
//             home: const SplashScreen(),
//             debugShowCheckedModeBanner: false,
//             navigatorKey: NavigationService().navigatorKey,
//             routes: {
//               '/login': (context) => const LoginScreen(),
//               '/manager_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   // If somehow user is null, go back to login
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return ManagerDashboardScreen(user: authViewModel.currentUser!);
//               },
//             },
//           );
//         },
//       ),
//     );
//   }
// }
