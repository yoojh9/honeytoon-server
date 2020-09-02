import 'package:flutter/material.dart';

class HoneytoonListSort extends StatefulWidget {
  final Function toggleSort;
  const HoneytoonListSort({
    Key key,
    this.toggleSort
  }) : super(key: key);

  @override
  _HoneytoonListSortState createState() => _HoneytoonListSortState();
}

class _HoneytoonListSortState extends State<HoneytoonListSort> {
  var sortType = 1;

  void _tapToggleText(type){
    widget.toggleSort(type);
    setState(() {
      sortType = type;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        GestureDetector(
          child: Text('신규순', 
            style: TextStyle(
              fontWeight: sortType == 1? FontWeight.bold : FontWeight.normal,
              color: sortType == 1? Theme.of(context).primaryColor: Colors.black
            )
          ),
          onTap: (){
            _tapToggleText(1);
          },
        ),
        SizedBox(width: 10,),
        GestureDetector(
          child: Text('인기순',
            style: TextStyle(
              fontWeight: sortType == 2? FontWeight.bold : FontWeight.normal,
              color: sortType == 2? Theme.of(context).primaryColor: Colors.black
            )  
          ),
          onTap: (){
            _tapToggleText(2);
          },
        ),
    ],);
  }
}

