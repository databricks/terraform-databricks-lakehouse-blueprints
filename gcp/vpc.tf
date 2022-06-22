resource "google_compute_address" "gc_address_fsl" {
    name = "gc-address-fsl"
    region = var.region
   }

resource "google_compute_network" "gc_network_fsl" {
auto_create_subnetworks = false
description = "VPC creation"
name= "vpc-standalone-fsl"
}

resource "google_compute_router" "gc_router_fsl" {
    name = "gc-router-fsl"
    network = google_compute_network.gc_network_fsl.id
    region = var.region
    }

resource "google_compute_router_nat" "gc_router_nat_fsl" {
    name = "gc-router-nat-fsl"
    nat_ip_allocate_option             = "AUTO_ONLY"
    #nat_ip_allocate_option = "MANUAL_ONLY"
    #nat_ips = "${google_compute_address.gc_address_fsl.self_link}"
    region = var.region
    router = google_compute_router.gc_router_fsl.name
    source_subnetwork_ip_ranges_to_nat =  "ALL_SUBNETWORKS_ALL_IP_RANGES"
    depends_on=[google_compute_address.gc_address_fsl]
}

resource "google_compute_subnetwork" "gc_subnet_fsl" {
    ip_cidr_range = "10.0.0.0/16"
    name = "gc-subnet-fsl"
    network = google_compute_network.gc_network_fsl.id
    region = var.region
    secondary_ip_range {
    ip_cidr_range = "10.1.0.0/16"
    range_name = "pod"
    }
    secondary_ip_range {
    ip_cidr_range =  "10.2.0.0/20"
    range_name = "svc"
    }
    }