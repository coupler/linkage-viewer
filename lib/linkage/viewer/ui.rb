module Linkage
  module Viewer
    module UI
      def self.get(name)
        const_get(name.to_s.capitalize)
      end
    end
  end
end

path = Pathname.new(File.dirname(__FILE__)) + 'ui'
require path + 'base'
require path + 'console'
