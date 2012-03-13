module Linkage
  module Viewer
    module UI
      class Base
        def initialize(config)
          @config = config
          @result_set = @config.result_set
          @groups_dataset = @result_set.groups_dataset
          @group_count = @groups_dataset.count
          @groups_records_dataset = @result_set.groups_records_dataset

          common_fields = [[], []]
          @config.expectations.each do |exp|
            if exp.kind != :filter
              lhs_data = exp.lhs.data
              rhs_data = exp.rhs.data
              if exp.lhs.side == :lhs
                common_fields[0] << lhs_data
                common_fields[1] << rhs_data
              else
                common_fields[1] << lhs_data
                common_fields[0] << rhs_data
              end
            end
          end
          @dataset_1 = @config.dataset_1
          @dataset_2 = @config.dataset_2
          all_fields = [
            common_fields[0] | @dataset_1.field_set.values,
            common_fields[1] | @dataset_2.field_set.values
          ]
          @field_expressions = [[], []]
          @field_names = [[], []]
          all_fields.each_with_index do |fields, i|
            fields.each do |field|
              expr = field.to_expr
              if expr.is_a?(Sequel::SQL::Function)
                name = field.name
                expr = expr.as(name)
              else
                name = expr
              end
              @field_expressions[i] << expr
              @field_names[i] << name
            end
          end
        end

        def start
          raise NotImplementedError
        end
      end
    end
  end
end
