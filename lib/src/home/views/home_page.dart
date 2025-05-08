import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zegocloud_uikit/core/core.dart';
import 'package:zegocloud_uikit/src/auth/services/auth_service.dart';
import 'package:zegocloud_uikit/src/auth/views/login_view.dart';
import 'package:zegocloud_uikit/src/home/services/home_service.dart';
import 'package:zegocloud_uikit/src/home/views/components/contact_adding_form.dart';

class HomePage extends StatefulWidget {
  static String routeName = "home";

  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final contactListNotifier = ValueNotifier<List<Contact>>([]);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    contactListNotifier.dispose();
    super.dispose();
  }

  void loadData() {
    contactListNotifier.value = HomeService.getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Your Phone Number: ${Session.currentUser?.name}',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            Container(
              height: 33,
              width: 33,
              margin: const EdgeInsets.only(right: 16),
              child: FloatingActionButton.small(
                elevation: 2.5,
                onPressed: () {
                  AuthService.logout().then((value) {
                    AuthService.onUserLogout();
                    if (context.mounted) {
                      Navigator.popAndPushNamed(context, LoginPage.routeName);
                    }
                  });
                },
                backgroundColor: Colors.red[400],
                child: const Icon(
                  Icons.exit_to_app_sharp,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          height: 40,
          child: FloatingActionButton.extended(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
                builder: (_) {
                  return ContactAddingForm(
                    onSaved: () => loadData(),
                  );
                },
              );
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Add New Contact',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: contactListNotifier,
            builder: (_, contactList, __) {
              return ListView.separated(
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                separatorBuilder: (context, index) =>
                    const Divider(height: 0.3, color: Colors.black26),
                itemCount: contactList.length,
                itemBuilder: (context, index) {
                  final item = contactList[index];

                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.phoneNumber),
                    contentPadding: EdgeInsets.zero,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildCallButton(
                          isVideoCall: false,
                          name: item.name,
                          phoneNumber: item.phoneNumber,
                        ),
                        buildCallButton(
                          isVideoCall: true,
                          name: item.name,
                          phoneNumber: item.phoneNumber,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: VerticalDivider(),
                        ),
                        SizedBox(
                          height: 35,
                          width: 35,
                          child: CloseButton(
                            onPressed: () async {
                              await HomeService.removeContact(
                                  phoneNumber: item.phoneNumber);
                              loadData();
                            },
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildCallButton({
    required bool isVideoCall,
    required String name,
    required String phoneNumber,
    void Function(String code, String message, List<String>)? onCallFinished,
  }) {
    final String finalPhoneNumber = phoneNumber.replaceAll(RegExp(r' '), '');
    return ZegoSendCallInvitationButton(
      isVideoCall: isVideoCall,
      invitees: [
        ZegoUIKitUser(
          id: finalPhoneNumber,
          name: name,
        ),
      ],
      resourceID: 'zego_data',
      iconSize: const Size(40, 40),
      buttonSize: const Size(50, 50),
      onPressed: onSendCallInvitationFinished,
    );
  }

  void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        final userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var message = "User doesn't exist or is offline: $userIDs";
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      toastification.show(
        title: Text(message),
        autoCloseDuration: const Duration(milliseconds: 2300),
        alignment: Alignment.topCenter,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        showProgressBar: false,
      );
    } else if (code.isNotEmpty) {
      toastification.show(
        title: Text('code: $code, message:$message'),
        autoCloseDuration: const Duration(milliseconds: 2300),
        alignment: Alignment.topCenter,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        showProgressBar: false,
      );
    }
  }
}
