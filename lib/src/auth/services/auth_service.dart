// Package imports:
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zegocloud_uikit/components/components.dart';
import 'package:zegocloud_uikit/core/core.dart';

class AuthService {
  /// Local virtual get user login session
  static Future<void> getUserLoginSession() async {
    final cacheUserID =
        LocalStorage.instance.getString(Variables.cacheUserIDKey) ?? '';
    if (cacheUserID.isNotEmpty) {
      final user = UserInfo.fromJson(json.decode(cacheUserID));
      Session.currentUser = user;
    }
  }

  /// Local virtual login
  static Future<void> login({
    required String phoneNumber,
  }) async {
    final String userID = phoneNumber.replaceAll(RegExp(r' '), '');
    final user = UserInfo(
      id: userID,
      name: phoneNumber,
    );
    Session.currentUser = user;
    await LocalStorage.instance
        .setString(Variables.cacheUserIDKey, json.encode(user.toJson()));
  }

  /// On user login
  static Future<void> onUserLogin() async {
    final currentUser = Session.currentUser!;

    /// 7/8: initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Variables.appID,
      appSign: Variables.appSign,
      userID: currentUser.id,
      userName: currentUser.id,
      innerText: ZegoCallInvitationInnerText(
        incomingVideoCallDialogTitle: currentUser.name,
        incomingVideoCallPageTitle: currentUser.name,
      ),
      plugins: [ZegoUIKitSignalingPlugin()],
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.invitees.length > 1)
            ? ZegoCallInvitationType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            : ZegoCallInvitationType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        /// Custom avatar
        config.avatarBuilder = (_, Size size, ZegoUIKitUser? user,
                Map<String, dynamic> extraInfo) =>
            AvatarImage(
              size: size,
              user: user,
              extraInfo: extraInfo,
            );

        /// Support minimizing, show minimizing button
        config.topMenuBar.isVisible = true;
        config.topMenuBar.buttons
            .insert(0, ZegoCallMenuBarButtonName.minimizingButton);
        config.topMenuBar.buttons
            .insert(1, ZegoCallMenuBarButtonName.soundEffectButton);

        return config;
      },
    );
  }

  /// Local virtual logout
  static Future<void> logout() async {
    await LocalStorage.instance.remove(Variables.cacheUserIDKey);
  }

  /// On user logout
  static Future<void> onUserLogout() async {
    /// 8/8: de-initialization ZegoUIKitPrebuiltCallInvitationService when account is logged out
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
