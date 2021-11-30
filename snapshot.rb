#!/usr/bin/env ruby

require 'aws-sdk-quicksight'
require './variables.rb'
require 'pry'

# initiate connection to source
@source_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: SOURCE_AWS_ACCESS_KEY_ID,
  secret_access_key: SOURCE_AWS_SECRET_ACCESS_KEY,
)

# initiate connection to target
@target_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: TARGET_AWS_ACCESS_KEY_ID,
  secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY,
)


dsid = 'c148be9e-fab9-4746-92ee-af8fb5205849'

resource = @source_client.describe_data_set({
  aws_account_id: SOURCE_AWS_ACCOUNT_ID,
  data_set_id: "#{dsid}"
})


File.open("#{resource.data_set.name}", 'w') do |f|
  f.puts JSON.dump(resource.data_set.to_h)
end

file = File.read("#{resource.data_set.name}")
data_set_hash = JSON.parse(file)
date_set_build = Aws::QuickSight::Types::DataSet.new(data_set_hash)

binding.pry
