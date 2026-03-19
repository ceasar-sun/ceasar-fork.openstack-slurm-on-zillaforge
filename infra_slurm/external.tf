# --------------------------------------------------------------------------
# External scripts — runs during terraform plan/apply on the local machine
# --------------------------------------------------------------------------

module "check_deps" {
  source = "../modules/check_deps"
}
