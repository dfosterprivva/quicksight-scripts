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
def migrate_data_sources
  source_data_sources = @source_client.list_data_sources({ aws_account_id: SOURCE_AWS_ACCOUNT_ID })

  source_data_sources[:data_sources].each do |source|
    puts "creating #{source.name} with ID: #{source.data_source_id}"
    puts "\n"

    # initiate connection to target
    @target_client = Aws::QuickSight::Client.new(
      region: AWS_REGION,
      access_key_id: TARGET_AWS_ACCESS_KEY_ID,
      secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY
    )

    #create data source
    resp = @target_client.create_data_source({
      aws_account_id: TARGET_AWS_ACCOUNT_ID,
      data_source_id: source.data_source_id,
      name: source.name,
      type: source.type,
      data_source_parameters: {
        rds_parameters: {
          instance_id: TARGET_RDS_INSTANCE_ID,
          database: TARGET_RDS_DB_NAME,
        },
      },
      credentials: {
        credential_pair: {
          username: TARGET_RDS_USER,
          password: TARGET_RDS_PWD,
        },
      },
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
end

migrate_data_sources
