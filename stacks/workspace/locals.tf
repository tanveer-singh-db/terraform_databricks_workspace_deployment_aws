locals {
  config_dir = "${path.module}/${var.config_root}/${var.environment}/${var.region}/${var.workspace}"
  yaml_files = sort(tolist(fileset(local.config_dir, "*.yml")))
  documents  = { for name in local.yaml_files : name => yamldecode(file("${local.config_dir}/${name}")) }
  yaml_keys  = flatten([for document in values(local.documents) : keys(document)])
  duplicate_keys = [
    for key in distinct(local.yaml_keys) : key
    if length([for candidate in local.yaml_keys : candidate if candidate == key]) > 1
  ]
  config = merge(values(local.documents)...)
}
