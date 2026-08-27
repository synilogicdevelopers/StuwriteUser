import 'package:stuwrite_user/data/model/api_response.dart';
import 'package:stuwrite_user/interface/repo_interface.dart';

abstract class WishListRepositoryInterface implements RepositoryInterface<int>{

  Future<ApiResponseModel> getWishList({int? offset = 1, String? search = ''});

}