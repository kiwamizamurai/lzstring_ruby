require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "yard"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ["--display-cop-names"]
end

YARD::Rake::YardocTask.new(:yard) do |t|
  t.files = ["lib/**/*.rb"]
  t.options = ["--no-private"]
  t.stats_options = ["--list-undoc"]
end

desc "Run all quality checks"
task quality: %i[test rubocop yard]

task default: :quality
