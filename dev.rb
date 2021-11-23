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


# initiate connection to target
@target_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: TARGET_AWS_ACCESS_KEY_ID,
  secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY
)
#get_data_sets(SOURCE_AWS_ACCOUNT_ID)

#resp = @source_client.describe_data_set({
  #aws_account_id: SOURCE_AWS_ACCOUNT_ID,
  #data_set_id: "76ea2665-6a40-44f0-ad93-db8f3cbdbfd9"
#})
#resp = @source_client.describe_data_source({
  #aws_account_id: SOURCE_AWS_ACCOUNT_ID,
  #data_source_id: '83967cb4-4be0-4150-885f-b93893d11b54',
#})
source_data_sources = @source_client.list_data_sources({ aws_account_id: SOURCE_AWS_ACCOUNT_ID })
binding.pry

