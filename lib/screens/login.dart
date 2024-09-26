import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:startcode/models/config.dart';
import 'package:startcode/models/users.dart';
import 'package:startcode/screens/home.dart';


class Login extends StatefulWidget {
  static const routeName = "/login";

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  Users user = Users();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textHeader(),
              emailInputField(),
              passwordInputField(),
              SizedBox(height: 10.0),
              Row(
                children: [
                  submitButton(),
                  SizedBox(width: 10.0),
                  backButton(),
                  SizedBox(width: 10.0),
                  registerLink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget emailInputField() {
    return TextFormField(
      initialValue: "a@test.com",
      decoration: InputDecoration(labelText: "Email:", icon: Icon(Icons.email)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        if(!EmailValidator.validate(value)){
          return "It is not email format";
        }
        return null;
      },
      onSaved: (newValue) => user.email = newValue,
    );
  }

  Widget passwordInputField() {
    return TextFormField(
      initialValue: "1q2w3e4r",
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
        if(_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          print(user.toJson().toString());
          login(context, user);
        }
    }, child: Text("Login"));
  }

  Widget backButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      }, 
      child: const Text("Back"));
  }

  Widget registerLink() {
    return InkWell(
      child: const Text("Sign Up"),
      onTap: () {

      },
    );
  }

  Widget fnameInputField() {
    return TextFormField(
      initialValue: "Chanankorn Jandaeng",
      decoration: InputDecoration(
        labelText: "Fullname:",
        icon: Icon(Icons.person)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved:(newValue) => user.fullname = newValue,
      );
  }
  
  Widget textHeader() {
  return Center(
    child: Text(
      "Login",
      style: TextStyle(fontSize: 40),
    ),
  );
}
}

Future<void> login(BuildContext context, Users user) async {
  try {
    var params = {"email": user.email, "password": user.password};
    var url = Uri.http(Configure.server, "users", params);
    var resp = await http.get(url);

    if (resp.statusCode == 200) {
      List<Users> login_result = usersFromJson(resp.body);
      if (login_result.isNotEmpty) {
        Configure.login = login_result[0];
        Navigator.pushNamed(context, Home.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid email or password")),
        );
      }
    } else {
      throw Exception("Failed to login");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}
