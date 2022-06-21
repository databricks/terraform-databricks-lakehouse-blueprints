resource "google_compute_router" "router" {
  name    = "${var.google_project}-router"
  project = var.project_id
  region  = var.region
  network = module.vpc.network_name
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.google_project}-nat"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}