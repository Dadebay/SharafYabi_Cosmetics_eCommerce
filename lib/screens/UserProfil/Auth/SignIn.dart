// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sharaf_yabi_ecommerce/constants/widgets.dart';
import 'package:sharaf_yabi_ecommerce/controllers/AuthController.dart';
import 'package:sharaf_yabi_ecommerce/models/UserModels/UserSignInModel.dart';
import 'package:sharaf_yabi_ecommerce/screens/BottomNavBar.dart';
import 'package:sharaf_yabi_ecommerce/widgets/PhoneNumber.dart';
import 'package:sharaf_yabi_ecommerce/widgets/TextFieldMine.dart';
import 'package:sharaf_yabi_ecommerce/widgets/agreeButton.dart';
import 'package:sharaf_yabi_ecommerce/widgets/passwordTextField.dart';
import 'package:vibration/vibration.dart';

class SingIN extends StatelessWidget {
  SingIN({Key? key}) : super(key: key);

  final AuthController authController = Get.put(AuthController());
  FocusNode nameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  TextEditingController sigInPassswordController = TextEditingController();
  TextEditingController signInNameController = TextEditingController();
  TextEditingController signInPhoneController = TextEditingController();

  final _signUp = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        color: Colors.white,
        child: Form(
          key: _signUp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextFieldMine(mineFocus: nameFocus, requestFocus: phoneFocus, controller: signInNameController, hintText: "Amanow Aman"),
              PhoneNumber(
                mineFocus: phoneFocus,
                requestFocus: passwordFocus,
                controller: signInPhoneController,
              ),
              PasswordTextFieldMine(mineFocus: passwordFocus, requestFocus: passwordFocus, controller: sigInPassswordController, hintText: "userPassword".tr),
              Center(
                child: AgreeButton(
                  name: "agree",
                  onTap: () {
                    if (_signUp.currentState!.validate()) {
                      authController.changeSignInAnimation();
                      UserSignInModel().signUp(fullname: signInNameController.text, phoneNumber: signInPhoneController.text, password: sigInPassswordController.text).then((value) {
                        if (value == true) {
                          showSnackBar("signIntitle", "signInSubtitle", Colors.green);
                          Get.to(() => BottomNavBar());
                        } else if (value == 409) {
                          showSnackBar("signInErrorTitle", "singInSubtitle ", Colors.red);
                          signInPhoneController.clear();
                        } else if (value == 500) {
                          showSnackBar("retry", "error404", Colors.red);
                        }
                      });
                      authController.changeSignInAnimation();
                    } else {
                      Vibration.vibrate();
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
