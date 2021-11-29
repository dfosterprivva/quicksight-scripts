#!/usr/bin/env ruby

require 'aws-sdk-quicksight'
require './variables.rb'
require 'pry'

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
def migrate_data_set(source)

  puts "creating Data Set: #{source.name} with ID: #{source.data_set_id}"
  puts "\n"

  resource = @source_client.describe_data_set({
    aws_account_id: SOURCE_AWS_ACCOUNT_ID,
    data_set_id: "#{source.data_set_id}",
  })

  #!!!discuss if need iteration for multiple physical tables
  physical_table_id = resource.data_set.physical_table_map.keys[0].to_s

   #check table type and create resource accordingly
    if resource.data_set.physical_table_map["#{physical_table_id}"][:s3_source] != nil
      target_data_source_arn = resource.data_set.physical_table_map["#{physical_table_id}"].s3_source.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
      resource.data_set.physical_table_map["#{physical_table_id}"].s3_source.data_source_arn = target_data_source_arn

    elsif resource.data_set.physical_table_map["#{physical_table_id}"][:relational_table] != nil
      target_data_source_arn = resource.data_set.physical_table_map["#{physical_table_id}"].relational_table.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
      resource.data_set.physical_table_map["#{physical_table_id}"].relational_table.data_source_arn = target_data_source_arn

    elsif resource.data_set.physical_table_map["#{physical_table_id}"][:custom_sql] != nil
      target_data_source_arn = resource.data_set.physical_table_map["#{physical_table_id}"].custom_sql.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
      resource.data_set.physical_table_map["#{physical_table_id}"].custom_sql.data_source_arn = target_data_source_arn
    end

  resp = @target_client.create_data_set({
    aws_account_id: TARGET_AWS_ACCOUNT_ID,
    data_set_id: resource.data_set.data_set_id,
    name: resource.data_set.name,
    physical_table_map: resource.data_set.physical_table_map,
    logical_table_map: resource.data_set.logical_table_map,
    import_mode: resource.data_set.import_mode,
    #column_groups: resource.data_set.column_groups,
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
    row_level_permission_data_set: resource.data_set.row_level_permission_data_set,
    row_level_permission_tag_configuration: resource.data_set.row_level_permission_tag_configuration,
    column_level_permission_rules: resource.data_set.column_level_permission_rules,
    tags: [
      {
        key: "Name",
        value: resource.data_set.name,
      },
    ],
    data_set_usage_configuration: resource.data_set.data_set_usage_configuration,
  })

end

def check_data_sets

  #gather source data sets
  source_data_sets = @source_client.list_data_sets({ aws_account_id: SOURCE_AWS_ACCOUNT_ID })

  #gather target data sets, create id list
  target_data_set_list = @target_client.list_data_sets({ aws_account_id: TARGET_AWS_ACCOUNT_ID })
  target_data_set_id_hash = {}
  target_data_set_list[:data_set_summaries].each do |target_data_set|
    target_data_set_id_hash[target_data_set.data_set_id] = target_data_set.arn
  end

  #create exlusion prefixes for sets not to be included for migration
  exclusion_list = ["assessments_with_labels", "assessments_4a087994-f400-4c53-8e3b-61e4a86d4225"]

  source_data_sets[:data_set_summaries].each do |source|
    puts "Checking Data Set:#{source.name} with ID: #{source.data_set_id}"

    if target_data_set_id_hash["#{source.data_set_id}"]
      then
      puts "Data source already Exists... updating"
      puts "\n"
      #update_data_set(source)
    else
      puts "Checking set for migration readiness..."
      if exclusion_list.include?(source.name)
        then
        puts "Skipping #{source.name} with ID: #{source.data_set_id}.  This set is not meant to be migrated"
        puts "\n"
      else
        puts "Data set ready for migration and does NOT exist in target... will migrate set"
        puts "\n"
        migrate_data_set(source)
      end
    end
  end
end

check_data_sets
#binding.pry
