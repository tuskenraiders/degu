module Degu
end
require 'degu/polite'
class Object
  include Degu::Renum
end
if defined?(ActiveRecord::Base)
  class ActiveRecord::Base
    include Degu::HasEnum
    include Degu::HasSet
  end
end
