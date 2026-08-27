import 'package:stuwrite_user/common/enums/data_source_enum.dart';

abstract class BrandServiceInterface {
  Future<dynamic> getSellerWiseBrandList(String slug);
  Future<dynamic> getBrandList<T>({int offset, required DataSourceEnum source});
  Future<dynamic> getList();
}
