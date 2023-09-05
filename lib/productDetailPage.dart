import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/product.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage(this.id, {super.key});

  final id;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState(id);
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  _ProductDetailPageState(this.id);

  final _baseUrl = 'https://dummyjson.com/';

  bool _isFirstLoading = false;

  Product? _product;

  late int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: _isFirstLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _product!.images.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  // 첫 번째 아이템은 헤더
                  return HeaderCell(product: _product);
                } else {
                  // 나머지 아이템은 데이터 항목
                  return ImageCell(thumbnail: _product!.images[index - 1]);
                }
              },
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _firstLoad();
  }

  void _firstLoad() async {
    setState(() {
      _isFirstLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${_baseUrl}products/$id'));
      if (response.statusCode == 200) {
        // JSON 문자열을 Map으로 파싱
        Map<String, dynamic> jsonMap = json.decode(response.body);

        // Product 객체로 변환
        _product = Product.fromJson(jsonMap);
        print(_product!.discountPercentage);
      }
    } catch (err) {}

    setState(() {
      _isFirstLoading = false;
    });
  }
}

class HeaderCell extends StatefulWidget {
  const HeaderCell({super.key, this.product});

  final Product? product;

  @override
  State<HeaderCell> createState() => _HeaderCellState(product);
}

class _HeaderCellState extends State<HeaderCell> {
  late final Product? product;

  _HeaderCellState(this.product);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.lightBlue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                product!.thumbnail,
                width: screenWidth,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Container(
                  width: 50,
                  height: 50,
                  color: const Color.fromARGB(200, 255, 0, 255),
                  child: Center(
                    child: Text(product!.discountPercentage.toString()),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 0),
            child: Text(
              product!.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 1),
            child: Text(
              product!.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 2, left: 8, right: 8, bottom: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                        text: '${product?.price}', // Larger amount
                      ),
                    ],
                  ),
                ),
                Text(
                  '${product?.discountPercentage} OFF',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCell extends StatefulWidget {
  const ImageCell({super.key, this.thumbnail});

  final String? thumbnail;

  @override
  State<ImageCell> createState() => _ImageCellState(thumbnail);
}

class _ImageCellState extends State<ImageCell> {
  _ImageCellState(this.thumbnail);

  String? thumbnail;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Image.network(
      thumbnail!,
      width: screenWidth,
      fit: BoxFit.cover,
    );
  }
}
