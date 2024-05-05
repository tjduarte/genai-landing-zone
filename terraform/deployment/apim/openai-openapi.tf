locals {
  api_schema = {
    "openapi" = "3.0.0",
    "info" = {
      "title"       = "Azure OpenAI Service API",
      "description" = "Azure OpenAI APIs for completions and search",
      "version"     = "2023-05-15"
    },
    "servers" = [for openai_uri in var.openai_uris : {
      url = "${openai_uri}openai"
      variables = {
        endpoint = {
          default = replace(replace(openai_uri, "https://", ""), "/", "")
        }
      }
    }],
    "security" = [
      {
        "bearer" = [
          "api.read"
        ]
      },
      {
        "apiKey" = []
      }
    ],
    "paths" = {
      "/deployments/ada_2/embeddings" = {
        "post" = {
          "summary"     = "Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.",
          "operationId" = "embeddings_create",
          "parameters" = [
            {
              "in"       = "query",
              "name"     = "api-version",
              "required" = true,
              "schema" = {
                "type"        = "string",
                "example"     = "2023-05-15",
                "description" = "api version"
              }
            }
          ],
          "requestBody" = {
            "required" = true,
            "content" = {
              "application/json" = {
                "schema" = {
                  "type"                 = "object",
                  "additionalProperties" = true,
                  "properties" = {
                    "input" = {
                      "description" = "Input text to get embeddings for, encoded as a string. To get embeddings for multiple inputs in a single request, pass an array of strings. Each input must not exceed 2048 tokens in length.\nUnless you are embedding code, we suggest replacing newlines (\\n) in your input with a single space, as we have observed inferior results when newlines are present.",
                      "oneOf" = [
                        {
                          "type"     = "string",
                          "default"  = "",
                          "example"  = "This is a test.",
                          "nullable" = true
                        },
                        {
                          "type"     = "array",
                          "minItems" = 1,
                          "maxItems" = 2048,
                          "items" = {
                            "type"      = "string",
                            "minLength" = 1,
                            "example"   = "This is a test.",
                            "nullable"  = false
                          }
                        }
                      ]
                    },
                    "user" = {
                      "description" = "A unique identifier representing your end-user, which can help monitoring and detecting abuse.",
                      "type"        = "string",
                      "nullable"    = false
                    },
                    "input_type" = {
                      "description" = "input type of embedding search to use",
                      "type"        = "string",
                      "example"     = "query"
                    },
                    "model" = {
                      "type"        = "string",
                      "description" = "ID of the model to use. You can use the Models_List operation to see all of your available models, or see our Models_Get overview for descriptions of them.",
                      "nullable"    = false
                    }
                  },
                  "required" = [
                    "input"
                  ]
                }
              }
            }
          },
          "responses" = {
            "200" = {
              "description" = "OK",
              "content" = {
                "application/json" = {
                  "schema" = {
                    "type" = "object",
                    "properties" = {
                      "object" = {
                        "type" = "string"
                      },
                      "model" = {
                        "type" = "string"
                      },
                      "data" = {
                        "type" = "array",
                        "items" = {
                          "type" = "object",
                          "properties" = {
                            "index" = {
                              "type" = "integer"
                            },
                            "object" = {
                              "type" = "string"
                            },
                            "embedding" = {
                              "type" = "array",
                              "items" = {
                                "type" = "number"
                              }
                            }
                          },
                          "required" = [
                            "index",
                            "object",
                            "embedding"
                          ]
                        }
                      },
                      "usage" = {
                        "type" = "object",
                        "properties" = {
                          "prompt_tokens" = {
                            "type" = "integer"
                          },
                          "total_tokens" = {
                            "type" = "integer"
                          }
                        },
                        "required" = [
                          "prompt_tokens",
                          "total_tokens"
                        ]
                      }
                    },
                    "required" = [
                      "object",
                      "model",
                      "data",
                      "usage"
                    ]
                  }
                }
              }
            }
          }
        }
      },
      "/deployments/gpt_4_turbo/chat/completions" = {
        "post" = {
          "summary"     = "Creates a completion for the chat message",
          "operationId" = "ChatCompletions_Create",
          "parameters" = [
            {
              "in"       = "query",
              "name"     = "api-version",
              "required" = true,
              "schema" = {
                "type"        = "string",
                "example"     = "2023-05-15",
                "description" = "api version"
              }
            }
          ],
          "requestBody" = {
            "required" = true,
            "content" = {
              "application/json" = {
                "schema" = {
                  "type" = "object",
                  "properties" = {
                    "messages" = {
                      "description" = "The messages to generate chat completions for, in the chat format.",
                      "type"        = "array",
                      "minItems"    = 1,
                      "items" = {
                        "type" = "object",
                        "properties" = {
                          "role" = {
                            "type" = "string",
                            "enum" = [
                              "system",
                              "user",
                              "assistant"
                            ],
                            "description" = "The role of the author of this message."
                          },
                          "content" = {
                            "type"        = "string",
                            "description" = "The contents of the message"
                          },
                          "name" = {
                            "type"        = "string",
                            "description" = "The name of the user in a multi-user chat"
                          }
                        },
                        "required" = [
                          "role",
                          "content"
                        ]
                      }
                    },
                    "temperature" = {
                      "description" = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.\nWe generally recommend altering this or `top_p` but not both.",
                      "type"        = "number",
                      "minimum"     = 0,
                      "maximum"     = 2,
                      "default"     = 1,
                      "example"     = 1,
                      "nullable"    = true
                    },
                    "top_p" = {
                      "description" = "An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.\nWe generally recommend altering this or `temperature` but not both.",
                      "type"        = "number",
                      "minimum"     = 0,
                      "maximum"     = 1,
                      "default"     = 1,
                      "example"     = 1,
                      "nullable"    = true
                    },
                    "n" = {
                      "description" = "How many chat completion choices to generate for each input message.",
                      "type"        = "integer",
                      "minimum"     = 1,
                      "maximum"     = 128,
                      "default"     = 1,
                      "example"     = 1,
                      "nullable"    = true
                    },
                    "stream" = {
                      "description" = "If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only server-sent events as they become available, with the stream terminated by a `data: [DONE]` message.",
                      "type"        = "boolean",
                      "nullable"    = true,
                      "default"     = false
                    },
                    "stop" = {
                      "description" = "Up to 4 sequences where the API will stop generating further tokens.",
                      "oneOf" = [
                        {
                          "type"     = "string",
                          "nullable" = true
                        },
                        {
                          "type" = "array",
                          "items" = {
                            "type"     = "string",
                            "nullable" = false
                          },
                          "minItems"    = 1,
                          "maxItems"    = 4,
                          "description" = "Array minimum size of 1 and maximum of 4"
                        }
                      ],
                      "default" = null
                    },
                    "max_tokens" = {
                      "description" = "The maximum number of tokens allowed for the generated answer. By default, the number of tokens the model can return will be (4096 - prompt tokens).",
                      "type"        = "integer",
                      "default"     = "inf"
                    },
                    "presence_penalty" = {
                      "description" = "Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.",
                      "type"        = "number",
                      "default"     = 0,
                      "minimum"     = -2,
                      "maximum"     = 2
                    },
                    "frequency_penalty" = {
                      "description" = "Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.",
                      "type"        = "number",
                      "default"     = 0,
                      "minimum"     = -2,
                      "maximum"     = 2
                    },
                    "logit_bias" = {
                      "description" = "Modify the likelihood of specified tokens appearing in the completion. Accepts a json object that maps tokens (specified by their token ID in the tokenizer) to an associated bias value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.",
                      "type"        = "object",
                      "nullable"    = true
                    },
                    "user" = {
                      "description" = "A unique identifier representing your end-user, which can help Azure OpenAI to monitor and detect abuse.",
                      "type"        = "string",
                      "example"     = "user-1234",
                      "nullable"    = false
                    }
                  },
                  "required" = [
                    "messages"
                  ]
                },
                "example" = {
                  "model" = "gpt-35-turbo",
                  "messages" = [
                    {
                      "role"    = "user",
                      "content" = "Hello!"
                    }
                  ]
                }
              }
            }
          },
          "responses" = {
            "200" = {
              "description" = "OK",
              "content" = {
                "application/json" = {
                  "schema" = {
                    "type" = "object",
                    "properties" = {
                      "id" = {
                        "type" = "string"
                      },
                      "object" = {
                        "type" = "string"
                      },
                      "created" = {
                        "type"   = "integer",
                        "format" = "unixtime"
                      },
                      "model" = {
                        "type" = "string"
                      },
                      "choices" = {
                        "type" = "array",
                        "items" = {
                          "type" = "object",
                          "properties" = {
                            "index" = {
                              "type" = "integer"
                            },
                            "message" = {
                              "type" = "object",
                              "properties" = {
                                "role" = {
                                  "type" = "string",
                                  "enum" = [
                                    "system",
                                    "user",
                                    "assistant"
                                  ],
                                  "description" = "The role of the author of this message."
                                },
                                "content" = {
                                  "type"        = "string",
                                  "description" = "The contents of the message"
                                }
                              },
                              "required" = [
                                "role",
                                "content"
                              ]
                            },
                            "finish_reason" = {
                              "type" = "string"
                            }
                          }
                        }
                      },
                      "usage" = {
                        "type" = "object",
                        "properties" = {
                          "prompt_tokens" = {
                            "type" = "integer"
                          },
                          "completion_tokens" = {
                            "type" = "integer"
                          },
                          "total_tokens" = {
                            "type" = "integer"
                          }
                        },
                        "required" = [
                          "prompt_tokens",
                          "completion_tokens",
                          "total_tokens"
                        ]
                      }
                    },
                    "required" = [
                      "id",
                      "object",
                      "created",
                      "model",
                      "choices"
                    ]
                  },
                  "example" = {
                    "id"      = "chatcmpl-123",
                    "object"  = "chat.completion",
                    "created" = 1677652288,
                    "choices" = [
                      {
                        "index" = 0,
                        "message" = {
                          "role"    = "assistant",
                          "content" = "\n\nHello there, how may I assist you today?"
                        },
                        "finish_reason" = "stop"
                      }
                    ],
                    "usage" = {
                      "prompt_tokens"     = 9,
                      "completion_tokens" = 12,
                      "total_tokens"      = 21
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    "components" = {
      "schemas" = {
        "errorResponse" = {
          "type" = "object",
          "properties" = {
            "error" = {
              "type" = "object",
              "properties" = {
                "code" = {
                  "type" = "string"
                },
                "message" = {
                  "type" = "string"
                },
                "param" = {
                  "type" = "string"
                },
                "type" = {
                  "type" = "string"
                }
              }
            }
          }
        }
      },
      "securitySchemes" = {
        "bearer" = {
          "type" = "oauth2",
          "flows" = {
            "implicit" = {
              "authorizationUrl" = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
              "scopes"           = {}
            }
          },
          "x-tokenInfoFunc"     = "api.middleware.auth.bearer_auth",
          "x-scopeValidateFunc" = "api.middleware.auth.validate_scopes"
        },
        "apiKey" = {
          "type" = "apiKey",
          "name" = "api-key",
          "in"   = "header"
        }
      }
    }
  }
}
