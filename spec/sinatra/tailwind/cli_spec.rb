require "spec_helper"

RSpec.describe Sinatra::Tailwind::CLI do
  let(:cli) { described_class.new }
  let(:prompt) { instance_double(TTY::Prompt) }

  before do
    allow(TTY::Prompt).to receive(:new).with(enable_color: true).and_return(prompt)
    allow(prompt).to receive(:yes?).with(
      "\n🤔 Would you like to setup a Procfile.dev for development? (y/n)",
      default: true
    ).and_return(false)
    allow(cli).to receive(:say)
    allow(cli).to receive(:system).and_return(true)
  end

  describe "#install" do
    before do
      allow(cli).to receive(:check_npm_installation)
      allow(cli).to receive(:install_tailwind_dependencies)
      allow(cli).to receive(:create_tailwind_config)
      allow(cli).to receive(:create_css_file)
      allow(cli).to receive(:setup_build_process)
    end

    it "runs installation steps in order" do
      cli.install
      expect(cli).to have_received(:check_npm_installation).ordered
      expect(cli).to have_received(:install_tailwind_dependencies).ordered
      expect(cli).to have_received(:create_tailwind_config).ordered
      expect(cli).to have_received(:create_css_file).ordered
      expect(cli).to have_received(:setup_build_process).ordered
    end

    context "when user wants to setup Procfile.dev" do
      before do
        allow(prompt).to receive(:yes?).with(
          "\n🤔 Would you like to setup a Procfile.dev for development? (y/n)",
          default: true
        ).and_return(true)
        allow(cli).to receive(:invoke)
      end

      it "calls setup command" do
        cli.install
        expect(cli).to have_received(:invoke).with(:setup)
      end
    end

    context "when an error occurs" do
      before do
        allow(cli).to receive(:check_npm_installation).and_raise(Sinatra::Tailwind::Error, "Test error")
      end

      it "displays error message and exits" do
        expect { cli.install }.to raise_error(SystemExit)
        expect(cli).to have_received(:say).with("\n❌ Error: Test error", :red)
      end
    end
  end

  describe "#setup" do
    before do
      allow(File).to receive(:exist?).and_return(false)
      allow(cli).to receive(:create_file)
      allow(cli).to receive(:create_dev_script)
    end

    it "creates Procfile.dev when it doesn't exist" do
      cli.setup
      expect(cli).to have_received(:create_file).with("Procfile.dev", anything)
    end

    context "when setting up dev environment" do
      it "creates both Procfile.dev and bin/dev script" do
        cli.setup
        expect(cli).to have_received(:create_file).with("Procfile.dev", anything)
        expect(cli).to have_received(:create_dev_script)
      end

      it "displays setup completion message" do
        cli.setup
        expect(cli).to have_received(:say).with("\n✨ Development environment setup completed!", :green)
        expect(cli).to have_received(:say).with("\n👉 To start your development server, run:", :blue)
        expect(cli).to have_received(:say).with("  ./bin/dev", :cyan)
      end
    end

    context "when Procfile.dev exists" do
      before do
        allow(File).to receive(:exist?).with("Procfile.dev").and_return(true)
        allow(cli).to receive(:yes?).and_return(false)
      end

      it "asks for confirmation before overwriting" do
        cli.setup
        expect(cli).to have_received(:yes?)
      end

      context "and user confirms overwrite" do
        before do
          allow(cli).to receive(:yes?).and_return(true)
        end

        it "creates new Procfile.dev" do
          cli.setup
          expect(cli).to have_received(:create_file).with("Procfile.dev", anything)
        end
      end
    end

    context "when foreman is not installed" do
      before do
        allow(cli).to receive(:system).with("which foreman > /dev/null 2>&1").and_return(false)
        allow(cli).to receive(:create_file)
      end

      it "shows foreman installation instructions" do
        cli.setup
        expect(cli).to have_received(:say).with("\n⚠️  Note: You need to install foreman to use Procfile.dev", :yellow)
        expect(cli).to have_received(:say).with("  Run: gem install foreman", :cyan)
      end
    end
  end

  describe "#build" do
    context "when npm is installed" do
      before do
        allow(cli).to receive(:system).with("which npm > /dev/null 2>&1").and_return(true)
        allow(cli).to receive(:system).with("npm run build:css").and_return(true)
      end

      it "builds CSS successfully" do
        cli.build
        expect(cli).to have_received(:say).with("\n🔨 Building CSS files...", :blue)
        expect(cli).to have_received(:say).with("✨ CSS build completed successfully!", :green)
      end

      context "when build fails" do
        before do
          allow(cli).to receive(:system).with("npm run build:css").and_return(false)
        end

        it "shows error message and exits" do
          expect { cli.build }.to raise_error(SystemExit)
          expect(cli).to have_received(:say).with("\n❌ Error: Failed to build CSS", :red)
        end
      end
    end

    context "when npm is not installed" do
      before do
        allow(cli).to receive(:system).with("which npm > /dev/null 2>&1").and_return(false)
      end

      it "shows error message and exits" do
        expect { cli.build }.to raise_error(SystemExit)
        expect(cli).to have_received(:say).with("\n❌ Error: NPM is not installed", :red)
      end
    end
  end

  describe "#watch" do
    context "when npm is installed" do
      before do
        allow(cli).to receive(:system).with("which npm > /dev/null 2>&1").and_return(true)
        allow(cli).to receive(:exec)
      end

      it "starts watching for changes" do
        cli.watch
        expect(cli).to have_received(:say).with("\n👀 Watching for changes...", :blue)
      end
    end

    context "when npm is not installed" do
      before do
        allow(cli).to receive(:system).with("which npm > /dev/null 2>&1").and_return(false)
      end

      it "shows error message and exits" do
        expect { cli.watch }.to raise_error(SystemExit)
        expect(cli).to have_received(:say).with("\n❌ Error: NPM is not installed", :red)
      end
    end
  end
end
