#resource "google_access_context_manager_access_policy" "access-policy" {
#  parent = "organizations/91726329394"
#  title  = "Org Access Policy"
#  scopes=["projects/fslakehouse"]
#}

#resource "google_access_context_manager_service_perimeters" "secure-data-exchange" {
#  parent = "accessPolicies/733405850987/accessLevels/fslakehouse_access"

  #service_perimeters {
  #  name   = "accessPolicies/fs_lakehouse_ap/servicePerimeters/"
  #  title  = ""
  #  status {
  #    restricted_services = ["storage.googleapis.com"]
  #  }
  #}

  #service_perimeters {
  #  name   = "accessPolicies/fs_lakehouse_ap/servicePerimeters/"
  #  title  = ""
  #  status {
   #   restricted_services = ["bigtable.googleapis.com"]
   # }
 # }
#}

#resource "google_access_context_manager_access_level" "access-level" {
#  parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"
#  name   = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/accessLevels/secure_data_exchange"
#  title  = "secure_data_exchange"
#  basic {
#    conditions {
#      device_policy {
#        require_screen_lock = false
#        os_constraints {
#          os_type = "DESKTOP_CHROME_OS"
###        }
  #    }
  #    regions = [
  #      "CH",
  #      "IT",
  #      "US",
  #    ]
  #  }
 # }
#}