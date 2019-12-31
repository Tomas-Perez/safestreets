import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _buildCard(
              title: 'Report a violation',
              asset: 'images/traffic-violation-card.jpg',
              onPressed: () => Navigator.pushNamed(context, REPORT),
            ),
          ),
          Expanded(
            child: _buildCard(
              title: 'Reports map',
              asset: 'images/reports-map-card.jpg',
              onPressed: () => Navigator.pushNamed(context, MAP),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Card _buildCard({
    @required String title,
    @required String asset,
    @required VoidCallback onPressed,
  }) {
    return Card(
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Image.asset(asset, fit: BoxFit.fitWidth),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                ),
              ),
            ),
          ],
        ),
        onTap: onPressed,
      ),
    );
  }
}
