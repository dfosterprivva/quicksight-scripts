#!/usr/bin/env ruby
require 'aws-sdk-quicksight'
require 'pry'

require './variables.rb'

# initiate connection to source
@source_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: SOURCE_AWS_ACCESS_KEY_ID,
  secret_access_key: SOURCE_AWS_SECRET_ACCESS_KEY
)


# data sources
def get_data_sources(source_account_id)
  source_data_sources = @source_client.list_data_sources({ aws_account_id: source_account_id })

  source_data_sources[:data_sources].each do |source|
    puts "#{source[:name]}"
    puts "#{source[:data_source_id]}"
    puts "\n"
  end
end


# data sets
def get_data_sets(source_account_id)
  source_data_sets = @source_client.list_data_sets({ aws_account_id: source_account_id})

  source_data_sets[:data_set_summaries].each do |summary|
    data_set_name = "#{summary[:name]}"
    data_set_id = "#{summary[:data_set_id]}"
    puts "#{data_set_id} #{data_set_name}"
    puts "\n"

    dataset_details = @source_client.describe_data_set({
      aws_account_id: SOURCE_AWS_ACCOUNT_ID,
      data_set_id: "#{data_set_id}",
    })

    dataset_details.data_set.arn = "arn:aws:quicksight:us-east-1:#{TARGET_AWS_ACCOUNT_ID}:dataset/#{data_set_id}"
    physical_table_id = dataset_details.data_set.physical_table_map.keys
    puts physical_table_id
    puts "#{dataset_details.data_set.physical_table_map["#{physical_table_id}"].s3_source.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")}"
    #target_data_source_arn = dataset_details.data_set.physical_table_map[physical_table_id].s3_source.data_source_arn.gsub("#{SOURCE_AWS_ACCOUNT_ID}","#{TARGET_AWS_ACCOUNT_ID}")
    #puts target_data_source_arn
    #dataset_details.data_set.physical_table_map["s3PhysicalTable"].s3_source.data_source_arn = target_data_source_arn
    #puts "...Writing to file"
    #File.open("#{data_set_name}.json", 'w') do |f|
      #f.puts JSON.pretty_generate(dataset_details.data_set.to_h)
    #end
    puts "\n"
  end
end

#get_data_sets(SOURCE_AWS_ACCOUNT_ID)

resp = @source_client.describe_data_set({
  aws_account_id: SOURCE_AWS_ACCOUNT_ID,
  data_set_id: "0a38e48a-d3fe-478f-a1d6-b17e6b1c63a5"
  #data_set_id: "02d069aa-e68d-437b-8f38-1b8a76b2b39b"
})
binding.pry

