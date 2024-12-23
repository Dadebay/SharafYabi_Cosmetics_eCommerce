// ignore_for_file: must_be_immutable, deprecated_member_use, file_names, avoid_dynamic_calls, avoid_bool_literals_in_conditional_expressions, avoid_positional_boolean_parameters, always_declare_return_types, type_annotate_public_apis

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sharaf_yabi_ecommerce/components/appBar.dart';
import 'package:sharaf_yabi_ecommerce/components/constants/constants.dart';
import 'package:sharaf_yabi_ecommerce/components/constants/widgets.dart';
import 'package:sharaf_yabi_ecommerce/controllers/CartPageController.dart';
import 'package:sharaf_yabi_ecommerce/controllers/Fav_Cart_Controller.dart';
import 'package:sharaf_yabi_ecommerce/controllers/HomePageController.dart';
import 'package:sharaf_yabi_ecommerce/models/AddresModel.dart';
import 'package:sharaf_yabi_ecommerce/models/CartModel.dart';
import 'package:sharaf_yabi_ecommerce/screens/BottomNavBar.dart';
import 'package:sharaf_yabi_ecommerce/screens/UserProfil/pages/MyAddress.dart';
import 'package:vibration/vibration.dart';

import 'OrderComponents.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key, this.totalPrice, this.productCount}) : super(key: key);

  final int? productCount;
  final double? totalPrice;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

enum PaymentMethod { cash, creditCard }

class _OrderPageState extends State<OrderPage> {
  PaymentMethod payment = PaymentMethod.cash;
  TextEditingController addressController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final CartPageController cartPageController = Get.put(CartPageController());
  Fav_Cart_Controller favCartController = Get.put(Fav_Cart_Controller());

  double price = 0;
  final storage = GetStorage();
  final _form1Key = GlobalKey<FormState>();
  bool dataloaded = false;
  @override
  void initState() {
    super.initState();
    favCartController.orderTick.value = -1;
    cartPageController.sendButtonValue.value = false;
    cartPageController.nagt.value = 1;
    favCartController.promoDiscount.value = 0;
    favCartController.promoLottie.value = false;
    changeUserData();
  }

  changeUserData() async {
    final result = storage.read('data');
    await AddressModel().getAddress().then((value) {
      if (value.toString() != "[]") {
        dataloaded = true;
        favCartController.orderTick.value = 0;
        addressController.text = value[0].address!;
        noteController.text = value[0].comment!;
        if (result != null) {
          nameController.text = jsonDecode(result)["full_name"];
          phoneController.text = jsonDecode(result)["phone"];
        }
      } else {
        dataloaded = true;
        if (result != null) {
          nameController.text = jsonDecode(result)["full_name"];
          phoneController.text = "${jsonDecode(result)["phone"]}";
        }
      }
    });
    setState(() {});
  }

  Padding couponDiscount() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "couponCodeDiscount".tr,
            style: TextStyle(color: Colors.grey[500], fontSize: 16, fontFamily: montserratMedium),
          ),
          Obx(() {
            return Text(
              "${favCartController.promoDiscount.value}%",
              style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: montserratSemiBold),
            );
          })
        ],
      ),
    );
  }

  Center orderButton(BuildContext context) {
    return Center(
      child: Obx(() {
        return SizedBox(
          width: cartPageController.sendButtonValue.value ? 70 : Get.size.width,
          child: RaisedButton(
            shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
            color: kPrimaryColor,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: 10),
            onPressed: () {
              if (nameController.text.isEmpty) {
                Vibration.vibrate();
                showSnackBar("retry", "errorName", Colors.red);
              } else if (phoneController.text.isEmpty) {
                Vibration.vibrate();
                showSnackBar("retry", "errorPhone", Colors.red);
              } else if (addressController.text.isEmpty) {
                Vibration.vibrate();
                showSnackBar("retry", "errorAddress", Colors.red);
              } else {
                final storage = GetStorage();
                final result = storage.read('data') ?? "[]";
                String id = "";
                if (result != "[]") {
                  id = jsonDecode(result)["id"];
                }
                cartPageController.sendButtonValue.value = true;
                OrderModel()
                    .createOrder(
                        userID: id,
                        phoneNumber: phoneController.text,
                        address: addressController.text,
                        name: nameController.text,
                        coupon: couponController.text,
                        comment: noteController.text,
                        payment: "${cartPageController.nagt.value}")
                    .then((value) {
                  if (value == true) {
                    completeOrder();
                    Get.find<HomePageController>().refreshList();
                  } else {
                    cartPageController.sendButtonValue.value = false;
                    Vibration.vibrate();
                    showSnackBar("retry", "error404", Colors.red);
                  }
                });
              }
            },
            child: cartPageController.sendButtonValue.value
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text("order".tr, style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: montserratSemiBold)),
          ),
        );
      }),
    );
  }

  Widget paymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "${"paymentMethod".tr} : ",
            style: const TextStyle(color: Colors.black, fontFamily: montserratSemiBold, fontSize: 20),
          ),
        ),
        RadioListTile<PaymentMethod>(
          contentPadding: EdgeInsets.zero,
          value: PaymentMethod.cash,
          groupValue: payment,
          onChanged: (PaymentMethod? value) {
            setState(() {
              payment = value!;
              cartPageController.nagt.value = 1;
            });
          },
          activeColor: kPrimaryColor,
          title: Text(
            "cash".tr,
            style: const TextStyle(color: Colors.black, fontFamily: montserratMedium),
          ),
          subtitle: Text(
            "cashSubtitle".tr,
            style: const TextStyle(color: Colors.black54, fontFamily: montserratRegular),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        RadioListTile<PaymentMethod>(
          contentPadding: EdgeInsets.zero,
          value: PaymentMethod.creditCard,
          groupValue: payment,
          onChanged: (PaymentMethod? value) {
            setState(() {
              payment = value!;
              cartPageController.nagt.value = 2;
            });
          },
          activeColor: kPrimaryColor,
          title: Text(
            "creditCart".tr,
            style: const TextStyle(color: Colors.black, fontFamily: montserratMedium),
          ),
          subtitle: Text(
            "creditCartSubtitle".tr,
            style: const TextStyle(color: Colors.black54, fontFamily: montserratRegular),
          ),
        )
      ],
    );
  }

  Widget mineListTile(String text, String labelText, IconData icon, String dialogTitle, TextEditingController controllermine, int textLength, bool changeIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        minVerticalPadding: 0.0,
        dense: true,
        tileColor: backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: borderRadius10),
        title: Text(text.tr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kPrimaryColor, fontSize: 16, fontFamily: montserratMedium)),
        leading: Icon(icon, color: kPrimaryColor),
        trailing: Icon(changeIcon ? Icons.done : IconlyLight.arrowRightCircle, color: kPrimaryColor),
        onTap: () {
          if (storage.read("AccessToken") != null) {
            textLength == 50
                ? findMyAddress(
                    onTap: () {
                      Get.back();
                      Get.defaultDialog(
                          radius: 8,
                          titlePadding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                          title: dialogTitle.tr,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          titleStyle: const TextStyle(color: Colors.black, fontSize: 20, fontFamily: montserratMedium),
                          content: customTextField(labelText, controllermine, textLength));
                    },
                  )
                : Get.defaultDialog(
                    radius: 8,
                    titlePadding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                    title: dialogTitle.tr,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    titleStyle: const TextStyle(color: Colors.black, fontSize: 20, fontFamily: montserratMedium),
                    content: customTextField(labelText, controllermine, textLength));
          } else {
            Get.defaultDialog(
                radius: 8,
                titlePadding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                title: dialogTitle.tr,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                titleStyle: const TextStyle(color: Colors.black, fontSize: 20, fontFamily: montserratMedium),
                content: customTextField(labelText, controllermine, textLength));
          }
        },
      ),
    );
  }

  Column customTextField(String hintText, TextEditingController controller, int lenght) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Form(
            key: _form1Key,
            child: controller == phoneController
                ? phoneNumberTextField(phoneController)
                : TextFormField(
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: kPrimaryColor,
                    maxLines: lenght > 20 ? 3 : 1,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(lenght),
                    ],
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: montserratMedium),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "errorEmpty".tr;
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        label: Text(hintText.tr),
                        alignLabelWithHint: true,
                        prefixIconConstraints: const BoxConstraints.tightForFinite(),
                        labelStyle: const TextStyle(color: Colors.grey, fontFamily: montserratMedium),
                        constraints: const BoxConstraints(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 18, fontFamily: montserratMedium),
                        border: const OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: kPrimaryColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius10,
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                            )),
                        focusedBorder: const OutlineInputBorder(borderRadius: borderRadius10, borderSide: BorderSide(color: kPrimaryColor, width: 2))),
                  ),
          ),
        ),
        SizedBox(
          width: Get.size.width,
          child: RaisedButton(
            color: kPrimaryColor,
            shape: const RoundedRectangleBorder(borderRadius: borderRadius10),
            onPressed: () {
              if (_form1Key.currentState!.validate()) {
                if (controller == couponController) {
                  OrderModel().createPromo(coupon: couponController.text).then((value) {
                    if (value == false) {
                      Vibration.vibrate();

                      showSnackBar("retry", "couponCodeError", Colors.red);
                    } else {
                      showSnackBar("couponCodeDiscountTrueTitle", "${"couponCodeDiscountTrueSubtitle".tr} : $value%", kPrimaryColor);

                      favCartController.promoLottie.value = true;
                      favCartController.promoDiscount.value = value;
                    }
                  });
                }
                Future.delayed(const Duration(seconds: 5), () {
                  favCartController.promoLottie.value = false;
                });
                setState(() {});
                Get.back();
              } else {
                Vibration.vibrate();
              }
            },
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text("agree".tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: montserratSemiBold)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: MyAppBar(
          icon: Icons.add,
          onTap: () {},
          backArrow: true,
          iconRemove: false,
          name: "orders",
          addName: true,
        ),
        body: dataloaded
            ? Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mineListTile(nameController.text.isEmpty ? "enterUserName" : "${"orderName".tr} : ${nameController.text}", "enterUserName", IconlyLight.profile, "pleaseEnterYourName",
                              nameController, 20, nameController.text.isEmpty ? false : true),
                          mineListTile(phoneController.text.isEmpty ? "userPhoneNumber" : "${"orderPhone".tr} : ${phoneController.text}", "userPhoneNumber", IconlyLight.call, "pleaseEnterYourPhone",
                              phoneController, 8, phoneController.text.isEmpty ? false : true),
                          mineListTile(addressController.text.isEmpty ? "address" : "${"orderAddress".tr} : ${addressController.text}", "address", IconlyLight.location, "pleaseEnterYourAddress",
                              addressController, 50, addressController.text.isEmpty ? false : true),
                          mineListTile(noteController.text.isEmpty ? "note" : "${"orderNote".tr} : ${noteController.text}", "note", IconlyLight.editSquare, "pleaseEnterYourNote", noteController, 49,
                              noteController.text.isEmpty ? false : true),
                          mineListTile(couponController.text.isEmpty ? "couponCodeTitle" : "${"orderСoupon".tr} :  ${couponController.text}", "couponCodeTitle", IconlyLight.discount,
                              "pleaseEnterYourCouponeCode", couponController, 20, couponController.text.isEmpty ? false : true),
                          const SizedBox(
                            height: 80,
                          ),
                          paymentMethod(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "${"orderInfo".tr} : ",
                              style: const TextStyle(color: Colors.black, fontFamily: montserratSemiBold, fontSize: 20),
                            ),
                          ),
                          productsCount(widget.productCount!),
                          couponDiscount(),
                          total(),
                          orderButton(context),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    return Center(
                        child: favCartController.promoLottie.value == true
                            ? Lottie.asset(
                                couponFallingConfetti,
                                animate: true,
                              )
                            : const SizedBox.shrink());
                  }),
                ],
              )
            : Center(
                child: spinKit(),
              ));
  }

  Padding total() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "total".tr,
            style: TextStyle(color: Colors.grey[500], fontSize: 16, fontFamily: montserratMedium),
          ),
          Obx(() {
            price = widget.totalPrice!;
            price = ((100 - favCartController.promoDiscount.value) / 100) * price;
            return RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(children: <TextSpan>[
                TextSpan(text: price.toStringAsFixed(2), style: const TextStyle(fontFamily: montserratSemiBold, fontSize: 20, color: Colors.black)),
                const TextSpan(text: " m.", style: TextStyle(fontFamily: montserratSemiBold, fontSize: 16, color: Colors.black))
              ]),
            );
          }),
        ],
      ),
    );
  }

  findMyAddress({required Function() onTap}) {
    Get.defaultDialog(
        radius: 4,
        title: "myAddress".tr,
        content: FutureBuilder<List<AddressModel>>(
          future: AddressModel().getAddress(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: spinKit(),
              );
            } else if (snapshot.hasData) {
              return snapshot.data.toString() == "[]"
                  ? GestureDetector(
                      onTap: () {
                        Get.back();
                        pushNewScreen(context, screen: MyAddress(), withNavBar: true, pageTransitionAnimation: PageTransitionAnimation.fade);
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("noAddresses".tr, style: const TextStyle(color: Colors.black, fontFamily: montserratRegular)),
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: const BoxDecoration(color: kPrimaryColor, borderRadius: borderRadius5),
                              child: Text("${"addAddress".tr} + ", style: const TextStyle(color: Colors.white, fontFamily: montserratMedium))),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                                snapshot.data!.length,
                                (index) => CheckboxListTile(
                                      value: favCartController.orderTick.value == index ? true : false,
                                      activeColor: kPrimaryColor,
                                      onChanged: (value) {
                                        favCartController.orderTick.value = index;
                                        addressController.text = snapshot.data![index].address;
                                        noteController.text = snapshot.data![index].comment;
                                        Get.back();
                                        Get.back();
                                        setState(() {});
                                      },
                                      title: Text(snapshot.data![index].address, maxLines: 2, style: const TextStyle(color: Colors.black, fontFamily: montserratMedium)),
                                      subtitle: Text(snapshot.data![index].comment, maxLines: 2, style: const TextStyle(color: Colors.grey, fontFamily: montserratRegular)),
                                    ))),
                        GestureDetector(
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text("selectMyaddresses".tr, style: const TextStyle(color: kPrimaryColor, decoration: TextDecoration.underline, fontFamily: montserratMedium)),
                          ),
                        )
                      ],
                    );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("noAddresses".tr, style: const TextStyle(color: Colors.black, fontFamily: montserratRegular)),
                ),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(color: kPrimaryColor, borderRadius: borderRadius5),
                    child: Text("${"addAddress".tr} + ", style: const TextStyle(color: Colors.white, fontFamily: montserratMedium))),
              ],
            );
          },
        ));
  }

  completeOrder() {
    cartPageController.sendButtonValue.value = false;

    showGeneralDialog(
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: borderRadius15),
                content: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      width: Get.size.width / 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("orderComplete".tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontFamily: montserratSemiBold)),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text("orderCompleteSubtitle".tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontFamily: montserratRegular)),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -90,
                      child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Lottie.asset(cartBlack, fit: BoxFit.cover, width: 110, height: 110)),
                    )
                  ],
                ),
                actions: [
                  SizedBox(
                    width: Get.size.width / 1.5,
                    child: RaisedButton(
                      onPressed: () {
                        Get.back();
                        pushNewScreen(
                          context,
                          screen: BottomNavBar(),
                          withNavBar: false,
                          pageTransitionAnimation: PageTransitionAnimation.fade,
                        );
                      },
                      shape: const RoundedRectangleBorder(borderRadius: borderRadius15),
                      color: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text("homePage".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: montserratSemiBold,
                          )),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return SizedBox.shrink();
        });
  }
}
