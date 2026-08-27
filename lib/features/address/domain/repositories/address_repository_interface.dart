
import 'package:stuwrite_user/features/address/domain/models/address_model.dart';
import 'package:stuwrite_user/features/address/domain/models/label_model.dart';
import 'package:stuwrite_user/interface/repo_interface.dart';

abstract class AddressRepoInterface<T> implements RepositoryInterface<AddressModel>{

  List<LabelAsModel> getAddressType();

  Future<dynamic> getDeliveryRestrictedCountryList();

  Future<dynamic> getDeliveryRestrictedZipList();

  Future<dynamic> getDeliveryRestrictedZipBySearch(String zipcode);

  Future<dynamic> getDeliveryRestrictedCountryBySearch(String country);


}