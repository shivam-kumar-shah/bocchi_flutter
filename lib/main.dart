import 'package:anime_api/screens/library_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/user_preferences.dart';
import '../screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import './screens/details_screen.dart';
import './screens/home_screen.dart';
import 'constants/app_colors.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> setRefreshRate() async {
    final supported = await FlutterDisplayMode.supported;
    await FlutterDisplayMode.setPreferredMode(supported[1]);
    setState(() {});
  }

  @override
  void initState() {
    setRefreshRate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider(
        create: (context) => Watchlist(),
        builder: (context, _) => FutureBuilder(
              future: Provider.of<Watchlist>(context, listen: false).fetchAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  FlutterNativeSplash.remove();
                }
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  darkTheme: ThemeData.dark().copyWith(
                    useMaterial3: true,
                    colorScheme: const ColorScheme.dark().copyWith(
                      primary: AppColors.green,
                    ),
                    textTheme: TextTheme(
                      displayLarge: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      titleMedium: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    inputDecorationTheme: const InputDecorationTheme(
                      fillColor: AppColors.lightblack,
                    ),
                    cardColor: AppColors.lightblack,
                    scaffoldBackgroundColor: AppColors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.green,
                      ),
                    ),
                  ),
                  themeMode: ThemeMode.dark,
                  home: const Home(),
                  routes: {
                    DetailsScreen.routeName: (context) => const DetailsScreen(),
                  },
                );
              },
            ));
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  Widget _buildHome() {
    if (_currentIndex == 0) {
      return const HomeScreen();
    }
    if (_currentIndex == 1) {
      return const SearchScreen();
    }
    return const LibraryScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        items: const [
          Icon(Icons.home),
          Icon(Icons.search_rounded),
          Icon(Icons.video_library_rounded),
        ],
        buttonBackgroundColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.primary,
        animationCurve: Curves.easeOutCubic,
        animationDuration: const Duration(milliseconds: 300),
        height: 50,
        index: 0,
        onTap: (value) {
          if (_currentIndex == value) return;
          setState(() {
            _currentIndex = value;
          });
        },
      ),
      body: _buildHome(),
    );
  }
}
