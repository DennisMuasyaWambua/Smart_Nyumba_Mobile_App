import 'package:flutter/material.dart';

import 'caretaker_home.dart';

class CaretakerDashboard extends StatelessWidget {
  static const routeName = '/caretaker-dashboard';

  const CaretakerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const CaretakerHome();
  }
}
