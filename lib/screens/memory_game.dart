import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;

  List<GameCard> cards = [];
  List<int> selectedCards = [];
  int matches = 0;
  bool isChecking = false;
  int moves = 0;
  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int timeElapsed = 0;
  bool gameStarted = false;
  String difficulty = 'Medium';

  final List<ParticleExplosion> _explosions = [];

  final List<String> animals = [
    '🐯',
    '🐼',
    '🐻',
    '🐵',
    '🦁',
    '🐸',
    '🐰',
    '🐨',
    '🦊',
    '🐶',
    '🐱',
    '🐮',
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int _getPairCount() {
    switch (difficulty) {
      case 'Easy':
        return 4;
      case 'Hard':
        return 8;
      default:
        return 6;
    }
  }

  void _initializeGame() {
    cards.clear();
    selectedCards.clear();
    matches = 0;
    moves = 0;
    score = 0;
    combo = 0;
    maxCombo = 0;
    timeElapsed = 0;
    isChecking = false;
    gameStarted = false;
    _explosions.clear();

    int pairCount = _getPairCount();
    List<String> gameAnimals = animals.take(pairCount).toList();
    List<String> cardValues = [...gameAnimals, ...gameAnimals];
    cardValues.shuffle();

    for (int i = 0; i < cardValues.length; i++) {
      cards.add(
        GameCard(
          id: i,
          value: cardValues[i],
          isFlipped: false,
          isMatched: false,
        ),
      );
    }
    setState(() {});
  }

  void _startTimer() {
    if (!gameStarted) {
      gameStarted = true;
      _runTimer();
    }
  }

  void _runTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && gameStarted && matches < _getPairCount()) {
        setState(() => timeElapsed++);
        _runTimer();
      }
    });
  }

  void _onCardTap(int cardId) {
    if (!gameStarted) _startTimer();

    if (isChecking ||
        cards[cardId].isFlipped ||
        cards[cardId].isMatched ||
        selectedCards.length >= 2) {
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      cards[cardId].isFlipped = true;
      selectedCards.add(cardId);
    });

    if (selectedCards.length == 2) {
      moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    isChecking = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (cards[selectedCards[0]].value == cards[selectedCards[1]].value) {
        HapticFeedback.mediumImpact();

        setState(() {
          cards[selectedCards[0]].isMatched = true;
          cards[selectedCards[1]].isMatched = true;
          matches++;
          combo++;

          int comboBonus = combo > 1 ? (combo - 1) * 50 : 0;
          score += 100 + comboBonus;

          if (combo > maxCombo) maxCombo = combo;

          _createExplosion(selectedCards[0]);
          _createExplosion(selectedCards[1]);
        });

        _pulseController.forward(from: 0);

        if (matches == _getPairCount()) {
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _showWinDialog();
          });
        }
      } else {
        HapticFeedback.lightImpact();
        setState(() {
          cards[selectedCards[0]].isFlipped = false;
          cards[selectedCards[1]].isFlipped = false;
          combo = 0;
        });
      }

      setState(() {
        selectedCards.clear();
        isChecking = false;
      });
    });
  }

  void _createExplosion(int cardIndex) {
    final explosion = ParticleExplosion(
      position: Offset(
        (cardIndex % 4) * 100.0 + 50,
        (cardIndex ~/ 4) * 120.0 + 60,
      ),
    );
    _explosions.add(explosion);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _explosions.remove(explosion));
      }
    });
  }

  void _showWinDialog() {
    int timeBonus = max(0, 300 - timeElapsed * 5);
    int finalScore = score + timeBonus;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Column(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              const Text(
                'Victory!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E8B57),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WinStatRow(label: 'Score', value: '$finalScore', icon: '🏆'),
              _WinStatRow(label: 'Moves', value: '$moves', icon: '🎯'),
              _WinStatRow(label: 'Time', value: '${timeElapsed}s', icon: '⏱️'),
              _WinStatRow(label: 'Max Combo', value: 'x$maxCombo', icon: '🔥'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF20B2AA).withValues(alpha: 0.2),
                      Color(0xFF2E8B57).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRating(moves, timeElapsed),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E8B57),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _initializeGame());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF20B2AA), Color(0xFF2E8B57)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Exit',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getRating(int moves, int time) {
    int totalScore = 1000 - (moves * 10) - (time * 5);
    if (totalScore >= 800) return '⭐⭐⭐ PERFECT!';
    if (totalScore >= 600) return '⭐⭐ GREAT!';
    if (totalScore >= 400) return '⭐ GOOD!';
    return 'COMPLETE!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF20B2AA),
                    const Color(0xFF008B8B),
                    (_backgroundController.value * 2) % 1,
                  )!,
                  const Color(0xFF2E8B57),
                  Color.lerp(
                    const Color(0xFF008B8B),
                    const Color(0xFF20B2AA),
                    (_backgroundController.value * 2) % 1,
                  )!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStats(),
              const SizedBox(height: 20),
              _buildGameGrid(),
              _buildControls(),
              _buildDecorations(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _sparkleAnimation,
            builder: (context, child) {
              return Row(
                children: [
                  Transform.rotate(
                    angle: _sparkleAnimation.value * 2 * pi,
                    child: const Text('✨', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Memory Master',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.rotate(
                    angle: -_sparkleAnimation.value * 2 * pi,
                    child: const Text('✨', style: TextStyle(fontSize: 24)),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _AnimatedStatCard(
                  label: 'Score',
                  value: score.toString(),
                  icon: '🏆',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AnimatedStatCard(
                  label: 'Moves',
                  value: moves.toString(),
                  icon: '🎯',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AnimatedStatCard(
                  label: 'Time',
                  value: '${timeElapsed}s',
                  icon: '⏱️',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: combo > 0
                          ? [
                              Colors.orange.withValues(alpha: 0.3),
                              Colors.red.withValues(alpha: 0.3),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: combo > 0
                          ? Colors.orange
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (combo > 1) ...[
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        combo > 0
                            ? 'COMBO x$combo'
                            : 'Match cards to build combo!',
                        style: TextStyle(
                          color: combo > 0
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    int crossAxisCount = 4;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return _GameCardWidget(
                  card: cards[index],
                  onTap: () => _onCardTap(index),
                );
              },
            ),
            ..._explosions.map(
              (explosion) => _ParticleWidget(explosion: explosion),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DifficultyButton(
                label: 'Easy',
                isSelected: difficulty == 'Easy',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    difficulty = 'Easy';
                    _initializeGame();
                  });
                },
              ),
              const SizedBox(width: 8),
              _DifficultyButton(
                label: 'Medium',
                isSelected: difficulty == 'Medium',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    difficulty = 'Medium';
                    _initializeGame();
                  });
                },
              ),
              const SizedBox(width: 8),
              _DifficultyButton(
                label: 'Hard',
                isSelected: difficulty == 'Hard',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    difficulty = 'Hard';
                    _initializeGame();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _initializeGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E8B57),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 8,
            ),
            child: const Text(
              '🎮 New Game',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorations() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Transform.scale(
                scale: 0.5 + _sparkleAnimation.value * 0.5,
                child: const Text('✨', style: TextStyle(fontSize: 28)),
              ),
              Transform.scale(
                scale: 1.0 - _sparkleAnimation.value * 0.3,
                child: const Text('⭐', style: TextStyle(fontSize: 24)),
              ),
              Transform.scale(
                scale: 0.7 + _sparkleAnimation.value * 0.3,
                child: const Text('💫', style: TextStyle(fontSize: 26)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _AnimatedStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E8B57)
                : Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2E8B57) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _WinStatRow extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _WinStatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E8B57),
            ),
          ),
        ],
      ),
    );
  }
}

// ⭐ IMPROVED CARD WIDGET WITH PERFECT FLIP ANIMATION ⭐
class _GameCardWidget extends StatefulWidget {
  final GameCard card;
  final VoidCallback onTap;

  const _GameCardWidget({required this.card, required this.onTap});

  @override
  State<_GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<_GameCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(_GameCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          // Determine which side to show based on rotation angle
          final bool showFront = _flipAnimation.value < pi / 2;

          // Calculate the actual rotation for the current side
          final angle = showFront
              ? _flipAnimation.value
              : pi - _flipAnimation.value;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Add perspective for 3D effect
              ..rotateY(angle),
            child: showFront ? _buildFrontCard() : _buildBackCard(),
          );
        },
      ),
    );
  }

  // Front side of the card (showing "?")
  Widget _buildFrontCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 52,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black38,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Back side of the card (showing emoji)
  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi), // Mirror the back side
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: widget.card.isMatched
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withValues(alpha: 0.7),
                    Colors.greenAccent.withValues(alpha: 0.5),
                    Colors.lightGreen.withValues(alpha: 0.6),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.card.isMatched ? Colors.greenAccent : Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.card.isMatched
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: widget.card.isMatched ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.card.value,
            style: TextStyle(
              fontSize: 60,
              shadows: widget.card.isMatched
                  ? [const Shadow(blurRadius: 15, color: Colors.white)]
                  : [],
            ),
          ),
        ),
      ),
    );
  }
}

class GameCard {
  final int id;
  final String value;
  bool isFlipped;
  bool isMatched;

  GameCard({
    required this.id,
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class ParticleExplosion {
  final Offset position;
  final List<Particle> particles;

  ParticleExplosion({required this.position})
    : particles = List.generate(20, (index) {
        final random = Random();
        final angle = random.nextDouble() * 2 * pi;
        final speed = 2.0 + random.nextDouble() * 3.0;
        return Particle(
          position: position,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: Colors.primaries[random.nextInt(Colors.primaries.length)],
          size: 4.0 + random.nextDouble() * 4.0,
        );
      });
}

class Particle {
  Offset position;
  final Offset velocity;
  final Color color;
  final double size;
  double life = 1.0;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
}

class _ParticleWidget extends StatefulWidget {
  final ParticleExplosion explosion;

  const _ParticleWidget({required this.explosion});

  @override
  State<_ParticleWidget> createState() => _ParticleWidgetState();
}

class _ParticleWidgetState extends State<_ParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _controller.addListener(() {
      setState(() {
        for (var particle in widget.explosion.particles) {
          particle.position += particle.velocity;
          particle.life = 1.0 - _controller.value;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(widget.explosion.particles),
      child: Container(),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.life)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
