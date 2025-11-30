import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Matikanetannhauser"), centerTitle: true),
        body: Center(
          child: Image.network(
            "https://java-mambo.oss-cn-beijing.aliyuncs.com/Matikanetannhauser.jpg",
          ),
        ),
      ),
    );
  }
}
