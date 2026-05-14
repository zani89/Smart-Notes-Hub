import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C222D),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Icon(icon, size: 64, color: const Color(0xFF00BFA5).withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF8B949E)),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(actionLabel ?? 'Try Again', style: const TextStyle(color: Colors.black)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
