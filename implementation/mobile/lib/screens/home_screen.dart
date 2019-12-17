import 'package:flutter/material.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildCard("Card 1"),
          ),
          Expanded(
            child: _buildCard("Card 2"),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Card _buildCard(String title) {
    return Card(
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Placeholder(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 10.0,
                      offset: Offset(1.0, 4.0),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          print('pressed');
        },
      ),
    );
  }
}
