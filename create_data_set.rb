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
# data sets
def migrate_data_sets

  source_data_sources = @source_client.list_data_sources({ aws_account_id: SOURCE_AWS_ACCOUNT_ID})

  source_data_sources[:data_sources].each do |source|
    puts "#{source[:name]}"
    puts "#{source[:data_source_id]}"
    puts "\n"
    source.data_set.arn = "arn:aws:quicksight:us-east-1:#{TARGET_AWS_ACCOUNT_ID}:dataset/#{source.data_set.data_set_id}"

    #discuss if need iteration for multiple physical tables
    physical_table_id = source.data_set.physical_table_map.keys[0].to_s

    #check table type and create source accordingly 
    if source.data_set.physical_table_map["#{physical_table_id}"][:s3_source] != nil
      target_data_source_arn = source.data_set.physical_table_map["#{physical_table_id}"].s3_source.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
      source.data_set.physical_table_map["#{physical_table_id}"].s3_source.data_source_arn = target_data_source_arn

    elsif source.data_set.physical_table_map["#{physical_table_id}"][:relational_table] != nil
      target_data_source_arn = source.data_set.physical_table_map["#{physical_table_id}"].relational_table.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
      source.data_set.physical_table_map["#{physical_table_id}"].relational_table.data_source_arn = target_data_source_arn

    elsif source.data_set.physical_table_map["#{physical_table_id}"][:custom_sql] != nil
      target_data_source_arn = source.data_set.physical_table_map["#{physical_table_id}"].custom_sql.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
      source.data_set.physical_table_map["#{physical_table_id}"].custom_sql.data_source_arn = target_data_source_arn
    end


    # initiate connection to target
    @target_client = Aws::QuickSight::Client.new(
      region: AWS_REGION,
      access_key_id: TARGET_AWS_ACCESS_KEY_ID,
      secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY
    )


    resp = @target_client.create_data_set({
      aws_account_id: TARGET_AWS_ACCOUNT_ID,
      data_set_id: source.data_set.data_set_id,
      name: source.data_set.name,
      physical_table_map: source.data_set.physical_table_map,
      logical_table_map: source.data_set.logical_table_map,
      import_mode: source.data_set.import_mode,
      #column_groups: source.data_set.column_groups,
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
      row_level_permission_data_set: source.data_set.row_level_permission_data_set,
      row_level_permission_tag_configuration: source.data_set.row_level_permission_tag_configuration,
      column_level_permission_rules: source.data_set.column_level_permission_rules,
      tags: [
        {
          key: "Name",
          value: source.data_set.name,
        },
      ],
      data_set_usage_configuration: source.data_set.data_set_usage_configuration,
    })

  end
end

migrate_data_sets
