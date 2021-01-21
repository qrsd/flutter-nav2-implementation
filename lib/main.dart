import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/pages/mainPage.dart';
import 'package:flutter_ecommerce_app/src/pages/product_detail.dart';
import 'package:flutter_ecommerce_app/src/pages/unknown_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/config/route_path.dart';
import 'src/model/data.dart';
import 'src/model/product.dart';
import 'src/themes/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _routerDelegate = PageRouteDelegate();
  final _routeInformationParser = PageRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'E-Commerce ',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.muliTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class PageRouteInformationParser extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);

    // home '/'
    if (uri.pathSegments.length == 0) return RoutePath.home();
    // product '/product/:id'
    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'product') {
      final id = int.tryParse(uri.pathSegments.elementAt(1));
      return id == null || id > AppData.productList.length - 1
          ? RoutePath.unknown()
          : RoutePath.product(id);
    }
    // 404
    return RoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath path) {
    if (path.isUnknown)
      return RouteInformation(location: RoutePath.unknown().uri.path);
    else if (path.isHomePage)
      return RouteInformation(location: RoutePath.home().uri.path);
    else if (path.isProductPage) {
      return RouteInformation(location: RoutePath.product(path.id).uri.path);
    }

    return null;
  }
}

class PageRouteDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  RoutePath currentState = RoutePath.home();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('HomePage'),
          child: MainPage(
            onTapped: handleProductTap,
          ),
        ),
        if (currentState.isProductPage)
          MaterialPage(
            key: ValueKey('ProductPage${currentState.id.toString()}'),
            child: ProductDetailPage(
              product: AppData.productList[currentState.id],
            ),
          ),
        if (currentState.isUnknown)
          MaterialPage(key: ValueKey('UnknownPage'), child: UnknownPage())
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        } else {
          currentState = RoutePath.home();
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath newState) async {
    currentState = newState;
    return;
  }

  void handleProductTap(Product product) {
    currentState = RoutePath.product(AppData.productList.indexOf(product));
    notifyListeners();
  }

  @override
  RoutePath get currentConfiguration => currentState;

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();
}
