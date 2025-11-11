locals {
  # Location abbreviations for resource naming
  location_map = {
    "eastus"      = "eus"
    "eastus2"     = "eus2"
    "westus"      = "wus"
    "westus2"     = "wus2"
    "centralus"   = "cus"
    "northeurope" = "neu"
    "westeurope"  = "weu"
  }

  location_short = lookup(local.location_map, var.location, "unk")
}
