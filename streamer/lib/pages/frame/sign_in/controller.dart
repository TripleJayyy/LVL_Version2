import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:streamer/common/entities/entities.dart';
import 'package:streamer/common/routes/routes.dart';
import 'package:streamer/common/apis/user.dart';
import 'package:streamer/common/utils/http.dart';
import 'package:streamer/common/widgets/toast.dart';
import 'package:streamer/pages/frame/sign_in/state.dart';
import 'package:streamer/common/store/user.dart';

import '../../../common/apis/user.dart';

class SignInController extends GetxController {
  SignInController();
  final state = SignInState();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['openid']);

  Future<void> handleSignIn(String type) async {
    // email(1),google(2), facebook(3), apple(4), phone(5)
    try {
      if (type == "phone number") {
        if (kDebugMode) {
          print("... phone log in ...");
        }
      } else if (type == "google") {
        var user = await _googleSignIn.signIn();
        if (user != null) {
          String? displayName = user.displayName;
          String email = user.email;
          String id = user.id;
          String photoUrl = user.photoUrl ?? "assets/icons/google.png";
          LoginRequestEntity loginPanelListRequestEntity = LoginRequestEntity();
          loginPanelListRequestEntity.avatar = photoUrl;
          loginPanelListRequestEntity.name = displayName;
          loginPanelListRequestEntity.email = email;
          loginPanelListRequestEntity.open_id = id;
          loginPanelListRequestEntity.type = 2;
          print(jsonEncode(loginPanelListRequestEntity));
          asyncPostAllData(loginPanelListRequestEntity);
        }
      } else {
        if (kDebugMode) {
          print("... unsure of log in type ...");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('error with login $e');
      }
    }
  }

  asyncPostAllData(LoginRequestEntity loginRequestEntity) async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);

    var result = await UserAPI.Login(params: loginRequestEntity);
    if (result.code == 0) {
      await UserStore.to.saveProfile(result.data!);
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      toastInfo(msg: "Internet error");
    }

    //print("...let's go to msg page...");
    //var response = await HttpUtil().get('/api/index');
    //print(response);
    //UserStore.to.setIsLogin = true;
    Get.offAllNamed(AppRoutes.Message);
  }
}
