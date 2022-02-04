// ignore_for_file: must_be_immutable, file_names

import 'package:sharaf_yabi_ecommerce/screens/UserProfil/userPackages.dart';

class Login extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  TextEditingController loginPassswordController = TextEditingController();
  TextEditingController loginPhoneController = TextEditingController();
  FocusNode paswordFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();

  final _login = GlobalKey<FormState>();

  Column textPart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: Text(
            "login".tr,
            style: const TextStyle(color: Colors.black, fontFamily: montserratSemiBold, fontSize: 22),
          ),
        ),
        Text(
          "signIn2".tr,
          style: const TextStyle(color: Colors.grey, fontFamily: montserratMedium, fontSize: 18),
        ),
      ],
    );
  }

  Padding textMine(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(name.tr, style: const TextStyle(color: Colors.black, fontFamily: montserratSemiBold, fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      color: Colors.white,
      child: Form(
        key: _login,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            textPart(),
            PhoneNumber(
              mineFocus: phoneFocus,
              requestFocus: paswordFocus,
              controller: loginPhoneController,
            ),
            PasswordTextFieldMine(mineFocus: paswordFocus, requestFocus: paswordFocus, controller: loginPassswordController, hintText: "userPassword".tr),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: AgreeButton(
                name: "agree",
                onTap: () {
                  if (_login.currentState!.validate()) {
                    authController.changeSignInAnimation();
                    UserSignInModel().login(phone: loginPhoneController.text, password: loginPassswordController.text).then((value) {
                      if (value == true) {
                        showSnackBar("signIntitle", "signInSubtitle", Colors.green);
                        Get.to(() => BottomNavBar());
                      } else if (value == 409) {
                        showSnackBar("signInErrorTitle", "singInSubtitle ", Colors.red);

                        loginPhoneController.clear();
                      } else if (value == 500) {
                        showSnackBar("retry", "error404", Colors.red);
                      } else if (value == 404) {
                        showSnackBar("retry", "errorLogin", Colors.red);
                      }
                      authController.changeSignInAnimation();
                    });
                  } else {
                    Vibration.vibrate();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}