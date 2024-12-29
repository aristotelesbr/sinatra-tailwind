require "bundler/setup"
require "sinatra/tailwind"
require "fileutils"
require "tmpdir"

RSpec.configure do |config|
  # Store test statuses in project root directory
  config.example_status_persistence_file_path = File.join(__dir__, "..", ".rspec_status")
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use RSpec metadata to store directory information
  config.around(:each) do |example|
    original_dir = Dir.pwd
    tmp_dir = Dir.mktmpdir

    begin
      Dir.chdir(tmp_dir)
      example.run
    ensure
      Dir.chdir(original_dir)
      FileUtils.remove_entry(tmp_dir) if tmp_dir && Dir.exist?(tmp_dir)
    end
  end
end
