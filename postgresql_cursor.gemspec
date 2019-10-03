# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postgresql_cursor/version'

Gem::Specification.new do |spec|
  spec.name          = 'postgresql_cursor'
  spec.version       = PostgresqlCursor::VERSION
  spec.authors       = ['Allen Fair']
  spec.email         = ['allen.fair@gmail.com']
  spec.summary       = <<-SUMMARY
  ActiveRecord PostgreSQL Adapter extension for using a cursor to return a
  large result set
  SUMMARY
  spec.description = <<-DESCRIPTION
  PostgreSQL Cursor is an extension to the ActiveRecord PostgreSQLAdapter for
  very large result sets.  It provides a cursor open/fetch/close interface to
  access data without loading all rows into memory, and instead loads the result
  rows in 'chunks' (default of 1_000 rows), buffers them, and returns the rows
  one at a time.
  DESCRIPTION
  spec.homepage      = 'http://github.com/afair/postgresql_cursor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Remove this for jruby which should use 'activerecord-jdbcpostgresql-adapter'
  # spec.add_dependency 'pg'

  spec.add_dependency 'activerecord', '>= 3.1.0'
  # spec.add_dependency 'activerecord', '~> 3.1.0'
  # spec.add_dependency 'activerecord', '~> 4.1.0'
  # spec.add_dependency 'activerecord', '~> 5.0.0'
  # spec.add_dependency 'activerecord', '~> 6.0.0'

  spec.add_development_dependency 'irb'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rake'
end
