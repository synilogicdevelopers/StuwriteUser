import 'package:stuwrite_user/data/datasource/remote/dio/dio_client.dart';
import 'package:stuwrite_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:stuwrite_user/data/model/api_response.dart';
import 'package:stuwrite_user/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:stuwrite_user/utill/app_constants.dart';

class CouponRepository implements CouponRepositoryInterface{
  final DioClient? dioClient;
  CouponRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> get(dynamic coupon) async {
    try {
      final response = await dioClient!.get('${AppConstants.couponUri}$coupon');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getList({int? offset}) async {
    try {
      final response = await dioClient!.get('${AppConstants.couponListApi}$offset');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getAvailableCouponList() async {
    try {
      final response = await dioClient!.get(AppConstants.availableCoupon);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getSellerCouponList(String slug, int offset) async {
    try {
      final response = await dioClient!.get('${AppConstants.sellerWiseCouponListApi}$slug/seller-wise-coupons?limit=100&offset=$offset');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }



  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }

}