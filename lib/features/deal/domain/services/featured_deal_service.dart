import 'package:stuwrite_user/features/deal/domain/repositories/featured_deal_repository_interface.dart';
import 'package:stuwrite_user/features/deal/domain/services/featured_deal_service_interface.dart';
import 'package:stuwrite_user/common/enums/data_source_enum.dart';
import 'package:stuwrite_user/data/model/api_response.dart';

class FeaturedDealService implements FeaturedDealServiceInterface {
  final FeaturedDealRepositoryInterface featuredDealRepositoryInterface;
  FeaturedDealService({required this.featuredDealRepositoryInterface});

  @override
  Future<ApiResponseModel<T>> getFeaturedDeal<T>({required DataSourceEnum source}) async {
    return await featuredDealRepositoryInterface.getFeaturedDeal(source: source);
  }
}
