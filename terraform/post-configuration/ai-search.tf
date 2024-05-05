resource "restapi_object" "create_index" {
  path         = "/indexes"
  query_string = "api-version=${var.ai_search.api_version}"
  data         = jsonencode(local.index_json)
  debug        = true
  id_attribute = "name"

  lifecycle {
    ignore_changes = [data, query_string]
  }
}

resource "restapi_object" "create_data_source" {
  path         = "/datasources"
  query_string = "api-version=${var.ai_search.api_version}"
  data         = jsonencode(local.data_source_json)
  debug        = true
  id_attribute = "name"

  lifecycle {
    ignore_changes = [data, query_string]
  }
}

resource "restapi_object" "create_skillset" {
  path         = "/skillsets"
  query_string = "api-version=${var.ai_search.api_version}"
  data         = jsonencode(local.skillset_json)
  debug        = true
  id_attribute = "name"

  depends_on = [restapi_object.create_index]

  lifecycle {
    ignore_changes = [data, query_string]
  }
}

resource "restapi_object" "create_indexer" {
  path         = "/indexers"
  query_string = "api-version=${var.ai_search.api_version}"
  data         = jsonencode(local.indexer_json)
  debug        = true
  id_attribute = "name"

  depends_on = [restapi_object.create_data_source, restapi_object.create_index, restapi_object.create_skillset]

  lifecycle {
    ignore_changes = [data, query_string]
  }
}
