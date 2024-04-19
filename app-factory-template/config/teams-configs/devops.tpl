# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the Licencatcatcat
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#This file configures who will have access(and what kind of access) to the team and what repos will the team have access to
#This is a sample template, update/add/delete the files based on your needs

#######################
##### parent team #####
#######################
parent_team=Engineering

#################################
##### user role on the team #####
#################################
maintainers=["user1"]
members=["user1","user2"]

#################################################
##### repo that the team has permissions on #####
#################################################
admin_repositories=["app-template-java"]
maintain_repositories=["app-template-java"]
push_repositories=["app-template-java"]
triage_repositories=["app-template-java"]
pull_repositories=["app-template-golang"]

############################
##### privacy settings #####
############################
privacy=closed
