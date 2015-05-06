require 'degu/has_set'
require 'degu/has_enum'

class ActiveRecord::Base
  include Degu::HasEnum
  include Degu::HasSet
end