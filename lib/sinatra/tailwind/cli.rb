require "thor"
require "sinatra/tailwind/setup"
require "tty-prompt"

module Sinatra
  module Tailwind
    class CLI < Thor
      include Thor::Actions
      include Sinatra::Tailwind::Setup

      map %w[--version -v] => :version

      desc "version", "Show sinatra-tailwind version"
      def version
        require "sinatra/tailwind/version"
        say "sinatra-tailwind version #{Sinatra::Tailwind::VERSION}"
      end

      desc "install", "Install TailwindCSS in your Sinatra application"
      def install
        say "\n🎨 Installing TailwindCSS for your Sinatra application...", :blue

        check_npm_installation
        install_tailwind_dependencies
        create_tailwind_config
        create_css_file
        setup_build_process

        if ask_setup_procfile?
          invoke :setup
        end

        say "\n✨ TailwindCSS installation completed successfully!", :green
        say "\n👉 You can now run:", :blue
        say "  bundle exec tailwind build  - To build your CSS", :cyan
        say "  bundle exec tailwind watch  - To watch for CSS changes", :cyan
        say "  bundle exec tailwind setup  - To setup Procfile.dev", :cyan if !File.exist?("Procfile.dev")
      rescue Error => e
        say "\n❌ Error: #{e.message}", :red
        exit 1
      end

      desc "build", "Build TailwindCSS files"
      def build
        if system("which npm > /dev/null 2>&1")
          say "\n🔨 Building CSS files...", :blue
          if system("npm run build:css")
            say "✨ CSS build completed successfully!", :green
          else
            say "\n❌ Error: Failed to build CSS", :red
            exit 1
          end
        else
          say "\n❌ Error: NPM is not installed", :red
          exit 1
        end
      end

      desc "watch", "Watch for CSS changes and rebuild"
      def watch
        if system("which npm > /dev/null 2>&1")
          say "\n👀 Watching for changes...", :blue
          exec("npx tailwindcss -i ./public/css/application.css -o ./public/css/application.min.css --watch")
        else
          say "\n❌ Error: NPM is not installed", :red
          exit 1
        end
      end

      desc "setup", "Setup Procfile.dev for development"
      def setup
        if File.exist?("Procfile.dev")
          if yes?("\n⚠️  Procfile.dev already exists. Do you want to override it?", :yellow)
            create_procfile
            create_dev_script
          end
        else
          create_procfile
          create_dev_script
        end

        say "\n✨ Development environment setup completed!", :green
        say "\n👉 To start your development server, run:", :blue
        say "  ./bin/dev", :cyan
      end

      private

      def ask_setup_procfile?
        prompt = TTY::Prompt.new(enable_color: true)
        prompt.yes?("\n🤔 Would you like to setup a Procfile.dev for development? (y/n)", default: true)
      end

      def create_procfile
        say "\n📝 Creating Procfile.dev...", :blue

        content = <<~PROCFILE
          web: bundle exec rackup -p ${PORT:-9292}
          css: bundle exec tailwind watch
        PROCFILE

        create_file "Procfile.dev", content

        if !system("which foreman > /dev/null 2>&1")
          say "\n⚠️  Note: You need to install foreman to use Procfile.dev", :yellow
          say "  Run: gem install foreman", :cyan
        end

        say "✨ Procfile.dev created successfully!", :green
      end
    end
  end
end
