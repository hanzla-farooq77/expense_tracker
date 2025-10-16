import 'package:expense_tracker/theme/theme.dart';
import 'package:expense_tracker/views/add_expenses.dart';
import 'package:expense_tracker/views/expense_details.dart';
import 'package:expense_tracker/views/expense_list.dart';
import 'package:expense_tracker/views/login_screen.dart';
import 'package:expense_tracker/views/signupscreen.dart';
import 'package:expense_tracker/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) =>  SplashScreen(),
        '/expenses': (context) =>  ExpenseListView(),
        '/signup': (context) =>  SignupScreen(),
        '/login': (context) =>  LoginScreen(),
        '/details': (context) =>  ExpenseDetailsView(),
        '/addexpense': (context) =>  AddExpenseView(),
      },
    );
  }
}
