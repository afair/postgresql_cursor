# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: postgresql_cursor 0.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "postgresql_cursor"
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Allen Fair"]
  s.date = "2013-02-20"
  s.description = "PostgreSQL Cursor is an extension to the ActiveRecord PostgreSQLAdapter for very large result sets. It provides a cursor open/fetch/close interface to access data without loading all rows into memory, and instead loads the result rows in \"chunks\" (default of 10_000 rows), buffers them, and returns the rows one at a time."
  s.email = "allen.fair@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/postgresql_cursor.rb",
    "postgresql_cursor.gemspec",
    "test/helper.rb",
    "test/test_postgresql_cursor.rb"
  ]
  s.homepage = "http://github.com/afair/postgresql_cursor"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.11"
  s.summary = "ActiveRecord PostgreSQL Adapter extension for using a cursor to return a large result set"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<postgresql_cursor>, [">= 0"])
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_runtime_dependency(%q<pg>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<minitest-stub-const>, [">= 0"])
    else
      s.add_dependency(%q<postgresql_cursor>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<pg>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<minitest-stub-const>, [">= 0"])
    end
  else
    s.add_dependency(%q<postgresql_cursor>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<pg>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<minitest-stub-const>, [">= 0"])
  end
end

