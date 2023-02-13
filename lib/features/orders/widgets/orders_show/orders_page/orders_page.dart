import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../orders_content.dart';

class OrdersPage extends StatefulWidget {

  static const routeName = 'OrdersPage';

  const OrdersPage({
    super.key,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  ShoppableStore get store => storeProvider.store!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Content of the page
      body: OrdersContent(
        store: store,
        showingFullPage: true
      ),
    );
  }
}