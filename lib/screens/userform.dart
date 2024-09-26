import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:startcode/models/config.dart';
import 'package:startcode/models/users.dart';
import 'package:http/http.dart' as http;

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formkey = GlobalKey<FormState>();
  late Users user;

  Future<void> addNewUser(user) async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.post(url,
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    var rs = usersFromJson("[${resp.body}]");

    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
    return;
  }

  Future<void> updateData(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.put(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    var rs = usersFromJson("[${resp.body}]");
    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
  }

  Widget fnameInputField() {
    return TextFormField(
      initialValue: user.fullname ?? "", // เพิ่มเพื่อเลี่ยง null ที่อาจเกิดขึ้น
      decoration: InputDecoration(
          labelText: "Fullname:", icon: Icon(Icons.person)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.fullname = newValue,
    );
  }

    Widget emailInputField() {
    return TextFormField(
      initialValue: user.email ?? "", // เลี่ยง null ที่อาจเกิดขึ้น
      decoration: InputDecoration(labelText: "Email:", icon: Icon(Icons.email)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        if (!EmailValidator.validate(value)) {
          return "Invalid email format";
        }
        return null;
      },
      onSaved: (newValue) => user.email = newValue,
    );
  }

    Widget passwordInputField() {
    return TextFormField(
      initialValue: user.password ?? "", // เลี่ยง null ที่อาจเกิดขึ้น
      obscureText: true,
      decoration:
          InputDecoration(labelText: "Password:", icon: Icon(Icons.lock)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.password = newValue,
    );
  }

    Widget submitButton() {
    return ElevatedButton(
        onPressed: () {
          if (_formkey.currentState!.validate()) {
            _formkey.currentState!.save();
            print(user.toJson().toString());
            // addNewUser(user);
            if (user.id == null) {
              addNewUser(user);
            } else {
              updateData(user);
            }
          }
        },
        child: Text("Save"));
  }

    Widget genderFormInput() {
    var initGen = "None";
    try {
      if (user.gender!.isEmpty) {
        initGen = user.gender!;
      }
    } catch (e) {
      initGen = "None";
    }

    return DropdownButtonFormField(
        decoration:
            InputDecoration(labelText: "Gender:", icon: Icon(Icons.man)),
        value: initGen,
        // value: 'None',
        items: Configure.gender.map((String val) {
          return DropdownMenuItem(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: (value) {
          user.gender = value;
        },
        onSaved: (newValue) => user.gender);
  }

  @override
  Widget build(BuildContext context) {
    try {
      user = ModalRoute.of(context)!.settings.arguments as Users;
      print(user.fullname);
    } catch (e) {
      user = Users();
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("User Form"),
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fnameInputField(),
                emailInputField(),
                passwordInputField(),
                genderFormInput(),
                SizedBox(
                  height: 10,
                ),
                submitButton(),
              ],
            ),
          ),
        ));
  }
}