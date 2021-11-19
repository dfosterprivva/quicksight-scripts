#!/usr/bin/env ruby
require 'aws-sdk-quicksight'

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
    puts "#{source[:arn]}"
    puts "#{source[:data_source_id]}"
    puts "\n"
  end
end


# data sets
def get_data_sets(source_account_id)
  source_data_sets = @source_client.list_data_sets({ aws_account_id: source_account_id})

  source_data_sets[:data_set_summaries].each do |summary|
    puts "#{summary[:name]}"
    puts "#{summary[:data_set_id]}"
    #puts "#{summary[:arn]}"
    puts "\n"
  end
end

get_data_sources(SOURCE_AWS_ACCOUNT_ID)
#get_data_sets(SOURCE_AWS_ACCOUNT_ID)
