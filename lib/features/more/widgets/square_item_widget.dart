import 'package:flutter/material.dart';
import 'package:stuwrite_user/features/cart/controllers/cart_controller.dart';
import 'package:stuwrite_user/helper/price_converter.dart';
import 'package:stuwrite_user/localization/language_constrants.dart';
import 'package:stuwrite_user/theme/controllers/theme_controller.dart';
import 'package:stuwrite_user/utill/custom_themes.dart';
import 'package:stuwrite_user/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SquareButtonWidget extends StatelessWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final int count;
  final bool hasCount;
  final bool isWallet;
  final double? balance;
  final bool isLoyalty;
  final String? subTitle;
  final Function? onTap;
  final double? boxWidth;
  final double? boxHeight;
  final EdgeInsetsGeometry boxPadding;

  const SquareButtonWidget({super.key, required this.image,
    required this.title, this.navigateTo, required this.count,
    required this.hasCount, this.isWallet = false, this.balance, this.subTitle,
    this.isLoyalty = false, this.onTap,
    this.boxWidth,
    this.boxHeight,
    this.boxPadding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Padding(
          padding: boxPadding,
          child: Container(
            width: boxWidth ?? 120,
            height: boxHeight ?? 90,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                color: Provider.of<ThemeController>(context).darkTheme ?
                Theme.of(context).primaryColor.withValues(alpha:.30) : Theme.of(context).primaryColor),
            child: Stack(children: [
              Positioned(top: -80,left: -10,right: -10,
                  child: Container(height: 120, decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha:.07), width: 15),
                      borderRadius: BorderRadius.circular(100)))),


              isWallet?
              Padding(padding: const EdgeInsets.all(8.0),
                child: SizedBox(width: 30, height: 30,child: Image.asset(image, color: Colors.white)),
              ):

              Center(child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(image, color:  Theme.of(context).colorScheme.secondaryContainer))),

              if(isWallet)
                Positioned(right: 10,bottom: 10,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(getTranslated(subTitle, context)??'', style: textRegular.copyWith(color: Colors.white),),
                      isLoyalty? Text(balance != null? balance!.toStringAsFixed(0) : '0',
                          style: textMedium.copyWith(color: Colors.white)):
                      Text(balance != null? PriceConverter.convertPrice(context, balance):'0',
                          style: textMedium.copyWith(color: Colors.white))])),

              hasCount?
              Positioned(top: 5, right: 5,
                child: Consumer<CartController>(builder: (context, cart, child) {
                  return CircleAvatar(radius: 10, backgroundColor: Theme.of(context).colorScheme.error,
                      child: Text(count.toString(), style: titilliumSemiBold.copyWith(color: Theme.of(context).cardColor,
                          fontSize: Dimensions.fontSizeExtraSmall)));
                })):const SizedBox(),
            ])),
        ),
        SizedBox(
          height: 16,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}