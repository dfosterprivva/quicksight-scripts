#!/usr/bin/env ruby
require 'aws-sdk-quicksight'

# Variables
DEV_AWS_ACCESS_KEY_ID = ENV['DEV_AWS_ACCESS_KEY_ID']
DEV_AWS_SECRET_ACCESS_KEY = ENV['DEV_AWS_SECRET_ACCESS_KEY']
DEV_AWS_ACCOUNT_ID = ENV['DEV_AWS_ACCOUNT_ID']

SANDBOX_AWS_ACCESS_KEY_ID = ENV['SANDBOX_AWS_ACCESS_KEY_ID']
SANDBOX_AWS_SECRET_ACCESS_KEY = ENV['SANDBOX_AWS_SECRET_ACCESS_KEY']
SANDBOX_AWS_ACCOUNT_ID = ENV['SANDBOX_AWS_ACCOUNT_ID']

# initiate connection to dev
@dev_client = Aws::QuickSight::Client.new(
  region: 'us-east-1',
  access_key_id: DEV_AWS_ACCESS_KEY_ID,
  secret_access_key: DEV_AWS_SECRET_ACCESS_KEY
)


# data sources
def get_data_sources(source_account_id)
  dev_data_sources = @dev_client.list_data_sources({ aws_account_id: source_account_id })

  dev_data_sources[:data_sources].each do |source|
    puts "#{source[:name]}"
    puts "#{source[:arn]}"
    puts "#{source[:data_source_id]}"
    puts "\n"
  end
end


# data sets
def get_data_sets(source_account_id)
  dev_data_sets = @dev_client.list_data_sets({ aws_account_id: source_account_id})

  dev_data_sets[:data_set_summaries].each do |summary|
    puts "#{summary[:name]}"
    puts "#{summary[:arn]}"
    puts "#{summary[:data_set_id]}"
    puts "\n"
  end
end

#get_data_sources(DEV_AWS_ACCOUNT_ID)
#get_data_sets(DEV_AWS_ACCOUNT_ID)
