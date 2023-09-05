import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shopping/shoppingListPage.dart';
import 'package:shopping/search.dart';

class ShoppingCategoryPage extends StatefulWidget {
  const ShoppingCategoryPage({super.key});

  @override
  State<ShoppingCategoryPage> createState() => _ShoppingCategoryPageState();
}

class _ShoppingCategoryPageState extends State<ShoppingCategoryPage>
    with SingleTickerProviderStateMixin {
  final _baseUrl = 'https://dummyjson.com/';

  bool _isFirstLoadRunning = false;

  late List<String> _categoryList;

  late TabController _tabController;

  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _firstLoad();
  }

  List<String> parseJsonArray(String jsonString) {
    final parsedList = json.decode(jsonString);
    if (parsedList is List<dynamic>) {
      return parsedList.map((item) => item.toString()).toList();
    }
    return [];
  }

  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true; // 최초 로딩 표시
    });
    try {
      final response =
          await http.get(Uri.parse('${_baseUrl}products/categories'));
      if (response.statusCode == 200) {
        _categoryList = parseJsonArray(response.body);
        _categoryList.insert(0, 'all');
        _tabController = TabController(
          length: _categoryList.length,
          vsync: this,
        );
        _tabController.addListener(_handleTabSelection);
      }
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
    }

    setState(() {
      _isFirstLoadRunning = false; // 최초 로딩 숨기고 리스트 표시
    });
  }

  void _handleTabSelection() {
    // 현재 선택된 탭 인덱스
    _tabIndex = _tabController.index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController();

    return _isFirstLoadRunning
        ? Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : DefaultTabController(
            length: _categoryList.length,
            child: Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: '검색어를 입력하세요',
                    border: InputBorder.none,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_textEditingController.text.isEmpty) {
                        _showDialog(); // 텍스트 필드가 비어 있을 때 다이얼로그 표시
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchPage(keyword: _textEditingController.text),
                          ),
                        );
                      }
                    },
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _categoryList.map((tab) => Tab(text: tab)).toList(),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: _categoryList.map((tab) {
                  return ShoppingList(
                    category: tab,
                    keyword: null,
                  );
                }).toList(),
              ),
            ),
          );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고'),
          content: Text('검색어를 입력하세요.'),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
