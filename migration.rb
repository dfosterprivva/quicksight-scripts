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
dev_client = Aws::QuickSight::Client.new(
  region: 'us-east-1',
  access_key_id: DEV_AWS_ACCESS_KEY_ID,
  secret_access_key: DEV_AWS_SECRET_ACCESS_KEY
)


# list data sources
DEV_DATA_SOURCES = dev_client.list_data_sources({ aws_account_id: DEV_AWS_ACCOUNT_ID })



DEV_DATA_SOURCES[:data_sources].each do |source|
  puts "#{source[:name]}"
  puts "#{source[:arn]}"
  puts "#{source[:data_source_id]}"
  puts "\n"
end


