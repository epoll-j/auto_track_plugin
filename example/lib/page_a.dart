import 'package:flutter/cupertino.dart';

class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("tap page a");
      },
      child: const Text('page a'),
    );
  }
}
