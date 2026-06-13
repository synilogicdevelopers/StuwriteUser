import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';

Future<void> showUpiAppPicker({
  required BuildContext context,
  required List<ApplicationMeta>? apps,
  required ValueChanged<ApplicationMeta> onSelectApp,
  required Future<void> Function() onSelectOtherMethods,
}) async {
  final upiApps = apps ?? await UpiPay.getInstalledUpiApplications(
    statusType: UpiApplicationDiscoveryAppStatusType.all,
  );

  if (!context.mounted) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      getTranslated('select_upi_app', sheetContext) ?? 'Select your UPI App',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (upiApps.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(getTranslated('no_upi_app_found', sheetContext) ?? 'No UPI apps installed'),
                  ),
                )
              else
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: upiApps.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final app = upiApps[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          onSelectApp(app);
                        },
                        child: SizedBox(
                          width: 84,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).dividerColor),
                                ),
                                child: app.iconImage(36),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                app.upiApplication.appName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: Dimensions.fontSizeSmall),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await onSelectOtherMethods();
                  },
                  child: Text(getTranslated('other_payment_methods', sheetContext) ?? 'Other payment methods'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
