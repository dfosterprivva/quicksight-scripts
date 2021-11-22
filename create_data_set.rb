#!/usr/bin/env ruby

require 'aws-sdk-quicksight'
require './variables.rb'

#BEGIN source stuff for dev
################################################################################
# initiate connection to source
@source_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: SOURCE_AWS_ACCESS_KEY_ID,
  secret_access_key: SOURCE_AWS_SECRET_ACCESS_KEY
)


dataset_details = @source_client.describe_data_set({
  aws_account_id: SOURCE_AWS_ACCOUNT_ID,
  data_set_id: "76ea2665-6a40-44f0-ad93-db8f3cbdbfd9"
})

dataset_details.data_set.arn = "arn:aws:quicksight:us-east-1:#{TARGET_AWS_ACCOUNT_ID}:dataset/#{dataset_details.data_set.data_set_id}"
#discuss if need iteration for multiple physical tables
physical_table_id = dataset_details.data_set.physical_table_map.keys[0].to_s
#check table type and create source accordingly 
if dataset_details.data_set.physical_table_map["#{physical_table_id}"][:s3_source] != nil
  target_data_source_arn = dataset_details.data_set.physical_table_map["#{physical_table_id}"].s3_source.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
  dataset_details.data_set.physical_table_map["#{physical_table_id}"].s3_source.data_source_arn = target_data_source_arn

elsif dataset_details.data_set.physical_table_map["#{physical_table_id}"][:relational_table] != nil
  target_data_source_arn = dataset_details.data_set.physical_table_map["#{physical_table_id}"].relational_table.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
  dataset_details.data_set.physical_table_map["#{physical_table_id}"].relational_table.data_source_arn = target_data_source_arn

elsif dataset_details.data_set.physical_table_map["#{physical_table_id}"][:custom_sql] != nil
  target_data_source_arn = dataset_details.data_set.physical_table_map["#{physical_table_id}"].custom_sql.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
  dataset_details.data_set.physical_table_map["#{physical_table_id}"].custom_sql.data_source_arn = target_data_source_arn
end
################################################################################
#END source stuff for dev

#scoped params
#DATA_SET_ID = ''
#RESOURCE_NAME  = ''

# initiate connection to target
@target_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: TARGET_AWS_ACCESS_KEY_ID,
  secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY
)


resp = @target_client.create_data_set({
  aws_account_id: TARGET_AWS_ACCOUNT_ID,
  data_set_id: dataset_details.data_set.data_set_id,
  name: dataset_details.data_set.name,
  physical_table_map: dataset_details.data_set.physical_table_map,
  logical_table_map: dataset_details.data_set.logical_table_map,
  import_mode: dataset_details.data_set.import_mode,
  #column_groups: dataset_details.data_set.column_groups,
  permissions: [
    {
      principal: TARGET_PRINCIPAL_USER_ARN,
      actions: [
        "quicksight:UpdateDataSetPermissions",
        "quicksight:DescribeDataSet",
        "quicksight:DescribeDataSetPermissions",
        "quicksight:PassDataSet",
        "quicksight:DescribeIngestion",
        "quicksight:ListIngestions",
        "quicksight:UpdateDataSet",
        "quicksight:DeleteDataSet",
        "quicksight:CreateIngestion",
        "quicksight:CancelIngestion"
      ]
    },
  ],
  row_level_permission_data_set: dataset_details.data_set.row_level_permission_data_set,
  row_level_permission_tag_configuration: dataset_details.data_set.row_level_permission_tag_configuration,
  column_level_permission_rules: dataset_details.data_set.column_level_permission_rules,
  tags: [
    {
      key: "Name", # required
      value: dataset_details.data_set.name, # required
    },
  ],
  data_set_usage_configuration: dataset_details.data_set.data_set_usage_configuration,
})

