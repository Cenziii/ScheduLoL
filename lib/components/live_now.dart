import 'package:flutter/material.dart';

class LiveNowWidget extends StatefulWidget {
  const LiveNowWidget({super.key});

  @override
  _LiveNowWidgetState createState() => _LiveNowWidgetState();
}

class _LiveNowWidgetState extends State<LiveNowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true); 

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade700, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.circle, color: Colors.white, size: 10),
            SizedBox(width: 6),
            Text(
              "LIVE NOW",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
