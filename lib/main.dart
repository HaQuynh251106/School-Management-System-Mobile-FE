import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = AppSession();
  await session.bootstrap();
  runApp(
    ChangeNotifierProvider.value(value: session, child: const SmartSchoolApp()),
  );
}
