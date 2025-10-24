import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/color_provider.dart';
import 'screens/color_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ColorProvider()..load(),
      child: MaterialApp(
        title: 'Color Model CRUD',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const ColorListScreen(),
      ),
    );
  }
}
