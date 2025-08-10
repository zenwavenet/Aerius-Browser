import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/browser_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0A0A0A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(AeriusBrowser());
}

class AeriusBrowser extends StatelessWidget {
  const AeriusBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aerius Browser',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF1A1A1A),
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFF00C853),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: BrowserHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
