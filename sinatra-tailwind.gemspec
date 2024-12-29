# frozen_string_literal: true

require_relative "lib/sinatra/tailwind/version"

Gem::Specification.new do |spec|
  spec.name = "sinatra-tailwind"
  spec.version = Sinatra::Tailwind::VERSION
  spec.summary = "Automated TailwindCSS integration for Sinatra applications"
  spec.authors = ["Aristóteles"]
  spec.license = "MIT"

  spec.homepage = "https://github.com/aristotelesbr/sinatra-tailwind"
  spec.description = "Integrate TailwindCSS in a Sinatra project"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "homepage_uri" => spec.homepage + "#readme"
  }

  spec.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE.txt README.md]
  spec.bindir = "exe"
  spec.executables = ["tailwind"]
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", "~> 3.0"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "tty-prompt", "~> 0.23.1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.3"
end
