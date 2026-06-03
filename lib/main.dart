import 'package:flutter/material.dart';
import 'package:medical_tracker/providers/medicine_provider.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/customer_provider.dart';
import 'providers/purchase_provider.dart';
import 'screens/home_screen.dart';
import 'screens/customers/add_customer_screen.dart';
import 'screens/customers/customer_detail_screen.dart';
import 'screens/purchases/add_purchase_screen.dart';
import 'screens/reminders/reminder_list_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.printConfig();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // State management providers
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()), // Add this

      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/add-customer': (context) => const AddCustomerScreen(),
          '/add-purchase': (context) => const AddPurchaseScreen(),
          '/reminders': (context) => const ReminderListScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes with arguments
          if (settings.name == '/customer-detail') {
            final customerId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => CustomerDetailScreen(customerId: customerId),
            );
          }
          if (settings.name == '/add-purchase') {
            final arguments = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AddPurchaseScreen(
                customer: arguments?['customer'],
                medicine: arguments?['medicine'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
