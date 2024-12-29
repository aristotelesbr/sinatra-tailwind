require "fileutils"
require "json"
require "logger"

module Sinatra
  module Tailwind
    module Setup
      def check_npm_installation
        unless system("which npm > /dev/null 2>&1")
          raise Error, "NPM is not installed. Please install Node.js and NPM first."
        end
      end

      def install_tailwind_dependencies
        if !File.exist?("package.json")
          log_info "📦 Initializing new Node.js project..."

          package_json = {
            "name" => "tailwind-app",
            "version" => "1.0.0",
            "private" => true,
            "dependencies" => {},
            "devDependencies" => {}
          }

          File.write("package.json", JSON.pretty_generate(package_json))
        end

        begin
          package_json = JSON.parse(File.read("package.json"))

          if !package_json.dig("dependencies", "tailwindcss")
            log_info "📦 Installing TailwindCSS..."
            if !system("npm install tailwindcss@latest --save --legacy-peer-deps")
              raise Error, "Failed to install TailwindCSS"
            end
          end

          dev_dependencies = package_json["devDependencies"] || {}
          needed_dev_deps = ["postcss", "autoprefixer"] - dev_dependencies.keys

          if !needed_dev_deps.empty?
            log_info "📦 Installing development dependencies..."
            if !system("npm install #{needed_dev_deps.join(" ")} --save-dev --legacy-peer-deps")
              raise Error, "Failed to install development dependencies"
            end
          end

          package_json = JSON.parse(File.read("package.json"))

          clean_deps = {"tailwindcss" => package_json.dig("dependencies", "tailwindcss")}
          package_json["dependencies"] = clean_deps

          dev_deps = package_json["devDependencies"] || {}
          clean_dev_deps = {
            "postcss" => dev_deps["postcss"],
            "autoprefixer" => dev_deps["autoprefixer"]
          }.compact
          package_json["devDependencies"] = clean_dev_deps

          File.write("package.json", JSON.pretty_generate(package_json))

          if !system("npm install --legacy-peer-deps")
            raise Error, "Failed to reinstall dependencies"
          end
        rescue JSON::ParserError => e
          raise Error, "Failed to parse package.json: #{e.message}"
        rescue => e
          raise Error, "An error occurred during dependency installation: #{e.message}"
        end
      end

      def create_tailwind_config
        return if File.exist?("tailwind.config.js")

        log_info "🔧 Creating Tailwind configuration..."
        config_content = <<~JS
          module.exports = {
            content: [
              './views/**/*.{erb,haml,slim}',
              './public/**/*.{html,js}'
            ],
            theme: {
              extend: {},
            },
            plugins: [],
          }
        JS

        File.write("tailwind.config.js", config_content)
      end

      def create_css_file
        css_dir = "public/css"
        css_file = "#{css_dir}/application.css"
        return if File.exist?(css_file)

        log_info "🎨 Creating CSS file..."
        FileUtils.mkdir_p(css_dir)
        css_content = <<~CSS
          @tailwind base;
          @tailwind components;
          @tailwind utilities;
        CSS

        File.write(css_file, css_content)
      end

      def setup_build_process
        package_json = File.exist?("package.json") ? JSON.parse(File.read("package.json")) : {}
        package_json["scripts"] ||= {}
        package_json["scripts"]["build:css"] = "tailwindcss -i ./public/css/application.css -o ./public/css/application.min.css --minify"

        File.write("package.json", JSON.pretty_generate(package_json))
        log_info "⚙️  Added build script to package.json"
      end

      private

      def log_info(message)
        logger.info(message)
      end

      def logger
        @logger ||= Logger.new($stdout)
      end
    end
  end
end
