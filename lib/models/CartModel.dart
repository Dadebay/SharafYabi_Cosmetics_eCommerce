// ignore_for_file: file_names, avoid_print, avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sharaf_yabi_ecommerce/components/compackages.dart';

class CartModel extends ChangeNotifier {
  CartModel({
    this.id,
    this.price,
    this.stock,
    this.name,
    this.image,
    this.categoryId,
    this.producerId,
    this.description,
    this.producerName,
    this.categoryName,
    this.discountValue,
    this.minValue,
  });

  factory CartModel.fromJson(Map<dynamic, dynamic> json) {
    return CartModel(
      id: json['id'],
      price: json['price'],
      stock: json['stock'],
      image: json['destination'],
      categoryId: json['category_id'],
      producerId: json['producer_id'],
      name: json['name'],
      description: json['description'],
      producerName: json['producer_name'],
      categoryName: json['category_name'],
      discountValue: json['discount_value'],
      minValue: json['min_value'],
    );
  }

  final int? id;
  final String? price;
  final String? stock;
  final String? image;
  final String? name;
  final int? categoryId;
  final String? categoryName;
  final String? description;
  final int? discountValue;
  final int? minValue;
  final int? producerId;
  final String? producerName;
}

class OrderModel extends ChangeNotifier {
  OrderModel({
    this.id,
  });

  factory OrderModel.fromJson(Map<dynamic, dynamic> json) {
    return OrderModel(
      id: json['id'],
    );
  }

  final int? id;

  Future createOrder({String? coupon, String? name, String? userID, String? address, String? phoneNumber, String? comment}) async {
    final body = json.encode({
      "products": Get.find<Fav_Cart_Controller>().cartList,
      "coupon": coupon ?? "",
      "phone": phoneNumber ?? "",
      "address": address ?? "",
      "user_id": userID ?? "",
      "name": name ?? "",
      "comment": comment ?? "",
    });
    final response = await http.post(
        Uri.parse(
          "$serverURL/api/tm/create-order",
        ),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      Get.find<Fav_Cart_Controller>().clearCartList();
      Get.find<AuthController>().changeSignInAnimation();
      return true;
    } else {
      Get.find<AuthController>().changeSignInAnimation();
      showSnackBar("retry", "error404", Colors.red);
      return false;
    }
  }

  Future createPromo({
    String? coupon,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$serverURL/api/ru/get-coupon?coupon=$coupon",
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)["rows"] == null) {
        return false;
      } else {
        final responseJson = jsonDecode(response.body)["rows"]["discount_value"] ?? false;
        return responseJson ?? false;
      }
    } else {
      return false;
    }
  }
}
