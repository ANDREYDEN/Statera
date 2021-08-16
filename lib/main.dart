import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:statera/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (const bool.fromEnvironment('USE_EMULATORS')) {
    // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    print("Emulators intialized");
    // FirebaseFirestore.instance.settings = const Settings(
    //   host: 'localhost:8080',
    //   sslEnabled: false,
    //   persistenceEnabled: false,
    // );
  }

  runApp(Statera());
}

class Statera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Nunito",
      ),
      home: MainNavigation(),
    );
  }
}
