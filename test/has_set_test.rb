require 'test_helper.rb'

class HasSetTest < Test::Unit::TestCase

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_should_have_has_set_class_method
    assert_respond_to Person, :has_set
  end

  def test_should_provide_a_way_of_storing_enums_in_a_set_on_an_ar_model
    person = Person.new(:fullname => "Jessie Summers", :interests => [Interests::Dating, Interests::Shopping])
    assert person.save, "Person should save!"
    person.reload
    assert person.interest_shopping?, "Person should be interested in shopping."
    assert person.interest_dating?, "Person should be interested in dating."
  end

  def test_should_provide_a_way_of_storing_a_single_enum_value_in_a_set_on_an_ar_model
    person = Person.new(:fullname => "Jessie Summers", :interests => Interests::Dating)
    assert person.save, "Person should save!"
    person.reload
    assert person.interest_dating?, "Person should be interested in dating."
  end

  def test_should_throw_argument_error_if_there_is_no_enumeratable_class_to_take_the_set_entries_from
    assert_raise(NameError) { Person.has_set :hobbies }
  end

  def test_should_set_a_single_set_element
    person = Person.new
    person.interest_golf = true
    assert person.save, "Person should save!"
    person.reload
    assert person.interest_golf?, "Person should be interested in golf."
    person.interest_golf = nil
    assert !person.interest_golf?, "Person should not be interested in golf."
  end

  def test_should_reset_all_set_entries
    person = Person.new(:fullname => "Jessie Summers", :interests => [Interests::Dating, Interests::Shopping])
    assert person.interest_shopping?, "Person should be interested in shopping."
    assert person.interest_dating?, "Person should be interested in dating."
    person.interests = nil
    assert !person.interest_shopping?, "Person should not be interested in shopping."
    assert !person.interest_dating?, "Person should not be interested in dating."
  end

  def test_should_get_all_set_elements_of_a_certain_object
    person = Person.new(:fullname => "Jessie Summers", :interests => [Interests::Dating, Interests::Shopping])
    assert_equal [Interests::Dating, Interests::Shopping], person.interests
  end

  def test_should_reset_values_if_setter_is_used
    person = Person.new(:fullname => "Jessie Summers", :interests => [Interests::Dating])
    person.interests = Interests::Shopping
    assert_equal [Interests::Shopping], person.interests
  end

  def test_should_set_elements_by_string_names
    person = Person.new(:fullname => "Jessie Summers", :interests => "Dating, Shopping")
    assert_equal [Interests::Dating, Interests::Shopping], person.interests
    person = Person.new(:fullname => "Jessie Summers", :interests => "")
    assert_equal [], person.interests
  end

  def test_should_be_settable_to_nil
    person = Person.new(:fullname => "Jessie Summers", :interests => nil)
    assert_equal nil, person.interests
  end

  def test_should_set_elements_by_string_name
    person = Person.new(:fullname => "Jessie Summers", :interests => "Dating")
    assert_equal [Interests::Dating], person.interests
  end

  def test_should_raise_exception_if_strings_cannot_be_constantized
    assert_raise(ArgumentError) { Person.new(:fullname => "Jessie Summers", :interests => "Dadding, Shopping") }
  end

  def test_should_provide_the_name_of_the_bitfield_column
    party = Party.new(:location => "Beach House", :drinks => [Drinks::Beer, Drinks::CubaLibre])
    assert party.save, "Party should save!"
    party.reload
    assert party.drink_beer?, "Party should offer beer."
    assert party.drink_beer, "Party should offer beer."
    assert party.drink_cuba_libre?, "Party should offer cuba libre."
  end

  def test_should_have_to_s_method
    party = Party.new(:location => "Beach House", :drinks => [Drinks::Beer, Drinks::CubaLibre])
    assert_equal "Beer, CubaLibre", party.drinks.to_s
  end

  def test_should_provide_the_name_of_the_enum_class
    Party.has_set :music, :enum_class => MusicStyles

    party = Party.new(:location => "Penthouse", :music => [MusicStyles::Rock])
    assert party.save, "Party should save!"
    party.reload
    assert party.music_rock?, "Party should have Rock music."
  end

  def test_should_allow_unset_bitset
    itunes = Itunes.new
    assert_nil itunes.music, itunes.inspect
    assert itunes.save, "Itunes should save!"
    itunes.reload
    assert_nil itunes.music, itunes.inspect
  end

  def test_should_understand_symbol_values
    itunes = Itunes.new
    itunes.music = :rock, :pop
    assert itunes.music_rock?, "Itunes should have Rock music."
    assert itunes.music_pop?, "Itunes should have Pop music."
    assert itunes.save, "Itunes should save!"
    itunes.reload
    assert itunes.music_rock?, "Itunes should have Rock music."
    assert itunes.music_pop?, "Itunes should have Pop music."
  end

  def test_should_understand_comma_separated_strings
    itunes = Itunes.new
    itunes.music = 'Rock,   pop'
    assert itunes.music_rock?, "Itunes should have Rock music."
    assert itunes.music_pop?, "Itunes should have Pop music."
    assert itunes.save, "Itunes should save!"
    itunes.reload
    assert itunes.music_rock?, "Itunes should have Rock music."
    assert itunes.music_pop?, "Itunes should have Pop music."
  end

  def test_should_validate_that_only_elements_from_the_given_enum_are_used_in_the_set
    person = Person.new(:fullname => "Jessie Summers", :interests => Interests::Dating)
    assert_raise(ArgumentError) { person.interests = Drinks::Beer }
  end

  def test_should_list_all_available_enum_elements
    assert_equal ["drink_beer", "drink_cuba_libre", "drink_wine"], Party.new.available_drinks
  end

  def test_should_extend_enum_with_fieldname_method
    assert_equal "drink_cuba_libre", Drinks::CubaLibre.field_name
    assert_equal "drink_beer", Drinks::Beer.field_name
    assert_equal "drink_wine", Drinks::Wine.field_name
  end

  def test_empty_bitfield
    party = Party.new :drinks => [ :beer ]
    assert_equal [ Drinks[:beer] ], party.drinks
    party.drinks = []
    assert_equal [], party.drinks
    assert_equal 0, party.drinks_set
  end
end
