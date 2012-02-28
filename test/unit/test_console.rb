require 'helper'

class TestConsole < Test::Unit::TestCase
  def new_console(*args)
    Linkage::Viewer::UI::Console.new(*args)
  end

  def setup
    super
    @dataset_1 = stub('dataset 1', :table_name => :foo, :adapter_scheme => :mysql, :field_set => {:id => stub(:to_expr => :id), :foo => stub(:to_expr => :foo)})
    @dataset_2 = stub('dataset 2', :table_name => :bar, :adapter_scheme => :sqlite, :field_set => {:id => stub(:to_expr => :id), :foo => stub(:to_expr => :bar)})
    @groups_dataset = stub('groups dataset', :count => 5)
    @groups_records_dataset = stub('groups_records dataset')
    @result_set = stub('result set', :groups_dataset => @groups_dataset, :groups_records_dataset => @groups_records_dataset)
    @lhs = stub('lhs', :side => :lhs, :data => stub(:to_expr => :foo))
    @rhs = stub('rhs', :side => :rhs, :data => stub(:to_expr => :bar))
    @expectation = stub('expectation', :kind => :self, :lhs => @lhs, :rhs => @rhs)
    @config = stub('configuration', :dataset_1 => @dataset_1, :dataset_2 => @dataset_2, :result_set => @result_set, :expectations => [@expectation])
    @highline = stub('highline', :say => nil)
    HighLine.stubs(:new).returns(@highline)
  end

  #test "menu" do
    #ui = new_console(@config)
    #ui.menu
  #end
end
