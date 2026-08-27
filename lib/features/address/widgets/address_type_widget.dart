
import 'package:flutter/material.dart';
import 'package:stuwrite_user/features/address/domain/models/address_model.dart';
import 'package:stuwrite_user/utill/custom_themes.dart';
import 'package:stuwrite_user/utill/dimensions.dart';
import 'package:stuwrite_user/utill/images.dart';

class AddressTypeWidget extends StatelessWidget {
  final AddressModel? address;
  const AddressTypeWidget({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Image.asset(address?.addressType == 'home' ? Images.homeImage
          : address!.addressType == 'office' ? Images.bag : Images.moreImage,
        color: Theme.of(context).textTheme.bodyLarge?.color, height: 30, width: 30),
      title: Text(address?.address??'',maxLines: 1, overflow: TextOverflow.ellipsis,
          style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
    );
  }
}
