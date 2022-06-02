resource "google_access_context_manager_access_policy" "access-policy" {
  parent = "organizations/123456789"
  title  = "Org Access Policy"
}

resource "google_access_context_manager_service_perimeters" "secure-data-exchange" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"

  service_perimeters {
    name   = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/servicePerimeters/"
    title  = ""
    status {
      restricted_services = ["storage.googleapis.com"]
    }
  }

  service_perimeters {
    name   = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/servicePerimeters/"
    title  = ""
    status {
      restricted_services = ["bigtable.googleapis.com"]
              vpcAccessibleServices = {
            enableRestriction = true
            allowedServices = ["bigquery.googleapis.com"]
        }
    }
  }
}

resource "google_access_context_manager_access_level" "access-level" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/accessLevels/secure_data_exchange"
  title  = "secure_data_exchange"
  basic {
    conditions {
      device_policy {
        require_screen_lock = false
        os_constraints {
          os_type = "DESKTOP_CHROME_OS"
        }
      }
      regions = [
        "CH",
        "IT",
        "US",
      ]
    }
  }
}



resource "google_access_context_manager_service_perimeter" "test-access" {
  parent         = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"
  name           = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/servicePerimeters/%s"
  title          = "%s"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  status {
    restricted_services = ["bigquery.googleapis.com", "storage.googleapis.com"]
        access_levels       = [google_access_context_manager_access_level.access-level.name]

        vpc_accessible_services {
            enable_restriction = true
            allowed_services   = ["bigquery.googleapis.com", "storage.googleapis.com"]
        }

        ingress_policies {
            ingress_from {
                sources {
                    access_level = google_access_context_manager_access_level.access-level.name
                }
                identity_type = "ANY_SERVICE_ACCOUNT"
            }

            ingress_to {
                resources = [ "projects/872269723794" ]
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
                identity_type = "user:${var.databricks_google_service_account}"
            }
          egress_to {
            resources = [ "projects/68422481410", #databricks central service
    "projects/643670579914", #databricks runtime artifact
    "projects/121886670913"], #databricks regional control plane
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