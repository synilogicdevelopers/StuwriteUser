import 'package:stuwrite_user/features/onboarding/domain/repositories/onboarding_repository_interface.dart';
import 'package:stuwrite_user/features/onboarding/domain/services/onboarding_service_interface.dart';

class OnBoardingService implements OnBoardingServiceInterface{
  OnBoardingRepositoryInterface onBoardingRepositoryInterface;

  OnBoardingService({required this.onBoardingRepositoryInterface});

  @override
  Future getList({int? offset = 1}) {
    return onBoardingRepositoryInterface.getList();
  }

}