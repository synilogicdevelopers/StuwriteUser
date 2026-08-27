import 'package:stuwrite_user/interface/repo_interface.dart';

abstract class CouponRepositoryInterface<T> extends RepositoryInterface{

  Future<dynamic> getAvailableCouponList();

  Future<dynamic> getSellerCouponList(String slug, int offset);

}