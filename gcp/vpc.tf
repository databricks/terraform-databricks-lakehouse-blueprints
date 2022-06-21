module "vpc" {
   source  = "terraform-google-modules/network/google"
   version = "~> 4.0"
   project_id   = var.project_id
   network_name = "example-vpc"
   routing_mode = "GLOBAL"
   auto_create_subnetworks=false

   subnets = [
       {
           subnet_name           = "subnet-primary"
           subnet_ip             = "10.10.10.0/24"
           subnet_region         = "${var.region}"
           subnet_private_access = "true"
       }
   ]

   secondary_ranges = {
       subnet-pods = [
           {
               range_name    = "subnet-01-secondary-01"
               ip_cidr_range = "192.168.64.0/23"
           }
       ]

       subnet-services = [
       {
               range_name    = "subnet-01-secondary-02"
               ip_cidr_range = "192.168.64.0/25"
           }
           ]
   }
}
