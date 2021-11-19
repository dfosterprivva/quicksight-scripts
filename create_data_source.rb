#!/usr/bin/env ruby

require './variables.rb'

resp = client.create_data_source({
  aws_account_id: "AwsAccountId", # required
  data_source_id: "ResourceId", # required
  name: "ResourceName", # required
  type: "ADOBE_ANALYTICS", # required, accepts ADOBE_ANALYTICS, AMAZON_ELASTICSEARCH, ATHENA, AURORA, AURORA_POSTGRESQL, AWS_IOT_ANALYTICS, GITHUB, JIRA, MARIADB, MYSQL, ORACLE, POSTGRESQL, PRESTO, REDSHIFT, S3, SALESFORCE, SERVICENOW, SNOWFLAKE, SPARK, SQLSERVER, TERADATA, TWITTER, TIMESTREAM, AMAZON_OPENSEARCH
  data_source_parameters: {
    amazon_elasticsearch_parameters: {
      domain: "Domain", # required
    },
    athena_parameters: {
      work_group: "WorkGroup",
    },
    aurora_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    aurora_postgre_sql_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    aws_iot_analytics_parameters: {
      data_set_name: "DataSetName", # required
    },
    jira_parameters: {
      site_base_url: "SiteBaseUrl", # required
    },
    maria_db_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    my_sql_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    oracle_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    postgre_sql_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    presto_parameters: {
      host: "Host", # required
      port: 1, # required
      catalog: "Catalog", # required
    },
    rds_parameters: {
      instance_id: "InstanceId", # required
      database: "Database", # required
    },
    redshift_parameters: {
      host: "Host",
      port: 1,
      database: "Database", # required
      cluster_id: "ClusterId",
    },
    s3_parameters: {
      manifest_file_location: { # required
        bucket: "S3Bucket", # required
        key: "S3Key", # required
      },
    },
    service_now_parameters: {
      site_base_url: "SiteBaseUrl", # required
    },
    snowflake_parameters: {
      host: "Host", # required
      database: "Database", # required
      warehouse: "Warehouse", # required
    },
    spark_parameters: {
      host: "Host", # required
      port: 1, # required
    },
    sql_server_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    teradata_parameters: {
      host: "Host", # required
      port: 1, # required
      database: "Database", # required
    },
    twitter_parameters: {
      query: "Query", # required
      max_rows: 1, # required
    },
    amazon_open_search_parameters: {
      domain: "Domain", # required
    },
  },
  credentials: {
    credential_pair: {
      username: "Username", # required
      password: "Password", # required
      alternate_data_source_parameters: [
        {
          amazon_elasticsearch_parameters: {
            domain: "Domain", # required
          },
          athena_parameters: {
            work_group: "WorkGroup",
          },
          aurora_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          aurora_postgre_sql_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          aws_iot_analytics_parameters: {
            data_set_name: "DataSetName", # required
          },
          jira_parameters: {
            site_base_url: "SiteBaseUrl", # required
          },
          maria_db_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          my_sql_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          oracle_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          postgre_sql_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          presto_parameters: {
            host: "Host", # required
            port: 1, # required
            catalog: "Catalog", # required
          },
          rds_parameters: {
            instance_id: "InstanceId", # required
            database: "Database", # required
          },
          redshift_parameters: {
            host: "Host",
            port: 1,
            database: "Database", # required
            cluster_id: "ClusterId",
          },
          s3_parameters: {
            manifest_file_location: { # required
              bucket: "S3Bucket", # required
              key: "S3Key", # required
            },
          },
          service_now_parameters: {
            site_base_url: "SiteBaseUrl", # required
          },
          snowflake_parameters: {
            host: "Host", # required
            database: "Database", # required
            warehouse: "Warehouse", # required
          },
          spark_parameters: {
            host: "Host", # required
            port: 1, # required
          },
          sql_server_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          teradata_parameters: {
            host: "Host", # required
            port: 1, # required
            database: "Database", # required
          },
          twitter_parameters: {
            query: "Query", # required
            max_rows: 1, # required
          },
          amazon_open_search_parameters: {
            domain: "Domain", # required
          },
        },
      ],
    },
    copy_source_arn: "CopySourceArn",
  },
  permissions: [
    {
      principal: "Principal", # required
      actions: ["String"], # required
    },
  ],
  vpc_connection_properties: {
    vpc_connection_arn: "Arn", # required
  },
  ssl_properties: {
    disable_ssl: false,
  },
  tags: [
    {
      key: "TagKey", # required
      value: "TagValue", # required
    },
  ],
})
