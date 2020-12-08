import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

import 'package:sherlock_voice_assistant/home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Home(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(355, 896), allowFontScaling: false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(80)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    Text("Sherlock",
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: ScreenUtil().setSp(36.0))),
                    Text("Voice Assistant",
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: ScreenUtil().setSp(36.0))),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    Text("Created by",
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: ScreenUtil().setSp(18))),
                    Text("Nicholas Anthony Suhartono",
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: ScreenUtil().setSp(18))),
                    Text("Mikhael Adriel Pratama Gana",
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: ScreenUtil().setSp(18))),
                    Text("Albertus Kevin",
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: ScreenUtil().setSp(18))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
