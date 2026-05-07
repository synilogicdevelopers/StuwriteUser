import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sixvalley_ecommerce/data/local/cache_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/facebook_login_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/google_login_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/compare/controllers/compare_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/contact_us/controllers/contact_us_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/loyaltyPoint/controllers/loyalty_point_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/controllers/order_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/refund/controllers/refund_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/reorder/controllers/re_order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/restock/controllers/restock_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/screens/splash_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/controllers/support_ticket_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/coupon/controllers/coupon_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/controllers/search_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/notification_helper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'di_container.dart' as di;
import 'features/splash/domain/models/config_model.dart';
import 'helper/custom_delegate.dart';
import 'localization/app_localization.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final database = AppDatabase();

void _installGlobalErrorHandlers() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('ErrorWidget: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint('${details.stack}');
    }
    return _GlobalErrorPanel(
      heading: 'Something went wrong',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught async error: $error\n$stack');
    return true;
  };
}

class _GlobalErrorPanel extends StatelessWidget {
  const _GlobalErrorPanel({
    required this.heading,
    required this.error,
    this.stackTrace,
  });

  final String heading;
  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final text = StringBuffer(error.toString());
    if (stackTrace != null) {
      text.write('\n\n');
      text.write(stackTrace);
    }
    return Material(
      color: const Color(0xFFF2F2F7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.error_outline, size: 44, color: Colors.red.shade800),
                const SizedBox(height: 12),
                Text(
                  heading,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  text.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF3A3A3C),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();

  if (AppConstants.baseUrl.contains('YOUR_BASE_URL')) {
    debugPrint(
      'Configure AppConstants.baseUrl in lib/utill/app_constants.dart with your live backend URL (scheme + host, no trailing slash).',
    );
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
    await di.init();

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    String? path;
    NotificationBody? body;

    try {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
      path = await initDynamicLinks();
    } catch (_) {}

    GoRouter.optionURLReflectsImperativeAPIs = true;

    runApp(MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => di.sl<CategoryController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ShopController>()),
        ChangeNotifierProvider(create: (context) => di.sl<FlashDealController>()),
        ChangeNotifierProvider(create: (context) => di.sl<FeaturedDealController>()),
        ChangeNotifierProvider(create: (context) => di.sl<BrandController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProductController>()),
        ChangeNotifierProvider(create: (context) => di.sl<BannerController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProductDetailsController>()),
        ChangeNotifierProvider(create: (context) => di.sl<OnBoardingController>()),
        ChangeNotifierProvider(create: (context) => di.sl<AuthController>()),
        ChangeNotifierProvider(create: (context) => di.sl<SearchProductController>()),
        ChangeNotifierProvider(create: (context) => di.sl<CouponController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ChatController>()),
        ChangeNotifierProvider(create: (context) => di.sl<OrderController>()),
        ChangeNotifierProvider(create: (context) => di.sl<NotificationController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProfileController>()),
        ChangeNotifierProvider(create: (context) => di.sl<WishListController>()),
        ChangeNotifierProvider(create: (context) => di.sl<SplashController>()),
        ChangeNotifierProvider(create: (context) => di.sl<CartController>()),
        ChangeNotifierProvider(create: (context) => di.sl<SupportTicketController>()),
        ChangeNotifierProvider(create: (context) => di.sl<LocalizationController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ThemeController>()),
        ChangeNotifierProvider(create: (context) => di.sl<GoogleSignInController>()),
        ChangeNotifierProvider(create: (context) => di.sl<FacebookLoginController>()),
        ChangeNotifierProvider(create: (context) => di.sl<AddressController>()),
        ChangeNotifierProvider(create: (context) => di.sl<WalletController>()),
        ChangeNotifierProvider(create: (context) => di.sl<CompareController>()),
        ChangeNotifierProvider(create: (context) => di.sl<CheckoutController>()),
        ChangeNotifierProvider(create: (context) => di.sl<LoyaltyPointController>()),
        ChangeNotifierProvider(create: (context) => di.sl<LocationController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ContactUsController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ShippingController>()),
        ChangeNotifierProvider(create: (context) => di.sl<OrderDetailsController>()),
        ChangeNotifierProvider(create: (context) => di.sl<RefundController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ReOrderController>()),
        ChangeNotifierProvider(create: (context) => di.sl<ReviewController>()),
        ChangeNotifierProvider(create: (context) => di.sl<SellerProductController>()),
        ChangeNotifierProvider(create: (context) => di.sl<RestockController>()),
      ],
      child: MyApp(body: body, route: path),
    ));
  } catch (e, st) {
    debugPrint('Startup failed: $e\n$st');
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _GlobalErrorPanel(
          heading: 'App failed to start',
          error: e,
          stackTrace: st,
        ),
      ),
    );
  }
}

StreamSubscription<Uri?>? _sub;


Future<String?> initDynamicLinks() async {
  final appLinks = AppLinks();

  final uri = await appLinks.getInitialLink();
  if (uri != null) {
    return uri.path;
  }

  _sub = appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null) {

      Future.delayed(const Duration(milliseconds: 300), () {
        if (navigatorKey.currentContext != null) {
          // navigatorKey.currentContext!.go(uri.path);
        }
      });
    }
  });

  return null;
}


class MyApp extends StatefulWidget {
  final NotificationBody? body;
  final String? route;
  const MyApp({
    super.key,
    required this.body,
    this.route
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    super.initState();
  }


  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }


  void _loadData() async {
    if(widget.route != null) {
      final AuthController authProvider = Provider.of<AuthController>(context, listen: false);

      if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
        await Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
      }

      if(mounted) {
        Provider.of<SplashController>(context, listen: false).initConfig(context, (_) {},
            (ConfigModel? configModel) async {
          if(configModel != null) {
            if (authProvider.isLoggedIn()) {
              await authProvider.updateToken(context);
            }
          }
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }
    return Consumer<SplashController>(
      builder: (context, splashController, _) {
        return Consumer<ThemeController>(
          builder: (context, themeController, _) {
            if ((widget.route != null && splashController.configModel == null)) {
              return Theme(
                data : themeController.darkTheme ? dark : light(
                  primaryColor: Theme.of(context).primaryColor,
                  secondaryColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Directionality(
                textDirection: TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQueryData.fromView(View.of(context)),
                  child: SplashWidget()
                )
              ));
            } else {
              return MaterialApp.router(
              routerConfig: RouterHelper.goRoutes,
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: themeController.darkTheme ? dark : light(
                primaryColor: Theme.of(context).primaryColor,
                secondaryColor: Theme.of(context).colorScheme.secondary,
              ),
              locale: Provider.of<LocalizationController>(context).locale,
              localizationsDelegates: [
                AppLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FallbackLocalizationDelegate()
              ],
              builder:(context,child) {
                return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), child: SafeArea(top: false, child: child!));
              },
              supportedLocales: locals,
            );
            }
          }
        );
      }
    );
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}