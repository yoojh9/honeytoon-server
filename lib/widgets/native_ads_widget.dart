import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

class NativeAdsWidget extends StatefulWidget {
  @override
  _NativeAdsWidgetState createState() => _NativeAdsWidgetState();
}

class _NativeAdsWidgetState extends State<NativeAdsWidget> {
  static final _adUnitId = NativeAd.testAdUnitId;
  final _nativeAdController = NativeAdmobController();
  double _height = 0;

  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _nativeAdController.dispose();
    super.dispose();
  }

  void _onStateChanged(AdLoadState state){
    switch (state) {
      case AdLoadState.loading:
        setState(() {
          _height = 0;
        });
        break;
      
      case AdLoadState.loadCompleted:
        setState(() {
          _height = 330;
        });
        break;
      
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: NativeAdmob(
        adUnitID: _adUnitId,
        controller: _nativeAdController,
        loading: Center(child: CircularProgressIndicator()),
        type: NativeAdmobType.full,
      ),
    );
  }
}