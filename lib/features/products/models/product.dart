import 'package:bonako_demo/core/shared_models/link.dart';

import '../../../../core/shared_models/value_and_description.dart';
import '../../../core/shared_models/variant_attribute.dart';
import '../../../../core/shared_models/currency.dart';
import '../../../../core/shared_models/status.dart';
import '../../../../core/shared_models/money.dart';

class Quantitative {
  int quantity = 1;
}

class Product extends Quantitative {
  late int id;
  late Links links;
  late String? sku;
  late String name;
  late Status isFree;
  late Status visible;
  late String? barcode;
  late Money unitPrice;
  late int? arrangement;
  late Currency currency;
  late String? description;
  late Money unitSalePrice;
  late Money unitCostPrice;
  late Status showDescription;
  late Status allowVariations;
  late Money unitRegularPrice;
  late ValueAndDescription stockQuantity;
  late ValueAndDescription stockQuantityType;
  late List<VariantAttribute> variantAttributes;
  late ValueAndDescription allowedQuantityPerOrder;
  late ValueAndDescription maximumAllowedQuantityPerOrder;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sku = json['sku'];
    name = json['name'];
    barcode = json['barcode'];
    arrangement = json['arrangement'];
    description = json['description'];
    links = Links.fromJson(json['links']);
    isFree = Status.fromJson(json['isFree']);
    visible = Status.fromJson(json['visible']);
    unitPrice = Money.fromJson(json['unitPrice']);
    currency = Currency.fromJson(json['currency']);
    unitCostPrice = Money.fromJson(json['unitCostPrice']);
    unitSalePrice = Money.fromJson(json['unitSalePrice']);
    allowVariations = Status.fromJson(json['allowVariations']);
    showDescription = Status.fromJson(json['showDescription']);
    unitRegularPrice = Money.fromJson(json['unitRegularPrice']);
    stockQuantity = ValueAndDescription.fromJson(json['stockQuantity']);
    stockQuantityType = ValueAndDescription.fromJson(json['stockQuantityType']);
    allowedQuantityPerOrder = ValueAndDescription.fromJson(json['allowedQuantityPerOrder']);
    maximumAllowedQuantityPerOrder = ValueAndDescription.fromJson(json['maximumAllowedQuantityPerOrder']);
    variantAttributes = (json['variantAttributes'] as List).map((variantAttribute) => VariantAttribute.fromJson(variantAttribute)).toList();
  }
}

class Links {
  late Link self;
  late Link updateProduct;
  late Link deleteProduct;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    updateProduct = Link.fromJson(json['updateProduct']);
    deleteProduct = Link.fromJson(json['deleteProduct']);
  }

}