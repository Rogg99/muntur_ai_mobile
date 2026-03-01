import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:munturai/core/fonctions.dart';
import 'package:munturai/model/token.dart';
import 'package:munturai/model/user.dart';
import 'package:munturai/services/api/helper.dart';
import '../logging.dart';

class AuthApi {

  String Api_ =   ApiHelper().apiBaseUrl;
  late String authorization = "Bearer ";
  String GOOGLE_MAPS_APIKEY=  ApiHelper().GOOGLE_MAPS_APIKEY;

  //User Profile
  Future<http.Response> signup(User user) async {
    var url = Uri.parse('https://$Api_/auth/register/');
    var body = user.toJson2();
    log(body.toString());
    var headers = {"Content-Type": "application/json"};
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> updateProfile(User user) async {
    authorization = await getToken().then((value) =>
    'Bearer ${value!.access}'
    );
    var id = "";
    var url = Uri.parse('https://$Api_/api/profils/$id/');
    var body = user.toJson();
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.patch(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> setPassword(String newp) async {
    authorization = await getToken().then((value) =>
    'Bearer ${value!.access}'
    );
    var url=Uri.parse('https://$Api_/auth/reset_password/');
    var body = json.encode({
      'new_password':newp,
      'confirm_new_password':newp
    });
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> login(String email, String password) async {
    var url=Uri.parse('https://$Api_/auth/login/');
    log(url.toString());
    var body = json.encode({"username": email, "password": password});
    var headers = {
      "Content-Type": "application/json",
    };
    return http.post(url, headers: headers, body: body).then((http.Response response) {
      return response;
    });
  }

  Future<http.Response> getProfile({String token = ""}) async {
    if (token != "") {
      authorization = 'Bearer $token';
    } else {
      authorization = await getToken().then((value) =>
      'Bearer ${value!.access}'
      );
    }

    var url=Uri.parse('https://$Api_/profiles/my-profile/');
    log(url.toString());
    var headers = {"Content-Type": "application/json", "Authorization": authorization};
    return http.get(url,headers: headers,).then((http.Response response) {
      return response;
    });
  }

  Future<void> keepTokenAlive({bool force = false}) async {
    Token? token;
    int last_login;
    last_login = await getKey('last_login').then((value) => value!=''?int.parse(value):0);
    log('DEBUG : keeping Token Alive ...');
    try {
      token = await getToken().then((value) => value);
      if(token!= null && (last_login > DateTime.now().millisecondsSinceEpoch / 1000)) {
        login(token.email, token.password).then((resp) async => {
          if (resp.statusCode == 200 || resp.statusCode == 201)
            {
              token!.access = json.decode(resp.body)['data']['token'],
              last_login = (24 * 3600 + DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
              await saveKey('last_login', last_login.toString()),
              await saveKey('token', token.toJson().toString()),
              // await saveKey('user', User.fromJson(json.decode(resp.body)['data']['user']).toJson().toString()),
              // await syncProfile()
            }
        }).onError((error, stackTrace) =>
            ThrowError(error!, stackTrace));
      }
    } on Exception catch (error) {
      print(error.toString());
      log('DEBUG : No token stored in local database');
    }
  }

  Future<Timer> syncProfile({bool force = false}) async {
    log('DEBUG : syncing Profile ...');
    try {
      User user = await getUser().then((value) => value);
      await getProfile().then((resp1) async => {
        log(jsonDecode(resp1.body).toString()),
        if (resp1.statusCode == 200  || resp1.statusCode==201){
          saveKey('user',User.fromJson(jsonDecode(resp1.body)['data']).toJson().toString()),
          log('DEBUG : synced Profile !'),
        }
        else{
          log('DEBUG : syncing Profile failed')
        }
      }).onError((error, stackTrace) =>
          ThrowError(error!, stackTrace));
    } on Exception catch (error) {
      print(error.toString());
      log('DEBUG : syncing Profile failed');
    }
    return Timer(Duration(seconds: 0), () {});
  }

  Future<void> clearUserDatas() async {
    log('deleting user datas...');
    await saveKey('user', '');
    await saveKey('token','');
    await saveKey('last_login','0');
    log('deleting user datas finished with');
  }

  Future<void> deleteUser(User user) async {
    log('deleting user datas...');
    await saveKey('user', '');
    await saveKey('token','');
    await saveKey('last_login','0');
    log('deleting user datas finished with');
  }

  Future<User> getUser()async{
    if (kDebugMode) {
      print('DEBUG : USER ::: ${await getKey('user')}');
    }
    return User.fromJson(jsonDecode(await getKey('user')));
  }

  Future<Token?> getToken()async{
    try{
      return Token.fromJson2(jsonDecode(await getKey('token')));
    }catch (_){
      return null;
    }
    // print(getKey('token'));
  }

}
