# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postgresql_cursor/version'

Gem::Specification.new do |spec|
  spec.name          = "postgresql_cursor"
  spec.version       = PostgresqlCursor::VERSION
  spec.authors       = ["Allen Fair"]
  spec.email         = ["allen.fair@gmail.com"]
  spec.summary       = "ActiveRecord PostgreSQL Adapter extension for using a cursor to return a large result set"
  spec.description   = "PostgreSQL Cursor is an extension to the ActiveRecord PostgreSQLAdapter for very large result sets. It provides a cursor open/fetch/close interface to access data without loading all rows into memory, and instead loads the result rows in \"chunks\" (default of 1_000 rows), buffers them, and returns the rows one at a time."
  spec.homepage      = "http://github.com/afair/postgresql_cursor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

 #spec.add_dependency "pg" # Remove this for jruby, which should specify 'activerecord-jdbcpostgresql-adapter'
  spec.add_dependency "activerecord", ">= 3.1.0"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
