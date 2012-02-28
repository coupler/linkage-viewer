require 'linkage'
require 'highline'
require 'terminal-table'
require 'erb'

module Linkage
  module Viewer
    def self.inspect(config, ui = :console)
      UI.get(ui).new(config)
    end
  end
end

path = Pathname.new(File.dirname(__FILE__)) + 'viewer'
require path + 'cli'
require path + 'ui'
