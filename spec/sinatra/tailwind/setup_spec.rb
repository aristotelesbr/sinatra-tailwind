# spec/sinatra/tailwind/setup_spec.rb

require "spec_helper"

RSpec.describe Sinatra::Tailwind::Setup do
  let(:setup_instance) { Class.new { include Sinatra::Tailwind::Setup }.new }

  before do
    allow(setup_instance).to receive(:logger).and_return(Logger.new(nil))
  end

  describe "#create_dev_script" do
    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
      allow(FileUtils).to receive(:chmod)
      allow(setup_instance).to receive(:log_info)
    end

    it "creates bin directory" do
      setup_instance.create_dev_script
      expect(FileUtils).to have_received(:mkdir_p).with("bin")
    end

    it "creates dev script with correct content" do
      setup_instance.create_dev_script
      expect(File).to have_received(:write).with("bin/dev", anything)
    end

    it "sets correct permissions on dev script" do
      setup_instance.create_dev_script
      expect(FileUtils).to have_received(:chmod).with(0o755, "bin/dev")
    end

    it "logs creation of dev script" do
      setup_instance.create_dev_script
      expect(setup_instance).to have_received(:log_info).with("📝 Created bin/dev script")
    end
  end
end
