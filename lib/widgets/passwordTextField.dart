// ignore_for_file: file_names, require_trailing_commas, must_be_immutable
import 'package:sharaf_yabi_ecommerce/components/compackages.dart';

class PasswordTextFieldMine extends StatelessWidget {
  PasswordTextFieldMine({
    required this.mineFocus,
    required this.requestFocus,
    required this.controller,
    required this.hintText,
  });

  final AuthController authController = Get.put(AuthController());
  final TextEditingController controller;
  final String hintText;
  final FocusNode mineFocus;
  final FocusNode requestFocus;
  String a = "errorPassword1".tr;
  String b = "errorPassword2".tr;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text("userPassword".tr, style: const TextStyle(color: Colors.black, fontFamily: montserratSemiBold, fontSize: 18)),
        ),
        Obx(() {
          return TextFormField(
            style: const TextStyle(fontFamily: montserratMedium, fontSize: 17, color: Colors.black),
            textInputAction: TextInputAction.next,
            focusNode: mineFocus,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9 a-z A-Z]')),
              LengthLimitingTextInputFormatter(14),
            ],
            controller: controller,
            validator: (value) {
              if (value == "") {
                return a;
              } else if (value.toString().length < 8) {
                return b;
              }
              return null;
            },
            onEditingComplete: () {
              mineFocus.requestFocus();
            },
            cursorColor: kPrimaryColor,
            obscureText: authController.signInObscure.value,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                  onTap: () {
                    authController.changeSignInObscure();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      authController.signInObscure.value ? Icons.visibility_off : Icons.visibility,
                      color: authController.signInObscure.value ? Colors.grey : kPrimaryColor,
                      size: 22,
                    ),
                  )),
              errorMaxLines: 1,
              errorStyle: const TextStyle(fontFamily: montserratRegular),
              suffixIconConstraints: const BoxConstraints.tightForFinite(),
              isDense: true,
              hintText: hintText.tr,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 18, fontFamily: montserratMedium),
              disabledBorder: const UnderlineInputBorder(),
              border: const UnderlineInputBorder(),
              focusedBorder: const UnderlineInputBorder(),
              errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              enabledBorder: const UnderlineInputBorder(),
            ),
          );
        }),
      ],
    );
  }
}