import 'package:flutter/material.dart';
import './shopping_list_screen.dart';
import './point_earn_screen.dart';
import './point_screen.dart';

class PointTemplateScreen extends StatefulWidget {
  @override
  _PointTemplateScreenState createState() => _PointTemplateScreenState();
}

class _PointTemplateScreenState extends State<PointTemplateScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
                color: Colors.transparent,
                child: SafeArea(
                  child: TabBar(
                    controller: _controller,
                    tabs: <Widget>[Tab(text: '포인트'), Tab(text: '적립하기'), Tab(text: '쇼핑하기')],
                  ),
                )),
          ),
          body: TabBarView(
              controller: _controller,
              children: <Widget>[PointScreen(), Center(child: PointEarnScreen()), ShoppingListScreen()])),
    );
  }
}
