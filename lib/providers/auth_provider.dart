import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/common.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  static final _auth = FirebaseAuth.instance;
  static final _db = Firestore.instance;

  Future<FirebaseUser> kakaoLogin() async {
      print('kakao login start');
      final installed = await isKakaoTalkInstalled();
      final authCode = installed
          ? await AuthCodeClient.instance.requestWithTalk()
          : await AuthCodeClient.instance.request();
      final token = await AuthApi.instance.issueAccessToken(authCode);

      print('accessToken:${token.accessToken}');

      final firebaseToken = await getFirebaseToken(token.accessToken);
      final firebaseUser = await signInWithCustomToken(firebaseToken);

      return firebaseUser;
    // try {
    //   print('kakao login start');
    //   final installed = await isKakaoTalkInstalled();
    //   final authCode = installed
    //       ? await AuthCodeClient.instance.requestWithTalk()
    //       : await AuthCodeClient.instance.request();
    //   final token = await AuthApi.instance.issueAccessToken(authCode);

    //   print('accessToken:${token.accessToken}');

    //   final firebaseToken = await getFirebaseToken(token.accessToken);
    //   final firebaseUser = await signInWithCustomToken(firebaseToken);

    //   return firebaseUser;
    // } on KakaoAuthException catch (error) {
    //   print(error);
    // } on KakaoClientException catch (error) {
    //   print(error);
    // } catch (error) {
    //   print(error);
    // }
  }

  Future<FirebaseUser> facebookLogin() async {
    try {
      final FacebookLogin facebookSignIn = FacebookLogin();
      final FacebookLoginResult result =
          await facebookSignIn.logIn(['email', 'public_profile']);
      FacebookAccessToken accessToken;

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          accessToken = result.accessToken;
          break;
        case FacebookLoginStatus.cancelledByUser:
          break;
        case FacebookLoginStatus.error:
          break;
      }

      AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: accessToken.token);
      AuthResult authResult = await _auth.signInWithCredential(credential);

      print('displayName: ${authResult.user.displayName}');
      print(authResult.user.displayName);
      print('user : ${authResult.user}');

      await addUserToDB(authResult, 'FACEBOOK', null);

      print('success');
      return authResult.user;
    } on PlatformException catch (error) {
      var message = 'An error occurred, please check your credentials!';
      print(error);
    } catch (error) {
      print(error);
    }
  }

  Future<AuthResult> createUserWithEmailAndPassword(User user) async {
    AuthResult authResult = await _auth.createUserWithEmailAndPassword(email: user.email, password: user.password);
    return authResult;
  }

  Future<void> addUserToDB(AuthResult authResult, String providerType, User user) async {
    await _db.collection('users').document(authResult.user.uid).setData({
        'displayName': user == null ? authResult.user.displayName : user.displayName,
        'email': user == null ? authResult.user.email : user.email,
        'provider': providerType,
        'thumbnail': user == null ? authResult.user.photoUrl : user.thumbnail,
        'update_time': Timestamp.now(),
    });
  }

  Future<User> getUserFromDB() async {
    final firebaseUser = await _auth.currentUser();
    if (firebaseUser == null || firebaseUser.uid == null) {
      return null;
    }
    final userData =
        await _db.collection('users').document(firebaseUser.uid).get();
    User user = User(
        uid: userData.documentID,
        displayName: userData.data['displayName'],
        email: userData.data['email'],
        provider: userData.data['provider'],
        thumbnail: userData.data['thumbnail'],
        honey: userData.data['honey'],
        rank: userData.data['rank'],
        works: userData.data['works']);

    return user;
  }

  Future<String> getFirebaseToken(String kakaoToken) async {
    print('kakaoToken: $kakaoToken');
    const url =
        "https://asia-northeast1-honeytoon-server.cloudfunctions.net/app/custom-token";
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"token": kakaoToken}));
    final data = json.decode(response.body) as Map<String, dynamic>;
    print('data=$data');

    return data['firebase_token'];
  }

  Future<FirebaseUser> signInWithCustomToken(String token) async {
    final authResult = await _auth.signInWithCustomToken(token: token);
    print(authResult.user);
    return authResult.user;
  }

  static Future<FirebaseUser> getCurrentFirebaseUser() async {
    FirebaseUser currentUser = await _auth.currentUser();
    return currentUser;
  }

  static Future<String> getCurrentFirebaseUserUid() async {
    FirebaseUser currentUser = await _auth.currentUser();
    return currentUser == null ? null : currentUser.uid;
  }
}
