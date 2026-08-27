import 'package:stuwrite_user/common/enums/data_source_enum.dart';
import 'package:stuwrite_user/data/model/api_response.dart';
import 'package:stuwrite_user/interface/repo_interface.dart';

abstract class CategoryRepoInterface extends RepositoryInterface{
  Future<dynamic> getSellerWiseCategoryList(String slug);

  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source});


}