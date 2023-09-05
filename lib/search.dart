import 'package:flutter/material.dart';
import 'package:shopping/shoppingListPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.keyword});

  final keyword;

  @override
  State<SearchPage> createState() => _SearchPageState(keyword);
}

class _SearchPageState extends State<SearchPage> {
  _SearchPageState(this.keyword);

  final keyword;

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.keyword;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
          ]),
      body: ShoppingList(
        category: 'all',
        keyword: _textEditingController.text,
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
