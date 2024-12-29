# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sinatra::Tailwind do
  let(:app) { Class.new(Sinatra::Base) }
  let(:setup) { Class.new { include Sinatra::Tailwind::Setup }.new }

  before do
    allow(setup).to receive(:logger).and_return(Logger.new(nil))
  end

  describe ".registered" do
    it "registers helpers with Sinatra" do
      expect(app).to receive(:helpers).with(Sinatra::Tailwind::Setup)
      described_class.registered(app)
    end
  end

  describe "Setup module" do
    describe "#check_npm_installation" do
      context "when npm is installed" do
        before do
          allow(setup).to receive(:system).with("which npm > /dev/null 2>&1").and_return(true)
        end

        it "does not raise error" do
          expect { setup.check_npm_installation }.not_to raise_error
        end
      end

      context "when npm is not installed" do
        before do
          allow(setup).to receive(:system).with("which npm > /dev/null 2>&1").and_return(false)
        end

        it "raises error" do
          expect { setup.check_npm_installation }
            .to raise_error(Sinatra::Tailwind::Error, /NPM is not installed/)
        end
      end
    end

    describe "#install_tailwind_dependencies" do
      before do
        # Mocka qualquer chamada a system() para não rodar nada real.
        allow(setup).to receive(:system).and_return(true)
        # Evita logs inconvenientes durante os testes
        allow(setup).to receive(:log_info)
      end

      context "when package.json doesn't exist" do
        before do
          # Simula que na primeira checagem o arquivo não existe;
          # na segunda, já existe (após criação).
          allow(File).to receive(:exist?).with("package.json")
            .and_return(false, true)

          # Permite escrita do arquivo "package.json" sem criar fisicamente
          allow(File).to receive(:write)

          # Conteúdo inicial que simulará a leitura de "package.json"
          initial_content = {
            "name" => "tailwind-app",
            "version" => "1.0.0",
            "private" => true,
            "dependencies" => {},
            "devDependencies" => {}
          }

          # Quando o código chamar File.read, devolve o JSON acima
          allow(File).to receive(:read).with("package.json")
            .and_return(JSON.pretty_generate(initial_content))

          # E quando JSON.parse for chamado, devolve esse hash
          allow(JSON).to receive(:parse).and_return(initial_content)
        end

        it "creates initial package.json" do
          expect(File).to receive(:write).with("package.json", anything).at_least(:once)
          setup.install_tailwind_dependencies
        end

        it "installs tailwindcss separately" do
          expect(setup).to receive(:system)
            .with("npm install tailwindcss@latest --save --legacy-peer-deps")
            .and_return(true)
          setup.install_tailwind_dependencies
        end
      end

      context "when package.json exists but dependencies are missing" do
        before do
          allow(File).to receive(:exist?).with("package.json").and_return(true)
          allow(File).to receive(:write)

          # Simula um package.json vazio
          initial_content = {
            "dependencies" => {},
            "devDependencies" => {}
          }
          allow(File).to receive(:read).with("package.json")
            .and_return(JSON.pretty_generate(initial_content))
          allow(JSON).to receive(:parse).and_return(initial_content)
        end

        it "installs required dependencies" do
          expect(setup).to receive(:system)
            .with("npm install tailwindcss@latest --save --legacy-peer-deps")
          expect(setup).to receive(:system)
            .with("npm install postcss autoprefixer --save-dev --legacy-peer-deps")
          setup.install_tailwind_dependencies
        end
      end

      context "when node_modules is missing" do
        before do
          allow(File).to receive(:exist?).with("package.json").and_return(true)
          allow(File).to receive(:write)

          content = {
            "dependencies" => {"tailwindcss" => "^3.4.17"},
            "devDependencies" => {
              "postcss" => "^8.0.0",
              "autoprefixer" => "^10.0.0"
            }
          }
          allow(File).to receive(:read).with("package.json")
            .and_return(JSON.pretty_generate(content))
          allow(JSON).to receive(:parse).and_return(content)

          allow(Dir).to receive(:exist?).with("node_modules").and_return(false)
        end

        it "reinstalls all dependencies" do
          expect(setup).to receive(:system)
            .with("npm install --legacy-peer-deps")
          setup.install_tailwind_dependencies
        end
      end

      context "when commands fail" do
        before do
          allow(File).to receive(:exist?).with("package.json").and_return(true)
          allow(File).to receive(:write)
          allow(setup).to receive(:system).and_return(true)
        end

        it "raises error when tailwind installation fails" do
          allow(File).to receive(:read).with("package.json")
            .and_return('{"dependencies":{},"devDependencies":{}}')
          # JSON.parse retorna um hash vazio aqui
          allow(JSON).to receive(:parse).and_return({
            "dependencies" => {},
            "devDependencies" => {}
          })

          allow(setup).to receive(:system)
            .with("npm install tailwindcss@latest --save --legacy-peer-deps")
            .and_return(false)

          expect { setup.install_tailwind_dependencies }
            .to raise_error(Sinatra::Tailwind::Error, /Failed to install TailwindCSS/)
        end

        it "raises error when dev dependencies installation fails" do
          # 1a leitura do package.json: sem tailwind
          allow(File).to receive(:read).with("package.json")
            .and_return(
              '{"dependencies":{},"devDependencies":{}}',
              '{"dependencies":{"tailwindcss":"^3.4.17"},"devDependencies":{}}'
            )

          # 1a parse: vazio, 2a parse: contém "tailwindcss"
          allow(JSON).to receive(:parse).and_return(
            {"dependencies" => {}, "devDependencies" => {}},
            {"dependencies" => {"tailwindcss" => "^3.4.17"}, "devDependencies" => {}}
          )

          allow(setup).to receive(:system)
            .with("npm install tailwindcss@latest --save --legacy-peer-deps")
            .and_return(true)

          allow(setup).to receive(:system)
            .with("npm install postcss autoprefixer --save-dev --legacy-peer-deps")
            .and_return(false)

          expect { setup.install_tailwind_dependencies }
            .to raise_error(Sinatra::Tailwind::Error, /Failed to install development dependencies/)
        end
      end
    end

    describe "#create_css_file" do
      before do
        allow(FileUtils).to receive(:mkdir_p)
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:write)
      end

      it "creates css directory" do
        setup.create_css_file
        expect(FileUtils).to have_received(:mkdir_p).with("public/css")
      end

      it "creates css file with tailwind directives" do
        expected_content = "@tailwind base;\n@tailwind components;\n@tailwind utilities;\n"
        setup.create_css_file
        expect(File).to have_received(:write).with("public/css/application.css", expected_content)
      end
    end
  end

  describe Sinatra::Tailwind::CLI do
    let(:cli) { described_class.new }
    let(:prompt) { instance_double(TTY::Prompt) }

    before do
      allow(TTY::Prompt).to receive(:new).with(enable_color: true).and_return(prompt)
      allow(prompt).to receive(:yes?).with(
        "\n🤔 Would you like to setup a Procfile.dev for development? (y/n)",
        default: true
      ).and_return(false)

      allow(cli).to receive(:check_npm_installation)
      allow(cli).to receive(:install_tailwind_dependencies)
      allow(cli).to receive(:create_tailwind_config)
      allow(cli).to receive(:create_css_file)
      allow(cli).to receive(:setup_build_process)
      allow(cli).to receive(:say)
    end

    describe "#install" do
      it "runs installation steps in order" do
        cli.install
        expect(cli).to have_received(:check_npm_installation).ordered
        expect(cli).to have_received(:install_tailwind_dependencies).ordered
        expect(cli).to have_received(:create_tailwind_config).ordered
        expect(cli).to have_received(:create_css_file).ordered
        expect(cli).to have_received(:setup_build_process).ordered
      end
    end
  end
end
