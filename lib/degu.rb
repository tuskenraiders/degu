module Degu
end
require 'degu/version'
require 'degu/renum'

class Object
  include Degu::Renum
  unless defined?(enum)
    alias_method :enum, :renum
  end
end

require 'degu/railtie' if defined?(Rails)