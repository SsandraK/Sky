import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sky Map')),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
        
            Image.asset(
              'assets/bg_sky.jpeg',
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0), 
              child: Container(
                color: Colors.black.withOpacity(0), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
