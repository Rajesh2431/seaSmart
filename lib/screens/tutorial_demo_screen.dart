import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../widgets/guided_tour_widget.dart';
import '../services/guided_tour_service.dart';

class TutorialDemoScreen extends StatefulWidget {
  const TutorialDemoScreen({super.key});

  @override
  State<TutorialDemoScreen> createState() => _TutorialDemoScreenState();
}

class _TutorialDemoScreenState extends State<TutorialDemoScreen> {
  final GlobalKey _parentKey = GlobalKey();
  final Map<String, GlobalKey> _tutorialKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeTutorialKeys();
  }

  void _initializeTutorialKeys() {
    _tutorialKeys['button1'] = GlobalKey();
    _tutorialKeys['button2'] = GlobalKey();
    _tutorialKeys['card1'] = GlobalKey();
    _tutorialKeys['card2'] = GlobalKey();
  }

  void _startTutorial() {
    print('🚀 [TUTORIAL_DEMO] Starting tutorial demo...');
    GuidedTourService.startTour(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Demo'),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        actions: [
          TourTriggerButton(),
        ],
      ),
      body: ShowCaseWidget(
        builder: (context) => Padding(
          key: _parentKey,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Start Tutorial Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _startTutorial,
                  icon: const Icon(Icons.tour),
                  label: const Text('Start Tutorial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Demo elements with guided tour widgets
              GuidedTourWidget(
                targetKey: _tutorialKeys['button1']!,
                title: "Demo Button 1",
                description: "This is the first demo button. Click it to see what happens!",
                icon: Icons.touch_app,
                color: const Color(0xFF3498DB),
                child: ElevatedButton(
                  key: _tutorialKeys['button1'],
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Button 1 clicked!')),
                    );
                  },
                  child: const Text('Demo Button 1'),
                ),
              ),

              const SizedBox(height: 20),

              GuidedTourWidget(
                targetKey: _tutorialKeys['card1']!,
                title: "Demo Card 1",
                description: "This is a demo card that will be highlighted during the tutorial.",
                icon: Icons.card_giftcard,
                color: const Color(0xFF9B59B6),
                child: Container(
                  key: _tutorialKeys['card1'],
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Card 1',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This is a demo card that will be highlighted during the tutorial.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GuidedTourWidget(
                targetKey: _tutorialKeys['button2']!,
                title: "Demo Button 2",
                description: "This is the second demo button with different styling.",
                icon: Icons.touch_app,
                color: const Color(0xFF2ECC71),
                child: ElevatedButton(
                  key: _tutorialKeys['button2'],
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Button 2 clicked!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Demo Button 2'),
                ),
              ),

              const SizedBox(height: 20),

              GuidedTourWidget(
                targetKey: _tutorialKeys['card2']!,
                title: "Demo Card 2",
                description: "Another demo card to showcase the tutorial system.",
                icon: Icons.card_giftcard,
                color: const Color(0xFFE67E22),
                child: Container(
                  key: _tutorialKeys['card2'],
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Card 2',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Another demo card to showcase the tutorial system.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Tour information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tutorial System Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Interactive guided tour with spotlight effects\n'
                      '• Skip functionality at any time\n'
                      '• Progress tracking and completion status\n'
                      '• Responsive design for all screen sizes\n'
                      '• Fallback dialogs for error handling',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}