import 'package:greenplayapp/redux/model/BranchOrganisationResponse.dart';
import 'package:greenplayapp/redux/model/OrganisationResponse.dart';

class OrganisationAction{
  OrganisationAction();
}


class OrganisationResponseAction{
  OrganisationResponse organisationResponse;

  OrganisationResponseAction(this.organisationResponse);
}
class BranchOrganisationAction{
  String organisationId;
  BranchOrganisationAction(this.organisationId);
}


class BranchOrganisationResponseAction{
  BranchOrganisationResponse branchOrganisationResponse;

  BranchOrganisationResponseAction(this.branchOrganisationResponse);
}