require 'helper'

class TestViewer < Test::Unit::TestCase
  test ".inspect takes a configuration and a ui mode" do
    config = stub('config')
    ui = stub('console ui')
    Linkage::Viewer::UI::Console.expects(:new).with(config).returns(ui)
    Linkage::Viewer.inspect(config, :console)
  end
end
