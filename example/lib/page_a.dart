import 'package:flutter/cupertino.dart';

class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 200),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("tap page a null key");
            },
            child: const Text('null key'),
          ),
          GestureDetector(
            key: const Key('page-a-click'),
            onTap: () {
              print("tap page a");
            },
            child: const Text('have key'),
          )
        ],
      ),
    );
  }
}
