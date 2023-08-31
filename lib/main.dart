import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/product.dart';
import 'package:shopping/productDetailPage.dart';

void main() {
  runApp(const MyApp());
}

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
      initialRoute: '/',
      routes: {'/': (context) => MainPage(),
      '/ProductDetailPage': (context) => ProductDetailPage()},
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
      body: ShoppingList(),
    );
  }
}

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<Product> products = [];

  @override
  Widget build(BuildContext context) {
    // 아이템 목록 생성
    List<String> items = List.generate(20, (index) => '아이템 $index');

    return GridView.builder(
      // 열의 개수를 지정합니다.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      // 아이템 생성
      itemBuilder: (context, index) {
        final product = products[index];
        double screenWidth = MediaQuery.of(context).size.width;
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/ProductDetailPage');
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
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              text: '${product.price}', // Larger amount
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${product.discountPercentage} OFF',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
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
      itemCount: products.length,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://dummyjson.com/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> productsData = data['products'];

      final List<Product> loadedProducts = productsData.map((productData) {
        return Product.fromJson(productData);
      }).toList();

      setState(() {
        products = loadedProducts;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}
