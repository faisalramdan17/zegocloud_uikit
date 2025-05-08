// Package imports:
import 'dart:convert';

import 'package:zegocloud_uikit/core/core.dart';

class HomeService {
  static List<Contact> getContacts() {
    final listString =
        LocalStorage.instance.getStringList(Variables.cacheContactsKey) ?? [];
    return List<Contact>.from(
        listString.map((it) => Contact.fromJson(json.decode(it))));
  }

  static Future<void> addContact({
    required String name,
    required String phoneNumber,
  }) async {
    final contactList = getContacts();
    contactList.add(Contact(
      name: name,
      phoneNumber: phoneNumber,
    ));
    final listString =
        contactList.map((it) => json.encode(it.toJson())).toList();
    await LocalStorage.instance
        .setStringList(Variables.cacheContactsKey, listString);
  }

  static Future<void> removeContact({
    required String phoneNumber,
  }) async {
    final contactList = getContacts();
    contactList.removeWhere((it) => it.phoneNumber == phoneNumber);
    final listString =
        contactList.map((it) => json.encode(it.toJson())).toList();
    await LocalStorage.instance
        .setStringList(Variables.cacheContactsKey, listString);
  }
}
