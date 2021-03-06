#!/usr/bin/env ruby

require 'aws-sdk-quicksight'
require './variables.rb'
require 'pry'

#make directories
@data_set_dirname = "data_sets"
Dir.mkdir(@data_set_dirname) unless File.exists?(@data_set_dirname)

@archive_dirname = "#{@data_set_dirname}/archive"
Dir.mkdir(@archive_dirname) unless File.exists?(@archive_dirname)

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


def convert_file_to_struct(file)
  json_file = File.read(file)
  data_set_hash = JSON.parse(json_file)
  struct = Aws::QuickSight::Types::DataSet.new(data_set_hash)
end


#def create_source_data_set_json_file(source)

  #resource = @source_client.describe_data_set({
    #aws_account_id: SOURCE_AWS_ACCOUNT_ID,
    #data_set_id: "#{source.data_set_id}",
  #})

  #File.open("source-#{resource.data_set.name}.json", 'w') do |f|
    #f.puts JSON.dump(resource.data_set.to_h)
  #end

  ##source_json_file = File.read("#{resource.data_set.name}")
  ##source_data_set_hash = JSON.parse(source_json_file)
  ##source_data_set = Aws::QuickSight::Types::DataSet.new(source_data_set_hash)
#end

def create_new_target_data_set_json_file(target_data_set)


  resource = @target_client.describe_data_set({
    aws_account_id: TARGET_AWS_ACCOUNT_ID,
    data_set_id: "#{target_data_set.data_set_id}",
  })


  File.open("#{@data_set_dirname}/#{resource.data_set.name}.json", 'w') do |f|
    f.puts JSON.dump(resource.data_set.to_h)
  end

end



#def check_last_updated_date(data_set_snapshot)
  ##grab dataset from target
  #target_data_set = @target_client.describe_data_set({
    #aws_account_id: TARGET_AWS_ACCOUNT_ID,
    #data_set_id: "#{data_set_snapshot.data_set_id}",
  #})

  #if target_data_set.data_set.last_updated_time == data_set_snapshot.last_updated_time
    #puts 'No updates were made...skipping'
  #else
    #puts "Updates found in source data_set...Updating Target"
  #end
#end

def archive(target_data_set)
  resource = @target_client.describe_data_set({
    aws_account_id: TARGET_AWS_ACCOUNT_ID,
    data_set_id: "#{target_data_set.data_set_id}",
  })

  if File.exist?("#{@data_set_dirname}/#{resource.data_set.name}.json")
    File.rename("#{@data_set_dirname}/#{resource.data_set.name}.json", "#{@archive_dirname}/#{resource.data_set.name}-#{Time.now}.json")
  end
end

def snapshot

  target_data_set_list = @target_client.list_data_sets({ aws_account_id: TARGET_AWS_ACCOUNT_ID })
  target_data_set_list[:data_set_summaries].each do |target_data_set|
    archive(target_data_set)
    create_new_target_data_set_json_file(target_data_set)
  end
end

snapshot
binding.pry
#remove after dev
#dsid = 'c148be9e-fab9-4746-92ee-af8fb5205849'
#
