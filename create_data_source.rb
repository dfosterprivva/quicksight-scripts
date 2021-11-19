#!/usr/bin/env ruby

require 'aws-sdk-quicksight'
require './variables.rb'

#scoped params
DATA_SOURCE_ID=''
RESOURCE_NAME=''
TYPE='POSTGRESQL'


# initiate connection to target
@target_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: TARGET_AWS_ACCESS_KEY_ID,
  secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY
)

resp = @target_client.create_data_source({
  aws_account_id: TARGET_AWS_ACCOUNT_ID,
  data_source_id: DATA_SOURCE_ID,
  name: RESOURCE_NAME,
  type: TYPE,
  data_source_parameters: {
    #postgre_sql_parameters: {
      #host: TARGET_RDS_HOSTNAME,
      #port: TARGET_RDS_PORT,
      #database: TARGET_RDS_DB_NAME,
    #},
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
    # don't think we need this
#    copy_source_arn: "CopySourceArn",
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
      value: RESOURCE_NAME, # required
    },
  ],
})
