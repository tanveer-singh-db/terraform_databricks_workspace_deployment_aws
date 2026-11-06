variable "config" {
  type = object({
    warehouses = list(object({
      name             = string
      cluster_size     = string
      min_num_clusters = number
      max_num_clusters = number
      auto_stop_mins   = number
      tags             = optional(map(string), {})
    }))
  })
}
