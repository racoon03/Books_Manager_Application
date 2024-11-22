import 'package:ct484_project/ui/shared/footer_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import './ui/screens.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        error: Colors.red,
        surface: Colors.white,
        surfaceTint: Colors.grey[200],
        primary: Colors.blue,
        onError: Colors.white,
        secondary: Colors.blue,
        onSecondary: Colors.white,
        brightness: Brightness.light);
    final themeData = ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          // shadowColor: colorScheme.shadow,
          elevation: 4,
        ),
        dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
            )));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => MembersManager()),
        ChangeNotifierProvider(create: (ctx) => CardsManager()),
        ChangeNotifierProvider(create: (ctx) => BooksManager()),
        ChangeNotifierProvider(create: (ctx) => AuthManager()),
      ],
      child: Consumer<AuthManager>(
        builder: (ctx, authManager, _) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: themeData,
            home: authManager.isAuth
                ? const Home() // Nếu đã xác thực, điều hướng đến trang Home
                : FutureBuilder(
                    future: authManager.tryAutoLogin(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SplashScreen(); // Hiển thị SplashScreen khi đang kiểm tra đăng nhập tự động
                      }
                      return const AuthScreen(); // Hiển thị AuthScreen nếu không tự động đăng nhập được
                    },
                  ),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case MemberDetailsView.routeName:
                  final id = settings.arguments as String;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => MemberDetailsView(
                        context.read<MembersManager>().findById(id)!),
                  );
                case MemberAddForm.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const MemberAddForm(),
                  );
                case MemberExtendForm.routeName:
                  final id = settings.arguments as String;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => MemberExtendForm(
                        context.read<MembersManager>().findById(id)!),
                  );
                case MemberEditForm.routeName:
                  final id = settings.arguments as String;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => MemberEditForm(
                        context.read<MembersManager>().findById(id)!),
                  );

                case CardAddForm.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const CardAddForm(),
                  );
                // case of book
                case BooksListView.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const BooksListView(),
                  );
                case BookForm.routeName:
                  // Kiểm tra nếu có `settings.arguments`, và ép kiểu về `int`
                  final bookId = settings.arguments as String?;
                  return MaterialPageRoute(
                    builder: (context) => BookForm(bookId: bookId),
                  );
                case DeleteBookScreen.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const DeleteBookScreen(),
                  );
                case RestoreBookScreen.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const RestoreBookScreen(),
                  );
                case BookDetailScreen.routeName:
                  final bookId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (context) => BookDetailScreen(bookId: bookId),
                  );
                default:
                  return null; // Handle other routes or return a default route
              }
            },
          );
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  BooksListView(), // BookScreen(),
                  MembersListView(), // MemberScreen(),
                  CardsListScreen(), // CardScreen(),
                ],
              ),
            ),
            NavbarFooter(), // Display NavbarFooter at the bottom
          ],
        ),
      ),
    );
  }
}
