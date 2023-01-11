require "bundler/gem_tasks"
require "bundler/setup"
require 'rake/testtask'

task :default => :test

desc "Run the Test Suite, toot suite"
task :test do
  sh "ruby test/test_*"
end

desc "Open and IRB Console with the gem and test-app loaded"
task :console do
  sh "bundle exec irb  -Ilib -I . -r pg -r postgresql_cursor -r test-app/app"
  #require 'irb'
  #ARGV.clear
  #IRB.start
end

desc "Setup testing database"
task :setup do
  sh %q(createdb postgresql_cursor_test)
end
