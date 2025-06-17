import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/purchase_order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/warehouse_provider.dart';
import 'providers/goods_receipt_provider.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_gr_screen.dart';

void main() {
  // Inisialisasi Flutter
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const RootApp(),
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        final apiService = auth.apiService;

        if (auth.isLoggedIn && apiService != null) {
          // Jika sudah login dan apiService tersedia, buat MultiProvider yang butuh apiService
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ProductProvider(apiService: apiService),
              ),
              ChangeNotifierProvider(
                create: (_) => VendorProvider(apiService: apiService),
              ),
              ChangeNotifierProvider(
                create: (_) => PurchaseOrderProvider(apiService: apiService),
              ),
              ChangeNotifierProvider(
                create:
                    (_) => WarehouseProvider(
                      apiService: apiService,
                    ), // Perbaiki: inject apiService
              ),
              ChangeNotifierProvider(
                create:
                    (_) => GoodsReceiptProvider(
                      apiService: apiService,
                    ), // Tambahkan provider GR
              ),
            ],
            child: MaterialApp(
              title: 'Purchase Order App',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1A4A8B),
                  primary: const Color(0xFF1A4A8B),
                  secondary: Colors.orangeAccent,
                  surface: const Color(0xFFEDF4FB),
                ),
                scaffoldBackgroundColor: const Color(0xFFEDF4FB),
                cardTheme: CardTheme(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                ),
                listTileTheme: const ListTileThemeData(
                  iconColor: Color(0xFF1A4A8B),
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1A4A8B),
                  foregroundColor: Colors.white,
                  elevation: 1,
                  centerTitle: true,
                ),
                fontFamily: 'Roboto',
                useMaterial3: true,
              ),
              home: const HomeScreen(),
              routes: {
                '/create-gr': (context) => const CreateGoodsReceiptScreen(),
              },
            ),
          );
        }

        // Jika belum login, tampilkan LoginScreen dengan MaterialApp
        return MaterialApp(
          title: 'Purchase Order App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A4A8B),
              primary: const Color(0xFF1A4A8B),
              secondary: Colors.orangeAccent,
            ),
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
