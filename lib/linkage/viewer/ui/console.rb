module Linkage
  module Viewer
    module UI
      class Console < Base
        def initialize(*args)
          super
          @console = HighLine.new
          @menu_template = ERB.new(MENU, nil, "-")
        end

        def start
          set_group_index(0)
          menu
        end

        private

        def menu
          @console.say(@menu_template.result(binding))
          result = @console.ask("? ") { |q| q.in = %w{1 2 3 4 p n q} }
          case result
          when "1"
            @records_index[0] -= 1 if @records_index[0] != 0
          when "2"
            @records_index[0] += 1 if @records_index[0] != (@records[0].length - 1)
          when "3"
            @records_index[1] -= 1 if @records_index[1] != 0
          when "4"
            @records_index[1] += 1 if @records_index[1] != (@records[1].length - 1)
          when "p"
            set_group_index(@group_index - 1) if @group_index != 0
          when "n"
            set_group_index(@group_index + 1) if @group_index != (@group_count - 1)
          when "q"
            return
          end
          menu
        end

        def get_table
          field_expressions_1 = @field_expressions[0]
          field_expressions_2 = @field_expressions[1]
          field_names_1 = @field_names[0]
          field_names_2 = @field_names[1]
          record_1 = @records[0][@records_index[0]]
          record_2 = @records[1][@records_index[1]]

          Terminal::Table.new do |t|
            t.title = "Group #{@group_index + 1} of #{@group_count}"
            t.headings = [
              {:value => "Record #{@records_index[0] + 1} of #{@records[0].length}", :colspan => 2, :alignment => :center},
              {:value => "Record #{@records_index[1] + 1} of #{@records[1].length}", :colspan => 2, :alignment => :center}
            ]

            num = [field_expressions_1.length, field_expressions_2.length].max
            num.times do |i|
              field_name_1 = field_names_1[i]
              field_name_2 = field_names_2[i]
              row = []
              if field_name_1
                row.push(field_name_1, record_1[field_name_1])
              else
                row.push("", "")
              end
              if field_name_2
                row.push(record_2[field_name_2], field_name_2)
              else
                row.push("", "")
              end
              t << row
            end
          end
        end
      end
    end
  end
end

Linkage::Viewer::UI::Console::MENU = <<EOF
Dataset 1: <%= @datasets[0].table_name %> (<%= @datasets[0].adapter_scheme %>)
Dataset 2: <%= @datasets[1].table_name %> (<%= @datasets[1].adapter_scheme %>)
Groups:    <%= @groups_dataset.count %>

<%= get_table %>

[1] prev left [2] next left [3] prev right [4] next right
[p]revious group [n]ext group [q]uit
EOF
