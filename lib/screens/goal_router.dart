// // goals_router.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'goal_set.dart';
// import 'goal_settings.dart'; // GoalSet

// class GoalsRouter extends StatefulWidget {
//   final String? userEmail;
//   const GoalsRouter({super.key, this.userEmail});

//   @override
//   State<GoalsRouter> createState() => _GoalsRouterState();
// }

// class _GoalsRouterState extends State<GoalsRouter> {
//   Widget? _target;

//   @override
//   void initState() {
//     super.initState();
//     _decide();
//   }

//   Future<void> _decide() async {
//     final prefs = await SharedPreferences.getInstance();
//     final preferGoalSet =
//         prefs.getBool('prefer_goal_set') ?? true; // toggle as needed

//     // Choose one subtree; do not navigate, just return the chosen widget.
//     final chosen = preferGoalSet
//         ? GoalSet(userEmail: widget.userEmail)
//         : GoalPage(userEmail: widget.userEmail);

//     if (!mounted) return;
//     setState(() => _target = chosen);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Empty shell until decision is made
//     if (_target == null) {
//       return const Scaffold(body: SizedBox.shrink());
//     }
//     return _target!;
//   }
// }
