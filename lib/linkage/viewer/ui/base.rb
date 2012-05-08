module Linkage
  module Viewer
    module UI
      class Base
        def initialize(config)
          @config = config
          @result_set = @config.result_set
          @groups_dataset = @result_set.groups_dataset
          @group_count = @groups_dataset.count
          @datasets = @config.datasets_with_applied_expectations

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

          all_fields = if @config.visual_comparisons.empty?
            [
              common_fields[0] | @datasets[0].field_set.values,
              common_fields[1] | @datasets[1].field_set.values
            ]
          else
            @config.visual_comparisons.inject(common_fields.dup) do |arr, vc|
              if vc.lhs.side == :lhs
                arr[0].push(vc.lhs.data)
                arr[1].push(vc.rhs.data)
              else
                arr[1].push(vc.lhs.data)
                arr[0].push(vc.rhs.data)
              end
              arr
            end
          end

          @field_expressions = [[], []]
          @field_names = [[], []]
          all_fields.each_with_index do |fields, i|
            fields.each do |field|
              expr = field.to_expr(@datasets[i].adapter_scheme)
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

        private

        def set_group_index(index)
          @group_index = index
          @group = @result_set.get_group(index)
          @records = []
          @records_index = [0, 0]

          if @config.linkage_type == :self
            expressions = @field_expressions[0] | @field_expressions[1]
            @records << get_records(@group, 1, expressions)
            @records << @records[0]
            @records_index[1] = 1
          else
            @records << get_records(@group, 1, @field_expressions[0])
            @records << get_records(@group, 2, @field_expressions[1])
          end
        end

        def get_records(group, dataset_id, record_expressions)
          dataset = dataset_id == 1 ? @datasets[0] : @datasets[1]
          dataset.dataset_for_group(group).select(*record_expressions).all
        end
      end
    end
  end
end
