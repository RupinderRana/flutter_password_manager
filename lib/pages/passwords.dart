import 'package:encrypt/encrypt.dart' as ENCRYPT;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_manager/controller/encrypter.dart';

class Passwords extends StatefulWidget {
  @override
  _PasswordsState createState() => _PasswordsState();
}

class _PasswordsState extends State<Passwords> {
  Box box = Hive.box('passwords');
  EncryptService _encryptService = new EncryptService();
  Future fetch() async {
    if (box.values.isEmpty) {
      return Future.value(null);
    } else {
      return Future.value(box.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Your Passwords",
          style: TextStyle(
            fontFamily: "customFont",
          ),
        ),
      ),
      //
      floatingActionButton: FloatingActionButton(
        onPressed: insertDB,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
        backgroundColor: Color(0xff892cdc),
      ),
      //
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      //
      body: FutureBuilder(
        future: fetch(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Text("No Value !");
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                // Map data = snapshot.data[index];
                Map data = box.getAt(index);
                print(data);
                return Card(
                  margin: EdgeInsets.all(
                    12.0,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 20.0,
                    ),
                    leading: Icon(
                      Icons.verified_user_outlined,
                    ),
                    title: Text(
                      "${data['type']}",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontFamily: "customFont",
                      ),
                    ),
                    subtitle: Text(
                      "CLick on the copy icon to copy your Password !",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "customFont",
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        _encryptService.copyToClipboard(
                            data['password'], context);
                      },
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 36.0,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void insertDB() {
    String type;
    String email;
    String password;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(
          12.0,
        ),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Service",
                  hintText: "Google",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "customFont",
                ),
                onChanged: (val) {
                  type = val;
                },
                validator: (val) {
                  if (val.trim().isEmpty) {
                    return "Enter A Value !";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 12.0,
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Username/Email/Phone",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "customFont",
                ),
                onChanged: (val) {
                  email = val;
                },
                validator: (val) {
                  if (val.trim().isEmpty) {
                    return "Enter A Value !";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 12.0,
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "customFont",
                ),
                onChanged: (val) {
                  password = val;
                },
                validator: (val) {
                  if (val.trim().isEmpty) {
                    return "Enter A Value !";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 12.0,
              ),
              ElevatedButton(
                onPressed: () {
                  // encrypt

                  final plainText = 'password1234';
                  final key = ENCRYPT.Key.fromUtf8('WlFsdCYyJPPmKAVeA9ir+A==');
                  final iv = ENCRYPT.IV.fromLength(16);

                  final encrypter = ENCRYPT.Encrypter(ENCRYPT.AES(key));

                  final encrypted = encrypter.encrypt(password, iv: iv);
                  final decrypted = encrypter.decrypt(encrypted, iv: iv);
                  print(encrypted.base64);
                  print(decrypted);

                  // insert into db
                  Box box = Hive.box('passwords');

                  // insert
                  var value = {
                    'type': type,
                    'email': email,
                    'password': encrypted.base64,
                  };
                  box.add(value);

                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: "customFont",
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 50.0,
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    Color(0xff892cdc),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
