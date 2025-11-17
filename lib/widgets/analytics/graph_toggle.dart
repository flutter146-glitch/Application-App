import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'package:flutter/material.dart';

class GraphToggle extends StatefulWidget {
  final AttendanceAnalyticsViewModel viewModel;
  final Function(int)? onViewChanged;

  const GraphToggle({super.key, required this.viewModel, this.onViewChanged});

  @override
  State<GraphToggle> createState() => _GraphToggleState();
}

class _GraphToggleState extends State<GraphToggle> {
  int _currentView = 0; // 0 = Merged, 1 = Individual, 2 = Project
  int? _hoveredView;
  bool _showHoverIndicator = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current View Icon
            _buildViewIcon(),
            const SizedBox(width: 12),

            // Three-Way Toggle Switch
            _buildThreeWayToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewIcon() {
    IconData icon;
    Color color;

    switch (_currentView) {
      case 0:
        icon = Icons.group;
        color = Colors.cyan.shade300;
        break;
      case 1:
        icon = Icons.person;
        color = Colors.orange.shade300;
        break;
      case 2:
        icon = Icons.pie_chart_rounded;
        color = Colors.purple.shade300;
        break;
      default:
        icon = Icons.group;
        color = Colors.cyan;
    }

    return Icon(icon, size: 18, color: color);
  }

  Widget _buildThreeWayToggle() {
    return Container(
      width: 80,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Background Selection
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _currentView * 26.0, // 26px per option
            child: Container(
              width: 26,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: _getBorderRadiusForPosition(_currentView),
                gradient: _getGradientForView(_currentView),
                boxShadow: [
                  BoxShadow(
                    color: _getColorForView(_currentView).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Hover Indicator
          if (_showHoverIndicator && _hoveredView != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _hoveredView! * 26.0,
              child: Container(
                width: 26,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: _getBorderRadiusForPosition(_hoveredView!),
                  border: Border.all(
                    color: _getColorForView(_hoveredView!).withOpacity(0.8),
                    width: 2,
                  ),
                ),
              ),
            ),

          // Toggle Options
          Row(
            children: [
              _buildToggleOption(0, Icons.group),
              _buildToggleOption(1, Icons.person),
              _buildToggleOption(2, Icons.pie_chart_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(int viewIndex, IconData icon) {
    final isSelected = _currentView == viewIndex;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredView = viewIndex;
            _showHoverIndicator = true;
          });

          // Start timer to hide hover after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && _hoveredView == viewIndex) {
              setState(() {
                _showHoverIndicator = false;
                _hoveredView = null;
              });
            }
          });
        },
        onExit: (_) {
          setState(() {
            _showHoverIndicator = false;
            _hoveredView = null;
          });
        },
        child: GestureDetector(
          onTap: () {
            _handleViewChange(viewIndex);
          },
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: _getBorderRadiusForOption(viewIndex),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  void _handleViewChange(int viewIndex) {
    setState(() {
      _currentView = viewIndex;
      _showHoverIndicator = false;
      _hoveredView = null;
    });

    // Update the viewModel for backward compatibility
    if (viewIndex == 0 || viewIndex == 1) {
      if (widget.viewModel.showIndividualGraphs != (viewIndex == 1)) {
        widget.viewModel.toggleGraphView();
      }
    }

    // Call the callback if provided
    widget.onViewChanged?.call(viewIndex);
  }

  BorderRadius _getBorderRadiusForOption(int index) {
    switch (index) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        );
      case 1:
        return BorderRadius.zero;
      case 2:
        return const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      default:
        return BorderRadius.zero;
    }
  }

  BorderRadius _getBorderRadiusForPosition(int index) {
    switch (index) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        );
      case 1:
        return BorderRadius.zero;
      case 2:
        return const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      default:
        return BorderRadius.zero;
    }
  }

  LinearGradient _getGradientForView(int viewIndex) {
    switch (viewIndex) {
      case 0:
        return LinearGradient(
          colors: [Colors.cyan.shade400, Colors.blue.shade400],
        );
      case 1:
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.amber.shade400],
        );
      case 2:
        return LinearGradient(
          colors: [Colors.purple.shade400, Colors.pink.shade400],
        );
      default:
        return LinearGradient(
          colors: [Colors.cyan.shade400, Colors.blue.shade400],
        );
    }
  }

  Color _getColorForView(int viewIndex) {
    switch (viewIndex) {
      case 0:
        return Colors.cyan.shade400;
      case 1:
        return Colors.orange.shade400;
      case 2:
        return Colors.purple.shade400;
      default:
        return Colors.cyan.shade400;
    }
  }
}

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class GraphToggle extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final Function(int)? onViewChanged;

//   const GraphToggle({super.key, required this.viewModel, this.onViewChanged});

//   @override
//   State<GraphToggle> createState() => _GraphToggleState();
// }

// class _GraphToggleState extends State<GraphToggle> {
//   int _currentView = 0; // 0 = Merged, 1 = Individual, 2 = Project

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white.withOpacity(0.15),
//               Colors.white.withOpacity(0.05),
//             ],
//           ),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Current View Icon
//             _buildViewIcon(),
//             const SizedBox(width: 12),

//             // Three-Way Toggle Switch
//             _buildThreeWayToggle(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViewIcon() {
//     IconData icon;
//     Color color;

//     switch (_currentView) {
//       case 0:
//         icon = Icons.group;
//         color = Colors.cyan.shade300;
//         break;
//       case 1:
//         icon = Icons.person;
//         color = Colors.orange.shade300;
//         break;
//       case 2:
//         icon = Icons.pie_chart_rounded;
//         color = Colors.purple.shade300;
//         break;
//       default:
//         icon = Icons.group;
//         color = Colors.cyan;
//     }

//     return Icon(icon, size: 18, color: color);
//   }

//   Widget _buildThreeWayToggle() {
//     return Container(
//       width: 80,
//       height: 32,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Stack(
//         children: [
//           // Background Selection
//           AnimatedPositioned(
//             duration: const Duration(milliseconds: 300),
//             left: _currentView * 26.0, // 26px per option
//             child: Container(
//               width: 26,
//               height: 32,
//               decoration: BoxDecoration(
//                 borderRadius: _getBorderRadiusForPosition(_currentView),
//                 gradient: _getGradientForView(_currentView),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _getColorForView(_currentView).withOpacity(0.4),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Toggle Options
//           Row(
//             children: [
//               _buildToggleOption(0, Icons.group),
//               _buildToggleOption(1, Icons.person),
//               _buildToggleOption(2, Icons.pie_chart_rounded),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleOption(int viewIndex, IconData icon) {
//     final isSelected = _currentView == viewIndex;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _currentView = viewIndex;
//           });

//           // Update the viewModel for backward compatibility
//           if (viewIndex == 0 || viewIndex == 1) {
//             if (widget.viewModel.showIndividualGraphs != (viewIndex == 1)) {
//               widget.viewModel.toggleGraphView();
//             }
//           }

//           // Call the callback if provided
//           widget.onViewChanged?.call(viewIndex);
//         },
//         child: Container(
//           height: 32,
//           decoration: BoxDecoration(
//             borderRadius: _getBorderRadiusForOption(viewIndex),
//           ),
//           child: Icon(
//             icon,
//             size: 16,
//             color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
//           ),
//         ),
//       ),
//     );
//   }

//   BorderRadius _getBorderRadiusForOption(int index) {
//     switch (index) {
//       case 0:
//         return const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           bottomLeft: Radius.circular(8),
//         );
//       case 1:
//         return BorderRadius.zero;
//       case 2:
//         return const BorderRadius.only(
//           topRight: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         );
//       default:
//         return BorderRadius.zero;
//     }
//   }

//   BorderRadius _getBorderRadiusForPosition(int index) {
//     switch (index) {
//       case 0:
//         return const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           bottomLeft: Radius.circular(8),
//         );
//       case 1:
//         return BorderRadius.zero;
//       case 2:
//         return const BorderRadius.only(
//           topRight: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         );
//       default:
//         return BorderRadius.zero;
//     }
//   }

//   LinearGradient _getGradientForView(int viewIndex) {
//     switch (viewIndex) {
//       case 0:
//         return LinearGradient(
//           colors: [Colors.cyan.shade400, Colors.blue.shade400],
//         );
//       case 1:
//         return LinearGradient(
//           colors: [Colors.orange.shade400, Colors.amber.shade400],
//         );
//       case 2:
//         return LinearGradient(
//           colors: [Colors.purple.shade400, Colors.pink.shade400],
//         );
//       default:
//         return LinearGradient(
//           colors: [Colors.cyan.shade400, Colors.blue.shade400],
//         );
//     }
//   }

//   Color _getColorForView(int viewIndex) {
//     switch (viewIndex) {
//       case 0:
//         return Colors.cyan.shade400;
//       case 1:
//         return Colors.orange.shade400;
//       case 2:
//         return Colors.purple.shade400;
//       default:
//         return Colors.cyan.shade400;
//     }
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class GraphToggle extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const GraphToggle({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight, // Right side alignment
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white.withOpacity(0.15),
//               Colors.white.withOpacity(0.05),
//             ],
//           ),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         ),
//         child: GestureDetector(
//           onTap: viewModel.toggleGraphView,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Current View Icon
//               Icon(
//                 viewModel.showIndividualGraphs
//                     ? Icons.person_rounded
//                     : Icons.person_alt_rounded,
//                 size: 18,
//                 color: Colors.cyan.shade300,
//               ),
//               const SizedBox(width: 8),

//               // Toggle Switch
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 width: 40,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   gradient: LinearGradient(
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                     colors: viewModel.showIndividualGraphs
//                         ? [Colors.cyan.shade400, Colors.blue.shade400]
//                         : [Colors.purple.shade400, Colors.pink.shade400],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color:
//                           (viewModel.showIndividualGraphs
//                                   ? Colors.cyan.shade400
//                                   : Colors.purple.shade400)
//                               .withOpacity(0.4),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Stack(
//                   children: [
//                     // Toggle Knob
//                     AnimatedAlign(
//                       duration: const Duration(milliseconds: 300),
//                       alignment: viewModel.showIndividualGraphs
//                           ? Alignment.centerLeft
//                           : Alignment.centerRight,
//                       child: Container(
//                         margin: const EdgeInsets.all(2),
//                         width: 16,
//                         height: 16,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 3,
//                               offset: const Offset(0, 1),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class GraphToggle extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const GraphToggle({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.blue.shade900.withOpacity(0.8),
//             Colors.purple.shade800.withOpacity(0.7),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.shade700.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//       ),
//       child: Row(
//         children: [
//           // View Mode Indicator
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1.5,
//               ),
//             ),
//             child: Icon(
//               viewModel.showIndividualGraphs
//                   ? Icons.person_rounded
//                   : Icons.person_alt_rounded,
//               color: Colors.cyan.shade300,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),

//           // View Information
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   viewModel.showIndividualGraphs
//                       ? 'INDIVIDUAL ANALYSIS'
//                       : 'TEAM NETWORK',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                     letterSpacing: 0.8,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   viewModel.showIndividualGraphs
//                       ? 'Single node performance metrics'
//                       : 'Collective team analytics',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.8),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Toggle Switch
//           GestureDetector(
//             onTap: viewModel.toggleGraphView,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               width: 60,
//               height: 30,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 gradient: LinearGradient(
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                   colors: viewModel.showIndividualGraphs
//                       ? [Colors.cyan.shade400, Colors.blue.shade400]
//                       : [Colors.purple.shade400, Colors.pink.shade400],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color:
//                         (viewModel.showIndividualGraphs
//                                 ? Colors.cyan.shade400
//                                 : Colors.purple.shade400)
//                             .withOpacity(0.4),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   // Toggle Knob
//                   AnimatedAlign(
//                     duration: const Duration(milliseconds: 300),
//                     alignment: viewModel.showIndividualGraphs
//                         ? Alignment.centerLeft
//                         : Alignment.centerRight,
//                     child: Container(
//                       margin: const EdgeInsets.all(3),
//                       width: 24,
//                       height: 24,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         viewModel.showIndividualGraphs
//                             ? Icons.person_rounded
//                             : Icons.person_alt_rounded,
//                         size: 12,
//                         color: viewModel.showIndividualGraphs
//                             ? Colors.cyan.shade400
//                             : Colors.purple.shade400,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';

// class GraphToggle extends StatelessWidget {
//   final AttendanceAnalyticsViewModel viewModel;

//   const GraphToggle({super.key, required this.viewModel});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             viewModel.showIndividualGraphs
//                 ? 'Individual View'
//                 : 'Team Overview',
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           GestureDetector(
//             onTap: viewModel.toggleGraphView,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: AppColors.primary,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     viewModel.showIndividualGraphs
//                         ? Icons.person_alt_rounded
//                         : Icons.person_rounded,
//                     color: AppColors.white,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     viewModel.showIndividualGraphs ? 'Team View' : 'Individual',
//                     style: const TextStyle(
//                       color: AppColors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
