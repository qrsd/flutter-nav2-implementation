class RoutePath {
  final Uri uri;
  final int id;

  RoutePath.home()
      : uri = Uri(path: '/'),
        id = null;

  RoutePath.unknown()
      : uri = Uri(path: '/unknown'),
        id = null;

  RoutePath.product(this.id) : uri = Uri(path: '/product/${id.toString()}');

  bool get isHomePage => uri == RoutePath.home().uri;
  bool get isUnknown => uri == RoutePath.unknown().uri;
  bool get isProductPage => id != null;
}
