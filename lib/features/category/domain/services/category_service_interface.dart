
import 'package:stuwrite_user/common/enums/data_source_enum.dart';
import 'package:stuwrite_user/data/model/api_response.dart';

abstract class CategoryServiceInterface {

  Future<dynamic> getSellerWiseCategoryList(String slug);
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source});


}