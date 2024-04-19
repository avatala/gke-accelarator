<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associated this project with | `string` | n/a | yes |
| enable\_hub\_and\_spoke | Enable Hub-and-Spoke architecture. | `bool` | `false` | no |
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"sec"` | no |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| parent\_folder |  It will place all the customer foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `"779126107996"` | no |
| project\_prefix | Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters. | `string` | `"sec"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | `string` | n/a | yes |
| shared\_project\_id | Shared network project Id |`string` | `"sec-s-shared-prj-37e7"` | no |
| vpc\_network\_name | production shared vpc network name | `string` | `"sec-core-p-shared-base-gbl-vpc-01"` | no |
| central\_monitoring\_project | central monitoring project ID | `string` | `"sec-s-monitoring-prj-3302"` | no |
| business_unit | Name of the customer business unit | `string` | `"business_unit_1"` | no |
## Outputs

| Name | Description |
|------|-------------|
| business\_unit\_folder_id | business unit customer folder id |
| base\_shared\_vpc\_project | Project sample base project. |
| base\_shared\_vpc\_project\_sa | Project sample base project SA. |
| bucket | The created storage bucket |
| env\_secrets\_project | Project sample peering project id. |
| keyring | The name of the keyring. |
| keys | List of created key names. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
