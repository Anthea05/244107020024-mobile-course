import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const ProfilPage(),
    );
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'ANTHEA AMODIA',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'NIM: 244107020024',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                'D4 Teknik Informatika - Polinema',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              const ListTile(
                leading: Icon(Icons.email, color: Colors.indigo),
                title: Text('Email'),
                subtitle: Text('amodiasyaffah@gmail.com'),
              ),
              const ListTile(
                leading: Icon(Icons.favorite, color: Colors.indigo),
                title: Text('Hobi'),
                subtitle: Text('listening mucic and idk '),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
