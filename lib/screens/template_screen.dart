import 'dart:async';

import 'package:flutter/material.dart';
import './point/point_template_screen.dart';
import './my/my_screen.dart';
import './honeytoon_list_screen.dart';
import './settings/setting_screen.dart';

class TemplateScreen extends StatefulWidget {
  static final routeName = 'main';
  

  @override
  _TemplateScreenState createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  int _currentIndex = 0;
  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text('허니툰');
  StreamController<String> _controller = StreamController<String>.broadcast();

  Widget _buildWidget(index){
    switch (index) {
      case 0: return HoneyToonListScreen(stream: _controller.stream);
      case 1: return PointTemplateScreen();
      case 2: return MyScreen();
      case 3: return SettingScreen();
      default: return null;
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _searchKeyword(keyword){
    _controller.add(keyword);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    _controller.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: customSearchBar,
              actions: <Widget>[
                IconButton(icon: customIcon, onPressed: (){
                  setState(() {
                    if(this.customIcon.icon == Icons.search){
                      this.customIcon = Icon(Icons.cancel);
                      this.customSearchBar = TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value){
                          _searchKeyword(value);
                        },
                        decoration: InputDecoration(
                          hintText: "검색할 키워드를 입력해주세요",
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        )
                      );
                    } else {
                        this.customIcon = Icon(Icons.search);
                        this.customSearchBar = Text('허니툰');
                        _searchKeyword('');
                    }
                  });
                })
              ],
            )
          : null,
      body: _buildWidget(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                title: Text('Home')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.attach_money,
                ),
                title: Text('Point')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                title: Text('My')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                ),
                title: Text('Setting')),
          ],
          currentIndex: _currentIndex,
          onTap: _onTap,
          selectedItemColor: Theme.of(context).primaryColor),
    );
  }
}
