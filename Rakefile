require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "postgresql_cursor"
    gem.summary = %Q{ActiveRecord PostgreSQL Adapter extension for using a cursor to return a large result set}
    gem.description = %Q{PostgreSQL Cursor is an extension to the ActiveRecord PostgreSQLAdapter for very large result sets. It provides a cursor open/fetch/close interface to access data without loading all rows into memory, and instead loads the result rows in "chunks" (default of 10_000 rows), buffers them, and returns the rows one at a time.}
    gem.email = "allen.fair@gmail.com"
    gem.homepage = "http://github.com/afair/postgresql_cursor"
    gem.authors = ["Allen Fair"]
    gem.add_dependency 'activerecord'
    gem.add_development_dependency 'jeweler'
    gem.add_development_dependency 'rdoc'
    gem.add_development_dependency 'minitest'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "postgresql_cursor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
