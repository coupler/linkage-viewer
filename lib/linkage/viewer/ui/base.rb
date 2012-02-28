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
          @common_fields = [[], []]
          @config.expectations.each do |exp|
            if exp.kind != :filter
              lhs_expr = exp.lhs.data.to_expr
              rhs_expr = exp.rhs.data.to_expr
              if exp.lhs.side == :lhs
                @common_fields[0] << lhs_expr
                @common_fields[1] << rhs_expr
              else
                @common_fields[1] << lhs_expr
                @common_fields[0] << rhs_expr
              end
            end
          end
          @dataset_1 = @config.dataset_1
          @dataset_2 = @config.dataset_2
          @fields = [
            @common_fields[0] | @dataset_1.field_set.values.collect(&:to_expr),
            @common_fields[1] | @dataset_2.field_set.values.collect(&:to_expr)
          ]
        end

        def start
          raise NotImplementedError
        end
      end
    end
  end
end
