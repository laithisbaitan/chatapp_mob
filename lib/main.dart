import 'package:chatapp_mob/widgets/rooms.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatting App',
      home: MaterialApp(
        title: "Chatapp",
        home: const WRooms(),
        routes: {
          WRooms.id: (context) => const WRooms(),
        },
      ),
    );
  }
}
