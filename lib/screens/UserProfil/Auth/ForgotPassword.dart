// ignore_for_file: file_names, must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sharaf_yabi_ecommerce/constants/constants.dart';
import 'package:sharaf_yabi_ecommerce/constants/widgets.dart';
import 'package:sharaf_yabi_ecommerce/models/UserModels/UserSignInModel.dart';
import 'package:sharaf_yabi_ecommerce/screens/UserProfil/Auth/ChangePassword.dart';
import 'package:sharaf_yabi_ecommerce/widgets/appBar.dart';
import 'package:vibration/vibration.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController phoneNumberController = TextEditingController();

  TextEditingController otpController = TextEditingController();

  bool numberSendLoading = false;
  bool otpHide = false;
  final _login = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: MyAppBar(
        icon: Icons.add,
        onTap: () {},
        backArrow: true,
        iconRemove: false,
        name: "forgotPassword",
        addName: true,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "phone".tr,
                style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: montserratMedium),
              ),
              Form(
                key: _login,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 20),
                  child: TextFormField(
                    style: const TextStyle(fontFamily: montserratMedium, fontSize: 18, color: Colors.black),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "errorEmpty".tr;
                      } else if (value.length != 8) {
                        return "errorPhoneCount".tr;
                      }
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(8),
                    ],
                    controller: phoneNumberController,
                    decoration: const InputDecoration(
                      errorMaxLines: 2,
                      errorStyle: TextStyle(fontFamily: montserratRegular),
                      prefixIcon: Text(
                        '  + 993  ',
                        style: TextStyle(color: Colors.grey, fontSize: 19, fontFamily: montserratMedium),
                      ),
                      prefixIconConstraints: BoxConstraints.tightForFinite(),
                      isDense: true,
                      hintText: '65 656565 ',
                      errorBorder: OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: Colors.red)),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18, fontFamily: montserratMedium),
                      border: OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: kPrimaryColor, width: 2)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: Colors.red, width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: kPrimaryColor, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: Colors.black12, width: 2)),
                    ),
                  ),
                ),
              ),
              if (otpHide)
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: TextFormField(
                    style: const TextStyle(fontFamily: montserratMedium, fontSize: 18, color: Colors.black),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "errorEmpty".tr;
                      }
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                    ],
                    controller: otpController,
                    decoration: InputDecoration(
                      errorMaxLines: 2,
                      errorStyle: const TextStyle(fontFamily: montserratRegular),
                      label: Text("smsKod".tr),
                      labelStyle: const TextStyle(color: Colors.grey, fontFamily: montserratMedium),
                      isDense: true,
                      errorBorder: const OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: Colors.red)),
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 18, fontFamily: montserratMedium),
                      focusedErrorBorder: const OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: Colors.red, width: 1)),
                      focusedBorder: const OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: kPrimaryColor, width: 2)),
                      enabledBorder: const OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: Colors.black12, width: 2)),
                    ),
                  ),
                )
              else
                SizedBox.shrink(),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    if (otpHide == false) {
                      if (_login.currentState!.validate()) {
                        setState(() {
                          numberSendLoading = true;
                        });

                        UserSignInModel().forgotPassword(phoneNumber: phoneNumberController.text).then((value) {
                          if (value == 200) {
                            showCustomToast(context, "writeSmsKod");
                            setState(() {
                              otpHide = true;
                              numberSendLoading = false;
                            });
                          } else if (value == 500) {
                            showSnackBar("signInErrorTitle", "singInErrorSubtitle2", Colors.red);
                            setState(() {
                              numberSendLoading = false;
                              Vibration.vibrate();
                            });
                          } else {
                            showCustomToast(context, "error404");
                            setState(() {
                              numberSendLoading = false;
                              Vibration.vibrate();
                            });
                          }
                        });
                      }
                    } else {
                      Get.to(() => ChangePassword(
                            otpCode: otpController.text,
                          ));
                    }
                  },
                  color: kPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: numberSendLoading ? 10 : 4, horizontal: 12),
                  shape: const RoundedRectangleBorder(borderRadius: borderRadius10),
                  child: numberSendLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("send".tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: montserratMedium)),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                IconlyLight.send,
                                color: Colors.white,
                              ),
                            )
                          ],
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