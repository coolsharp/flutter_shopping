import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

List? categeryList = null;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping'),
      ),
      body: ViewPagerExample(),
    );
  }
}

class TwoColumnGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 아이템 목록 생성
    List<String> items = List.generate(20, (index) => '아이템 $index');

    return GridView.builder(
      // 열의 개수를 지정합니다.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      // 아이템 생성
      itemBuilder: (context, index) {
        return Card(
          child: Center(
            child: Text(items[index]),
          ),
        );
      },
      // 아이템 개수
      itemCount: items.length,
    );
  }
}

class ViewPagerExample extends StatefulWidget {
  const ViewPagerExample({super.key});

  @override
  State<ViewPagerExample> createState() => _ViewPagerExampleState();
}

class _ViewPagerExampleState extends State<ViewPagerExample> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categeryList!.length, // 탭의 수
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TabBar & PageView 예제'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              for (int i = 0; i < categeryList!.length; i++) Tab(text: '${categeryList![i]}'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            for (int i = 0; i < categeryList!.length; i++)
              Center(
                child: TwoColumnGrid(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getJsonData();
  }

  Future<String> getJsonData() async {
    var url = 'https://dummyjson.com/products/categories';
    var response = await http.get(Uri.parse(url));
    var dataConvertedToJson = jsonDecode(response.body);
    setState(() {
      categeryList = dataConvertedToJson;
      _tabController = TabController(vsync: this, length: categeryList!.length);
    });
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        print('Change index ${categeryList![_tabController!.index]}');
      } else if(_tabController!.index != _tabController!.previousIndex) {
        print('Different index ${categeryList![_tabController!.index]}');
      }
    });
    for (int i = 0; i < categeryList!.length; i++) {
      print(categeryList![i]);
    }
    return 'Successfull';
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }
}
