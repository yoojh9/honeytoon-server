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

  }

  Future<FirebaseUser> facebookLogin() async {
    try {
      final FacebookLogin facebookSignIn = FacebookLogin();
      final FacebookLoginResult result = await facebookSignIn.logIn(['email', 'public_profile']);
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

      await _db.collection('users').document(authResult.user.uid).get().then((snapshot) => {
        if (snapshot.exists) {
          updateUserToDB(User.fromMap(snapshot.documentID, snapshot.data), 'FACEBOOK', )
        } else {
          addUserToDB(authResult, null, 'FACEBOOK')
        }
      });

      print('success');
      return authResult.user;
    } on PlatformException catch (error) {
      var message = 'An error occurred, please check your credentials!';
      print(error);
    } catch (error) {
      print(error);
    }
  }

  Future<FirebaseUser> emailLogin(email, password) async {
    AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return authResult.user;
  }

  Future<AuthResult> createUserWithEmailAndPassword(User user) async {
    AuthResult authResult = await _auth.createUserWithEmailAndPassword(email: user.email, password: user.password);
    return authResult;
  }

  Future<void> addUserToDB(AuthResult authResult, User user, String providerType) async {
    await _db.collection('users').document(authResult.user.uid).setData({
      'displayName': user==null ? authResult.user.displayName : user.displayName,
      'email': user==null ? authResult.user.email : user.email,
      'honey': 0,
      'earned_honey': 0,
      'provider': providerType,
      'thumbnail': user==null ? authResult.user.photoUrl : user.thumbnail,
      'update_time': Timestamp.now()
    });
  }

  // displayName은 앱에서 수정할 수 있으므로 로그인 시 displayName을 update 하지 않는다
  Future<void> updateUserToDB(User user, String providerType,) async {
    await _db.collection('users').document(user.uid).updateData({
        'email': user.email,
        'provider': providerType,
        'thumbnail': user.thumbnail,
        'update_time': Timestamp.now(),
    });
  }

  Future<void> changeUserInfo(uid, changeInfo) async {
    await _db.collection('users').document(uid).updateData(changeInfo);
  }

  Future<User> getUserFromDB() async {
    final firebaseUser = await _auth.currentUser();
    if (firebaseUser == null || firebaseUser.uid == null) {
      return null;
    }
    final userData =
        await _db.collection('users').document(firebaseUser.uid).get();
    
    // User user = User(
    //     uid: userData.documentID,
    //     displayName: userData.data['displayName'],
    //     email: userData.data['email'],
    //     provider: userData.data['provider'],
    //     thumbnail: userData.data['thumbnail'],
    //     honey: userData.data['honey'],
    //     works: userData.data['works']);

    return User.fromMap(userData.documentID, userData.data);
  }

  Future<User> getUserFromDBwithRank() async {
    User user = await getUserFromDB();
    final rank = await _db.collection('ranks').document(user.uid).get();

    if(rank.exists){
      user.rank = rank.data['rank'];
    }
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
