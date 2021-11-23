#!/usr/bin/env ruby

require 'aws-sdk-quicksight'
require './variables.rb'

# initiate connection to source
@source_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: SOURCE_AWS_ACCESS_KEY_ID,
  secret_access_key: SOURCE_AWS_SECRET_ACCESS_KEY
)

# initiate connection to target
@target_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: TARGET_AWS_ACCESS_KEY_ID,
  secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY
)

# data sources

def update_data_source(source)
  puts "future update code here"
end

def migrate_data_source(source)
  puts "creating #{source.name} with ID: #{source.data_source_id}"
  puts "\n"

  #build out data_source_parameters
  if source.data_source_parameters.rds_parameters != nil
    source.data_source_parameters.rds_parameters[:instance_id] = TARGET_RDS_INSTANCE_ID
    source.data_source_parameters.rds_parameters[:database] = TARGET_RDS_DB_NAME
    credential_pair_hash = { credential_pair: {username: TARGET_RDS_USER, password: TARGET_RDS_PWD }}
  else
    abort("Parameter set not built yet")
=begin
Possible params to build
amazon_elasticsearch_parameters
athena_parameters
aurora_parameters
aurora_postgre_sql_parameters
aws_iot_analytics_parameters
jira_parameters
maria_db_parameters
my_sql_parameters
oracle_parameters
postgre_sql_parameters
presto_parameters
redshift_parameters
s3_parameters
service_now_parameters
snowflake_parameters
spark_parameters
sql_server_parameters
teradata_parameters
twitter_parameters
amazon_open_search_parameters
=end
  end

  #create data source
  resp = @target_client.create_data_source({
    aws_account_id: TARGET_AWS_ACCOUNT_ID,
    data_source_id: source.data_source_id,
    name: source.name,
    type: source.type,
    data_source_parameters: source.data_source_parameters,
    credentials: credential_pair_hash,
    permissions: [
      {
        principal: TARGET_PRINCIPAL_USER_ARN,
        actions: [
          "quicksight:UpdateDataSourcePermissions",
          "quicksight:DescribeDataSource",
          "quicksight:DescribeDataSourcePermissions",
          "quicksight:PassDataSource",
          "quicksight:UpdateDataSource",
          "quicksight:DeleteDataSource"
        ]
      },
    ],
    vpc_connection_properties: {
      vpc_connection_arn: TARGET_VPC_ARN,
    },
    ssl_properties: {
      disable_ssl: false,
    },
    tags: [
      {
        key: "Name", # required
        value: source.name, # required
      },
    ],
  })
end


def check_data_source

  #gather source data sources
  source_data_sources = @source_client.list_data_sources({ aws_account_id: SOURCE_AWS_ACCOUNT_ID })

  #gather target data sources, create id list
  target_data_source_list = @target_client.list_data_sources({ aws_account_id: TARGET_AWS_ACCOUNT_ID })
  target_data_source_id_hash = {}
  target_data_source_list[:data_sources].each do |target_data_source|
    target_data_source_id_hash[target_data_source.data_source_id] = target_data_source.arn
  end

  source_data_sources[:data_sources].each do |source|
    puts "Checking #{source.name} with ID: #{source.data_source_id}"

    if target_data_source_id_hash["#{source.data_source_id}"]
      then
      puts "Data source already Exists... updating"
      puts "\n"
      # update method here
    else
      puts "Data source does NOT exist... will migrate source"
      puts "\n"
      migrate_data_source(source)
    end
  end
end

check_data_source
