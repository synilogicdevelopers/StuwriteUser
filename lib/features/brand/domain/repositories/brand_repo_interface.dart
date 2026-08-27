import 'package:stuwrite_user/common/enums/data_source_enum.dart';
import 'package:stuwrite_user/interface/repo_interface.dart';

abstract class BrandRepoInterface implements RepositoryInterface {
  Future<dynamic> getBrandList<T>({int offset, required DataSourceEnum source});

  Future<dynamic> getSellerWiseBrandList(String slug);
}
