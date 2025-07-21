# Changes

## 2025-07-21 v0.9.1

- Updated the `degu` gem to version **0.9.1**, including:
  - Increased Rails compatibility range for `activerecord` to **>= 3.0** and
    **< 9**
  - Added new development dependencies: `debug` and `simplecov`
  - Removed outdated dependency constraints
  - Updated the `VERSION` file, `degu.gemspec`, and `lib/degu/version.rb` from
    **0.9.0** to **0.9.1**
- Refactored JSON serialization test for `Status::NOT_STARTED` by adding
  `create_additions: true` to the `JSON.parse` call
- Removed defunct Travis CI build status badge from `README.md`
- Renamed `COPYING` file to `LICENSE` and updated references in `README.md`

## 2016-06-23 v0.9.0

- Added support for **pure active models** using `has_enum` to enable enum
  functionality without requiring a database column.

## 2016-02-24 v0.8.1

- Removed Rails 5 deprecation warnings
- Fixed Ruby special variable tracking in `SafeBuffer` by adjusting `gsub`
  semantics
- Updated gemspec to ensure compatibility with newer Ruby versions
- Added tests for current Ruby versions

## 2015-05-06 v0.8.0

- Added support for comparing to enum representations.
- Removed hard dependency on `activerecord`.
- Added deprecation warning for older requires.

## 2015-04-24 v0.7.0

## 2015-04-24 v0.6.0

- Improved comparison behavior of `enums`.
- Fixed a bug in Ruby **2.2.0** where comparing an `Enum` element with a
  non-`Enum` element displayed a warning.
- Updated tests to run on the newest Rubies and dropped support for Ruby 1.9.x.
- Upgraded to use the latest version of `gem_hadar`.

## 2014-06-11 v0.5.0

- Added support for **Rails 4.1** and large bitset functionality.
- Updated RSpec tests to align with recent API trends and best practices.
- Fixed the `read_set_attribute` method to handle classes with multiple enums
  correctly.
- Enhanced `has_set` functionality by supporting very large sets using string
  columns.
- Renamed the `enum` method in `renum` to avoid conflicts with Rails 4.1's
  built-in enum functionality. The original method is now aliased as `renum` if
  it doesn't already exist.
- Removed support for Ruby 1.9.2 due to Travis CI limitations.
- Updated test suite to focus on newer Ruby versions only.
- Upgraded various dependencies and updated ignored files list.

## 2013-07-11 v0.4.0

- Added the `COPYING` file, which indicates the project uses the MIT license.
- Removed a lambda-based `should` construct in favor of simpler syntax.
- Updated to support Ruby **2.0.0**.
- Added documentation for the `has_set` and `has_enum` methods in the README.
- Renamed planet names in documentation for clarity.
- Added tests for the `definition_extension` method in the `EnumeratedValue`
  class.
- Configured Travis CI to ignore failures on Ruby-head due to a known bug.
- Updated the project's README file to use Markdown format.
- Removed deprecation warnings related to Active Record and updated its version
  constraints.

## 2013-01-14 v0.3.0

- Added predicate methods `has_enum` to check for the presence of enums.

## 2013-01-11 v0.2.0

- **Fixes column type checking** when the database is not yet created.
- **Resolves validation bug** encountered with integer columns.
- **Supports has_enum columns** using integers, enabling database comparison of
  enum values. The `index` method is utilized to store enum values.

## 2012-07-30 v0.1.3

- Added `bitfield_index` method to `EnumeratedValue`
- Updated Travis configuration
- Modified compatibility settings for certain Ruby implementations

## 2012-07-05 v0.1.2

- Fixed a warning related to `InstanceMethods` in newer versions of Rails.

## 2011-12-15 v0.1.1

- Rollback changes to `Array#to_s`  
- Cleaned up `has_set` method and modified the `to_s` method for returned
  feature arrays

## 2011-12-14 v0.1.0

- Fixed an issue where a `false` exception was being raised incidentally.

## 2011-12-08 v0.0.5

## 2011-12-08 v0.0.4

- Added support for `foo.set = []` functionality.

## 2011-12-06 v0.0.3

- Added support for `has_enum` in the ORM layer, resolving issues with enum
  handling.

## 2011-12-01 v0.0.2

- Fixed comparison between `Foo['1']` and `Foo[1]` to ensure equality.

## 2011-11-30 v0.0.1

- Work on code in `HashSet`  
- Fix up documentation a bit

## 2011-11-30 v0.0.0

  * Start
