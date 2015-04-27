module Degu
  class Railtie < ::Rails::Railtie
    initializer 'degu.init_active_record_plugins' do
      require 'degu/init_active_record_plugins'
    end
  end
end