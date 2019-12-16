import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'json_user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home:LoginWithRestfulApi(),
    );
  }
}
class LoginWithRestfulApi extends StatefulWidget {
  @override
  _LoginWithRestfulApiState createState() => _LoginWithRestfulApiState();
}

class _LoginWithRestfulApiState extends State<LoginWithRestfulApi> {
  static var uri = "htp://test.natterbase.com:4999";

  static BaseOptions options = BaseOptions(
      baseUrl: uri,
      responseType: ResponseType.plain,
      connectTimeout: 30000,
      receiveTimeout: 30000,
      validateStatus: (code) {
        if (code >= 200) {
          return true;
        }
      });
  static Dio dio = Dio(options);

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<String> getData() async {
    List data;
    String url = 'http://testing.myvehicle.biz/api/login';
    final body = { "email":"123456780","password":"123456"};
    final response = await http.post(url, headers: {"Accept": "application/json"},body:body);
    if(response.statusCode==200){
      debugPrint(response.body);
    }else{
      debugPrint('error');
    }
  }

  Future<dynamic> _loginUser(String email, String password) async {
//   return password;
    String url = 'http://testing.myvehicle.biz/api/login';
    final body = { "email":email,"password":password};
    final response = await http.post(url, headers: {"Accept": "application/json"},body:body);
    if(response.statusCode==200){
        return response.body;
    }
    else{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final key = 'myvehicle_login_details';
      final value1 = prefs.getString(key) ?? 0;
      if(value1!=0){
        var data = json.decode(value1);
        var data1 = 'Bearer '+data["data"]["token"];
        String url = 'http://testing.myvehicle.biz/api/customers';
        final response = await http.get(url, headers: {"Accept": "application/json",'Authorization':'${data1}'});
        debugPrint('${response.body}');
      }
      return 0;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Login using RESTFUL api")),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
            ),
            RaisedButton(
              child: Text("Login"),
              color: Colors.red,
              onPressed :() async
              {
                var res = await _loginUser(
                    _emailController.text, _passwordController.text);

                if (res != 0) {


                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    final key = 'myvehicle_login_details';
                    final value = res;
                    prefs.setString(key, value);


                  Navigator.of(context).push(MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return LoginScreen(
                        );
                      }));

                  final value1 = prefs.getString(key) ?? 0;
                  debugPrint('read:${value1}');
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Invalid Username / Password"),
                  ));
                  debugPrint('xcv');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Screen")),
      body: Center(
        child: Text("next page"),
      ),
    );
  }
}