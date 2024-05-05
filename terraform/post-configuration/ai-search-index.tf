locals {
  index_json = {
    "name" = "documents",
    "fields" = [
      {
        "name"       = "id",
        "type"       = "Edm.String",
        "key"        = true,
        "searchable" = true,
        "analyzer"   = "keyword"
      },
      {
        "name"       = "chunkID",
        "type"       = "Edm.String",
        "key"        = false,
        "searchable" = true
      },
      {
        "name"       = "chunk",
        "type"       = "Edm.String",
        "key"        = false,
        "searchable" = true,
        "analyzer"   = "standard.lucene",
      },
      {
        "name"       = "title",
        "type"       = "Edm.String",
        "key"        = false,
        "searchable" = true,
        "analyzer"   = "standard.lucene",
      },
      {
        "name"       = "filepath",
        "type"       = "Edm.String",
        "key"        = false,
        "searchable" = false
      },
      {
        "name"       = "metadata_storage_size",
        "type"       = "Edm.Int64",
        "key"        = false,
        "searchable" = false
      },
      {
        "name"       = "metadata_storage_content_type",
        "type"       = "Edm.String",
        "key"        = false,
        "searchable" = true
      },
      {
        "name"                = "vector",
        "type"                = "Collection(Edm.Single)",
        "key"                 = false,
        "searchable"          = true,
        "dimensions"          = 1536,
        "vectorSearchProfile" = "hnsw-profile"
      }
    ],
    "vectorSearch" = {
      "algorithms" = [
        {
          "kind" = "hnsw",
          "hnswParameters" = {
            "m"              = 4,
            "efConstruction" = 400,
            "metric"         = "cosine",
            "efSearch"       = 500
          },
          "name" = "hnsw-config"
        },
        {
          "kind" = "exhaustiveKnn",
          "exhaustiveKnnParameters" = {
            "metric" = "cosine"
          },
          "name" = "exhaustiveknn-config"
        }
      ],
      "profiles" = [
        {
          "algorithm" = "hnsw-config",
          "name"      = "hnsw-profile"
        },
        {
          "algorithm" = "exhaustiveknn-config",
          "name"      = "exhaustiveknn-profile"
        }
      ]
    },
    "semantic" = {
      "configurations" = [
        {
          "name" = "semantic-configuration",
          "prioritizedFields" = {
            "prioritizedContentFields" = [
              {
                "fieldName" = "chunk"
              }
            ],
            "prioritizedKeywordsFields" = [
              {
                "fieldName" = "filepath"
              }
            ],
            "titleField" = {
              "fieldName" = "title"
            }
          }
        }
      ]
    }
  }
  data_source_json = {
    "name" = "documents-source",
    "type" = "azureblob",
    "credentials" = {
      "connectionString" = "ResourceId=${data.azurerm_storage_account.storage_account.id}"
    },
    "container" = {
      "name"  = "${var.storage.container_name}",
      "query" = null
    },
    "dataChangeDetectionPolicy" = {
      "@odata.type"             = "#Microsoft.Azure.Search.HighWaterMarkChangeDetectionPolicy",
      "highWaterMarkColumnName" = "metadata_storage_last_modified"
    },
    "dataDeletionDetectionPolicy" = null,
    "encryptionKey"               = null
  }
  skillset_json = {
    "name" = "crack-chunk-embedd",
    "skills" = [
      {
        "@odata.type"         = "#Microsoft.Skills.Text.SplitSkill",
        "name"                = "split-skill",
        "context"             = "/document/content",
        "defaultLanguageCode" = "en",
        "textSplitMode"       = "pages",
        "maximumPageLength"   = 400,
        "pageOverlapLength"   = 75,
        "maximumPagesToTake"  = 0,
        "inputs" = [
          {
            "name"   = "text",
            "source" = "/document/content"
          }
        ],
        "outputs" = [
          {
            "name"       = "textItems",
            "targetName" = "pages"
          }
        ]
      },
      {
        "@odata.type"  = "#Microsoft.Skills.Text.AzureOpenAIEmbeddingSkill",
        "name"         = "embedding-skill",
        "context"      = "/document/content/pages/*",
        "resourceUri"  = "${data.azurerm_cognitive_account.open_ai.endpoint}",
        "deploymentId" = "ada_2",
        "authIdentity" = null,
        "apiKey"       = null,
        "inputs" = [
          {
            "name"   = "text",
            "source" = "/document/content/pages/*"
          }
        ],
        "outputs" = [
          {
            "name"       = "embedding",
            "targetName" = "embedding"
          }
        ]
      }
    ],
    "cognitiveServices" = {
      "@odata.type" = "#Microsoft.Azure.Search.DefaultCognitiveServices",
      "description" = null
    },
    "indexProjections" = {
      "selectors" = [
        {
          "targetIndexName"    = "documents",
          "parentKeyFieldName" = "chunkID",
          "sourceContext"      = "/document/content/pages/*",
          "mappings" = [
            {
              "name"          = "chunk",
              "source"        = "/document/content/pages/*",
              "sourceContext" = null,
              "inputs"        = []
            },
            {
              "name"          = "vector",
              "source"        = "/document/content/pages/*/embedding",
              "sourceContext" = null,
              "inputs"        = []
            },
            {
              "name"          = "title",
              "source"        = "/document/metadata_storage_name",
              "sourceContext" = null,
              "inputs"        = []
            },
            {
              "name"          = "filepath",
              "source"        = "/document/DocRefUri",
              "sourceContext" = null,
              "inputs"        = []
            },
            {
              "name"          = "metadata_storage_content_type",
              "source"        = "/document/metadata_storage_content_type",
              "sourceContext" = null,
              "inputs"        = []
            },
            {
              "name"          = "metadata_storage_size",
              "source"        = "/document/metadata_storage_size",
              "sourceContext" = null,
              "inputs"        = []
            }
          ]
        }
      ],
      "parameters" = {
        "projectionMode" = "skipIndexingParentDocuments"
      }
    }
  }
  indexer_json = {
    "name"            = "indexer",
    "dataSourceName"  = "documents-source",
    "skillsetName"    = "crack-chunk-embedd",
    "targetIndexName" = "documents",
    "parameters" = {
      "configuration" = {
        "executionEnvironment" = "private"
      }
    }
  }
}
