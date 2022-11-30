resource "databricks_repo" "esg" {
  url = "https://github.com/databricks-industry-solutions/esg-scoring.git"
}

resource "databricks_repo" "risk" {
  url = "https://github.com/databricks-industry-solutions/value-at-risk.git"
}
