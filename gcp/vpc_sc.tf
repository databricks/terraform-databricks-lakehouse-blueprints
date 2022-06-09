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



resource "google_access_context_manager_service_perimeter" "test-access" {
  provider = google.service_perimeter_sa
  parent         = "accessPolicies/733405850987"
  name           = "accessPolicies/733405850987/servicePerimeters/fslakehousesp"
  title          = "mytitle"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  status {
    restricted_services = ["bigquery.googleapis.com", "storage.googleapis.com"]
        access_levels       = ["accessPolicies/733405850987/accessLevels/fslakehouse_access"]

        vpc_accessible_services {
            enable_restriction = true
            allowed_services   = ["bigquery.googleapis.com", "storage.googleapis.com"]
        }

        ingress_policies {
            ingress_from {
                sources {
                    access_level = "accessPolicies/733405850987/accessLevels/fslakehouse_access"
                }
                identity_type = "ANY_SERVICE_ACCOUNT"
            }

            ingress_to {
                resources = [ "projects/${var.project_id}" ]
                operations {
                    service_name = "container.googleapis.com"

                    method_selectors {
                        method = "google.storage.buckets.create"
                    }

                    method_selectors {
                        method = "google.storage.buckets.testIamPermissions"
                    }
                }

                operations {
                    service_name = "container.googleapis.com"

                    method_selectors {
                        method = "*"
                    }
                }
              operations {
                    service_name = "compute.googleapis.com"

                    method_selectors {
                        method = "NetworksService.Insert"
                    }
                 method_selectors {
                        method = "RegionOperationsService.Get"
                    }
                 method_selectors {
                        method = "GlobalOperationsService.Get"
                    }
                 method_selectors {
                        method = "RegionRoutersService.Insert"
                    }
                method_selectors {
                        method = "SubnetworksService.Insert"
                    }
                method_selectors {
                        method = "ZonesService.List"
                    }
                }
            }
        }

        egress_policies {
            egress_from {
                identity_type = "ANY_SERVICE_ACCOUNT"
            }
          egress_to {
            resources = [ "projects/68422481410", #databricks central service
    "projects/643670579914", #databricks runtime artifact
    "projects/121886670913"] #databricks regional control plane
             operations {
                    service_name = "storage.googleapis.com"

                    method_selectors {
                        method = "google.storage.objects.list"
                    }

                    method_selectors {
                        method = "google.storage.buckets.testIamPermissions"
                    }
               method_selectors {
                        method = "google.storage.objects.get"
                    }
               method_selectors {
                        method = "google.storage.objects.create"
                    }
                }
            operations {
                    service_name = "containerregistry.googleapis.com"

                    method_selectors {
                        method = "containers.registry.read"
                    }
                }
          }
        }
  }
}