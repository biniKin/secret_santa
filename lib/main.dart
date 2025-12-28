import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secrete_santa/firebase_options.dart';
import 'package:secrete_santa/services/notification_service.dart';
import 'package:secrete_santa/ui/auth_page/auth_bloc/auth_bloc.dart';
import 'package:secrete_santa/ui/auth_wrapper.dart';
import 'package:secrete_santa/ui/create_group/create_group_bloc/create_bloc.dart';
import 'package:secrete_santa/ui/group_info_page/group_info_bloc/group_info_bloc.dart';
import 'package:secrete_santa/ui/home/home_bloc/home_bloc.dart';
import 'package:secrete_santa/ui/join_group/join_group_bloc/join_group_bloc.dart';
import 'package:secrete_santa/ui/profile_page/profile_page_bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications with error handling
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    print('Failed to initialize notifications: $e');
    // App can still run without notifications
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => CreateGroupBloc()),
        BlocProvider(create: (_) => GroupInfoBloc()),
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => JoinGroupBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFAD2E2E)),
      ),
      home: const AuthWrapper(),
    );
  }
}
