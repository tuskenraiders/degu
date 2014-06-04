module Degu
end
require 'degu/polite'
class Object
  include Degu::Renum
  unless defined?(enum)
    alias_method :enum, :renum
  end
end
if defined?(ActiveRecord::Base)
  class ActiveRecord::Base
    include Degu::HasEnum
    include Degu::HasSet
  end
end
