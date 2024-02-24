import 'package:auto_track_example/page_a.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('page a'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const PageA();
            }));
          },
        )
      ],
    );
  }
}
