require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "pvwatts"
  gem.homepage = "http://github.com/bstrech/pvwatts"
  gem.license = "MIT"
  gem.summary = %Q{Wrapper around the http://www.nrel.gov/rredc/pvwatts/ web service API. Forked from Matt Aimonetti.}
  gem.description = %Q{Calculates the Performance of a Grid-Connected PV System.}
  gem.email = "bstrech@gmail.com"
  gem.authors = ["Brenda Strech"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_runtime_dependency 'savon', '~> 0.7.6'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new