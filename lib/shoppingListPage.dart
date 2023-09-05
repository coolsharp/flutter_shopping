import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shopping/product.dart';
import 'package:shopping/productDetailPage.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key, required  this.category, required  this.keyword});

  final category;

  final keyword;

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  _ShoppingListState();

  final _baseUrl = 'https://dummyjson.com/';

  // 페이징 시 건너띌 인덱스
  int _skip = 0;

  // 페이지당 로딩되는 글 수
  final int _limit = 20;

  // 다음 페이지 여부
  bool _hasNextPage = true;

  // 최초 로딩 시 인디케이터 표시
  bool _isFirstLoadRunning = false;

  // 추가 로딩 시 인디케이터 표시
  bool _isLoadMoreRunning = false;

  late ScrollController _controller;

  List<Product> _products = [];

  @override
  Widget build(BuildContext context) {
    // 아이템 목록 생성
    List<String> items = List.generate(20, (index) => '아이템 $index');

    return _isFirstLoadRunning // 최초 로딩일 경우 로딩 프로그래스 표시
        ? const Center(
            child: const CircularProgressIndicator(),
          )
        : Column(
            children: [
              Expanded(
                child: GridView.builder(
                  // 최초 로딩이 아닐 경우 리스트 표시
                  // 열의 개수를 지정합니다.
                  controller: _controller,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  // 아이템 생성
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    double screenWidth = MediaQuery.of(context).size.width;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product.id),
                            ));
                      },
                      child: Card(
                        semanticContainer: true,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7.0), // 상단 왼쪽 모서리
                                topRight: Radius.circular(7.0), // 상단 오른쪽 모서리
                              ),
                              child: Image.network(
                                product.images[0],
                                height: screenWidth / 2 / 1.05,
                                width: screenWidth / 2,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, left: 8, right: 8, bottom: 0),
                              child: Text(
                                product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 8, right: 8, bottom: 1),
                              child: Text(
                                product.brand,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 2, left: 8, right: 8, bottom: 1),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: '\$', // Small dollar sign
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '${product.price}', // Larger amount
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${product.discountPercentage} OFF',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  // 아이템 개수
                  itemCount: _products.length,
                ),
              ),
              // when the _loadMore function is running
              if (_isLoadMoreRunning == true)
                const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
  }

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  // 앱이 실행되면 호출되는 함수
  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true; // 최초 로딩 표시
    });
    try {
      String url =
          '${_baseUrl}products/category/${widget.category}?limit=$_limit&skip=$_skip';
      if ('all' == widget.category) {
        url = '${_baseUrl}products?limit=$_limit&skip=$_skip';
      }
      if (null != widget.keyword && widget.keyword.isNotEmpty) {
        url = '${_baseUrl}products/search?q=${widget.keyword}&limit=$_limit&skip=$_skip';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsData = data['products'];

        final List<Product> loadedProducts = productsData.map((productData) {
          return Product.fromJson(productData);
        }).toList();
        setState(() {
          _products = loadedProducts;
        });
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

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _skip += 20; // Increase _page by 1
      try {
        String url =
            '${_baseUrl}products/category/${widget.category}?limit=$_limit&skip=$_skip';
        if ('all' == widget.category) {
          url = '${_baseUrl}products?limit=$_limit&skip=$_skip';
        }
        if (null != widget.keyword && widget.keyword.isNotEmpty) {
          url = '${_baseUrl}products/search?q=${widget.keyword}&limit=$_limit&skip=$_skip';
        }

        final response = await http
            .get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> productsData = data['products'];

          final List<Product> loadedProducts = productsData.map((productData) {
            return Product.fromJson(productData);
          }).toList();
          if (loadedProducts.isNotEmpty) {
            setState(() {
              _products.addAll(loadedProducts);
            });
          } else {
            _hasNextPage = false;
          }
        }
      } catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }
}
