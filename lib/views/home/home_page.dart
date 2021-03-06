import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:eshemachoch_mobile_application/constants/api.dart';
import 'package:eshemachoch_mobile_application/viewmodels/consumer/consumer_model.dart';
import 'package:eshemachoch_mobile_application/viewmodels/product/product_model.dart';
import 'package:flutter/material.dart';
import 'package:eshemachoch_mobile_application/views/home/component/product_tile.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final consumer = context.read<ConsumerModel>().consumer!;

    _buildHeader(String text) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
          child: Row(children: [
            Container(
              height: 10.0,
              width: 24.0,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(5)),
            ),
            SizedBox(width: 8),
            Text(text),
          ]),
        ),
      );
    }

    return Consumer<ProductModel>(
      builder: (context, model, child) {
        if (model.hasError) return Text('Failed to load.');
        if (model.isLoading) return CircularProgressIndicator();
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: () async {
              model.getProducts();
            },
            child: CustomScrollView(
              slivers: [
                _buildHeader('NEWLY ARRIVED'),
                SliverToBoxAdapter(
                  child: CarouselSlider(
                    items: model.products!
                        .map((product) => Image.network(
                                '$BASEURL/products/images/${product.image}',
                                fit: BoxFit.contain,
                                headers: {
                                  HttpHeaders.authorizationHeader:
                                      consumer.token!,
                                }))
                        .toList(),
                    options: CarouselOptions(height: 180.0),
                  ),
                ),
                _buildHeader('ALL PRODUCTS'),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = model.products![index];
                    return MyProductTile(
                      product: product,
                    );
                  }, childCount: model.products!.length),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
