#!/usr/bin/env ruby

require 'aws-sdk-quicksight'
require './variables.rb'

#scoped params
DATA_SET_ID = ''
RESOURCE_NAME  = ''

# initiate connection to target
@target_client = Aws::QuickSight::Client.new(
  region: AWS_REGION,
  access_key_id: TARGET_AWS_ACCESS_KEY_ID,
  secret_access_key: TARGET_AWS_SECRET_ACCESS_KEY
)

resp = @target_client.create_data_set({
  aws_account_id: TARGET_AWS_ACCOUNT_ID,
  data_set_id: DATA_SET_ID,
  name: RESOURCE_NAME,
  physical_table_map: { # required
    "PhysicalTableId" => {
      relational_table: {
        data_source_arn: "Arn", # required
        catalog: "RelationalTableCatalog",
        schema: "RelationalTableSchema",
        name: "RelationalTableName", # required
        input_columns: [ # required
          {
            name: "ColumnName", # required
            type: "STRING", # required, accepts STRING, INTEGER, DECIMAL, DATETIME, BIT, BOOLEAN, JSON
          },
        ],
      },
      custom_sql: {
        data_source_arn: "Arn", # required
        name: "CustomSqlName", # required
        sql_query: "SqlQuery", # required
        columns: [
          {
            name: "ColumnName", # required
            type: "STRING", # required, accepts STRING, INTEGER, DECIMAL, DATETIME, BIT, BOOLEAN, JSON
          },
        ],
      },
      s3_source: {
        data_source_arn: "Arn", # required
        upload_settings: {
          format: "CSV", # accepts CSV, TSV, CLF, ELF, XLSX, JSON
          start_from_row: 1,
          contains_header: false,
          text_qualifier: "DOUBLE_QUOTE", # accepts DOUBLE_QUOTE, SINGLE_QUOTE
          delimiter: "Delimiter",
        },
        input_columns: [ # required
          {
            name: "ColumnName", # required
            type: "STRING", # required, accepts STRING, INTEGER, DECIMAL, DATETIME, BIT, BOOLEAN, JSON
          },
        ],
      },
    },
  },
  logical_table_map: {
    "LogicalTableId" => {
      alias: "LogicalTableAlias", # required
      data_transforms: [
        {
          project_operation: {
            projected_columns: ["String"], # required
          },
          filter_operation: {
            condition_expression: "Expression", # required
          },
          create_columns_operation: {
            columns: [ # required
              {
                column_name: "ColumnName", # required
                column_id: "ColumnId", # required
                expression: "Expression", # required
              },
            ],
          },
          rename_column_operation: {
            column_name: "ColumnName", # required
            new_column_name: "ColumnName", # required
          },
          cast_column_type_operation: {
            column_name: "ColumnName", # required
            new_column_type: "STRING", # required, accepts STRING, INTEGER, DECIMAL, DATETIME
            format: "TypeCastFormat",
          },
          tag_column_operation: {
            column_name: "ColumnName", # required
            tags: [ # required
              {
                column_geographic_role: "COUNTRY", # accepts COUNTRY, STATE, COUNTY, CITY, POSTCODE, LONGITUDE, LATITUDE
                column_description: {
                  text: "ColumnDescriptiveText",
                },
              },
            ],
          },
          untag_column_operation: {
            column_name: "ColumnName", # required
            tag_names: ["COLUMN_GEOGRAPHIC_ROLE"], # required, accepts COLUMN_GEOGRAPHIC_ROLE, COLUMN_DESCRIPTION
          },
        },
      ],
      source: { # required
        join_instruction: {
          left_operand: "LogicalTableId", # required
          right_operand: "LogicalTableId", # required
          left_join_key_properties: {
            unique_key: false,
          },
          right_join_key_properties: {
            unique_key: false,
          },
          type: "INNER", # required, accepts INNER, OUTER, LEFT, RIGHT
          on_clause: "OnClause", # required
        },
        physical_table_id: "PhysicalTableId",
        data_set_arn: "Arn",
      },
    },
  },
  import_mode: "SPICE", # required, accepts SPICE, DIRECT_QUERY
  column_groups: [
    {
      geo_spatial_column_group: {
        name: "ColumnGroupName", # required
        country_code: "US", # required, accepts US
        columns: ["ColumnName"], # required
      },
    },
  ],
  field_folders: {
    "FieldFolderPath" => {
      description: "FieldFolderDescription",
      columns: ["String"],
    },
  },
  permissions: [
    {
      principal: "Principal", # required
      actions: ["String"], # required
    },
  ],
  row_level_permission_data_set: {
    namespace: "Namespace",
    arn: "Arn", # required
    permission_policy: "GRANT_ACCESS", # required, accepts GRANT_ACCESS, DENY_ACCESS
    format_version: "VERSION_1", # accepts VERSION_1, VERSION_2
    status: "ENABLED", # accepts ENABLED, DISABLED
  },
  row_level_permission_tag_configuration: {
    status: "ENABLED", # accepts ENABLED, DISABLED
    tag_rules: [ # required
      {
        tag_key: "SessionTagKey", # required
        column_name: "String", # required
        tag_multi_value_delimiter: "RowLevelPermissionTagDelimiter",
        match_all_value: "SessionTagValue",
      },
    ],
  },
  column_level_permission_rules: [
    {
      principals: ["String"],
      column_names: ["String"],
    },
  ],
  tags: [
    {
      key: "TagKey", # required
      value: "TagValue", # required
    },
  ],
  data_set_usage_configuration: {
    disable_use_as_direct_query_source: false,
    disable_use_as_imported_source: false,
  },
})

