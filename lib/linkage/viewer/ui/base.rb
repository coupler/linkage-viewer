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
          @datasets = [@config.dataset_1, @config.dataset_2]

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
          @group = @groups_dataset.order(:id).limit(1, index).first
          @records = []
          @records_index = [0, 0]

          if @config.linkage_type == :self
            expressions = @field_expressions[0] | @field_expressions[1]
            @records << get_records(@group[:id], 1, expressions)
            @records << @records[0]
            @records_index[1] = 1
          else
            @records << get_records(@group[:id], 1, @field_expressions[0])
            @records << get_records(@group[:id], 2, @field_expressions[1])
          end
        end

        def get_records(group_id, dataset_id, record_expressions)
          record_ids = @groups_records_dataset.filter(:group_id => group_id, :dataset => dataset_id).select_map(:record_id)
          dataset = dataset_id == 1 ? @datasets[0] : @datasets[1]
          primary_key = dataset.field_set.primary_key.to_expr

          dataset.select(*record_expressions).filter(primary_key => record_ids).all
        end
      end
    end
  end
end
