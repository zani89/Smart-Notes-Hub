import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_card/flip_card.dart';
import '../../widgets/glass_container.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Flashcard Deck', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('AI-generated concept cards', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Dummy data for now
              itemBuilder: (context, index) => _buildFlipCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: GlassContainer(
          color: const Color(0xFFBC13FE),
          height: 200,
          child: Center(
            child: Text(
              'What is the capital of Flutter?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        back: GlassContainer(
          color: const Color(0xFF00BFA5),
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Dartland!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ratingButton('Easy', Colors.green),
                    const SizedBox(width: 10),
                    _ratingButton('Hard', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
