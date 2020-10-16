import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/all.dart' as kakao;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import '../models/auth.dart';

class AuthProvider with ChangeNotifier {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  Future<User> kakaoLogin() async {
      print('kakao login start');
      bool installed = await kakao.isKakaoTalkInstalled();
      print('installed? : $installed');
      final authCode = installed
          ? await kakao.AuthCodeClient.instance.requestWithTalk()
          : await kakao.AuthCodeClient.instance.request();
      final token = await kakao.AuthApi.instance.issueAccessToken(authCode);

      print('accessToken:${token.accessToken}');

      final firebaseToken = await getFirebaseToken(token.accessToken);
      final firebaseUser = await signInWithCustomToken(firebaseToken);

      return firebaseUser;

  }

  Future<User> facebookLogin() async {
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

      AuthCredential facebookCredential = FacebookAuthProvider.credential(accessToken.token);
      UserCredential userCredential = await _auth.signInWithCredential(facebookCredential);

      await _db.collection('users').doc(userCredential.user.uid).get().then((snapshot) async {
        if (snapshot.exists) {
          await signInUser(Auth.fromMap(snapshot.id, snapshot.data()), 'FACEBOOK');
        } else {
          await addUserToDB(userCredential, null, 'FACEBOOK');
        }
      });

      print('success');
      return userCredential.user;
    } on PlatformException catch (error) {
      //var message = 'An error occurred, please check your credentials!';
      print(error);
    } catch (error) {
      print(error);
    }
  }

  Future<User> appleLogin() async {
    print('appleLogin()');
    final nonce = _createNonce(32);
    try {
    final nativeAppleCredential = await _createAppleOAuthCredential(nonce);
    print('credential:$nativeAppleCredential');
    
    final appleCredential = OAuthCredential(
      providerId: "apple.com", // MUST be "apple.com"
      signInMethod: "oauth",   // MUST be "oauth"
      accessToken: nativeAppleCredential.identityToken, // propagate Apple ID token to BOTH accessToken and idToken parameters
      idToken: nativeAppleCredential.identityToken,
      rawNonce: nonce
    );

    UserCredential userCredential = await _auth.signInWithCredential(appleCredential);
    await _db.collection('users').doc(userCredential.user.uid).get().then((snapshot) => {

      if (snapshot.exists) {
        signInUser(Auth.fromMap(snapshot.id, snapshot.data()), 'APPLE', )
      } else {

        addUserToDB(userCredential, null, 'APPLE')
      }
    });
    print('success');
    return userCredential.user;
    
    } catch(error){
      print(error);
      return null;
    }
  }

  /*
   * apple social sign in
   */
  Future<AuthorizationCredentialAppleID> _createAppleOAuthCredential(nonce) async {
    final nativeAppleCredential = Platform.isIOS
      ? await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: sha256.convert(utf8.encode(nonce)).toString(),
        )
      : await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            redirectUri: Uri.parse(
                'https://honeytoon-server.firebaseapp.com/__/auth/handler'),
            clientId: 'com.jeonghyun.honeytoonapp',
          ),
          nonce: sha256.convert(utf8.encode(nonce)).toString(),
        );
    print(nativeAppleCredential);
    return nativeAppleCredential;
  }


  Future<User> emailLogin(email, password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<UserCredential> createUserWithEmailAndPassword(Auth auth) async {
    return await _auth.createUserWithEmailAndPassword(email: auth.email, password: auth.password);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> addUserToDB(UserCredential userCredential, Auth auth, String providerType) async {
    print('addUserToDB');
    await _db.collection('users').doc(userCredential.user.uid).set({
      'displayName': auth==null ? userCredential.user.displayName : auth.displayName,
      'email': auth==null ? userCredential.user.email : auth.email,
      'honey': 0,
      'earned_honey': 0,
      'provider': providerType,
      'thumbnail': auth==null ? userCredential.user.photoURL : auth.thumbnail,
      'update_time': Timestamp.now()
    });
  }

  // displayName, thumbnail 은 앱에서 수정할 수 있으므로 로그인 시 displayName을 update 하지 않는다
  Future<void> signInUser(Auth auth, String providerType,) async {
    await _db.collection('users').doc(auth.uid).update({
        'email': auth.email,
        'provider': providerType,
        //'thumbnail': user.thumbnail,
        'update_time': Timestamp.now(),
    });
  }

  Future<void> changeUserInfo(uid, changeInfo) async {
    await _db.collection('users').doc(uid).update(changeInfo);
  }

  Future<Auth> getUserFromDB() async {
    User firebaseUser = _auth.currentUser;
    if (firebaseUser == null || firebaseUser.uid == null) {
      return null;
    }
    final userData =
        await _db.collection('users').doc(firebaseUser.uid).get();
    
    // User user = User(
    //     uid: userData.documentID,
    //     displayName: userData.data['displayName'],
    //     email: userData.data['email'],
    //     provider: userData.data['provider'],
    //     thumbnail: userData.data['thumbnail'],
    //     honey: userData.data['honey'],
    //     works: userData.data['works']);

    return Auth.fromMap(userData.id, userData.data());
  }

  Future<Auth> getUserFromDBwithRank() async {
    Auth _auth = await getUserFromDB();
    final rank = await _db.collection('ranks').doc(_auth.uid).get();

    if(rank.exists){
      _auth.rank = rank.data()['rank'];
    }
    return _auth;
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

  Future<User> signInWithCustomToken(String token) async {
    UserCredential _userCredential = await _auth.signInWithCustomToken(token);
    print(_userCredential.user);
    return _userCredential.user;
  }

  static Future<User> getCurrentFirebaseUser() async {
    return _auth.currentUser;
  }

  static Future<String> getCurrentFirebaseUserUid() async {
    User user = _auth.currentUser;
    return user == null ? null : user.uid;
  }

  String _createNonce(int length){
    final random = Random();
    final charCodes = List<int>.generate(length, (_) {
      int codeUnit;

      switch(random.nextInt(3)){
        case 0:
          codeUnit = random.nextInt(10) + 48;
          break;
        case 1:
          codeUnit = random.nextInt(26) + 65;
          break;
        case 2:
          codeUnit = random.nextInt(26) + 97;
          break;
      }
      return codeUnit;
    });
    return String.fromCharCodes(charCodes);
  }
}