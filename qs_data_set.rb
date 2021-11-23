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

  source_data_sets = @source_client.list_data_sets({ aws_account_id: SOURCE_AWS_ACCOUNT_ID })

  source_data_sets[:data_set_summaries].each do |summary|
    data_set_name = "#{summary[:name]}"
    data_set_id = "#{summary[:data_set_id]}"
    puts "Creating Data Set: #{data_set_name} with ID: #{data_set_id}"
    puts "\n"

    source = @source_client.describe_data_set({
      aws_account_id: SOURCE_AWS_ACCOUNT_ID,
      data_set_id: "#{data_set_id}",
    })
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

def check_data_sets

  #gather source data sets
  source_data_sets = @source_client.list_data_sets({ aws_account_id: SOURCE_AWS_ACCOUNT_ID })

  #gather target data sets, create id list
  target_data_set_list = @target_client.list_data_sets({ aws_account_id: TARGET_AWS_ACCOUNT_ID })
  target_data_set_id_hash = {}
  target_data_set_list[:data_sets].each do |target_data_set|
    target_data_set_id_hash[target_data_set.data_set_id] = target_data_set.arn
  end

  source_data_sets[:data_sets].each do |source|
    puts "Checking #{source.name} with ID: #{source.data_set_id}"

    if target_data_set_id_hash["#{source.data_set_id}"]
      then
      puts "Data source already Exists... updating"
      puts "\n"
      #update_data_set(source)
    else
      puts "Data source does NOT exist... will migrate source"
      puts "\n"
      #migrate_data_set(source)
    end
  end
end
check_data_sets
