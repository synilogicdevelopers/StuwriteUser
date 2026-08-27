import 'package:stuwrite_user/common/enums/data_source_enum.dart';
import 'package:stuwrite_user/data/model/api_response.dart';
import 'package:stuwrite_user/interface/repo_interface.dart';

abstract class BannerRepositoryInterface<T> implements RepositoryInterface{
  Future<ApiResponseModel<T>> getBannerList<T>({required DataSourceEnum source});


}