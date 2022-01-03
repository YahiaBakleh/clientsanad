import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? email;
  String? name;
  String? phone;
  String? mobile;

  Users({
    this.id,
    this.email,
    this.name,
    this.phone,
    this.mobile
  });

  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    phone = dataSnapshot.value["phone"];
    mobile = dataSnapshot.value["mobile"];
  }
}
