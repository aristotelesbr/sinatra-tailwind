require "sinatra/base"
require "json"
require "fileutils"
require "sinatra/tailwind/version"
require "sinatra/tailwind/setup"
require "sinatra/tailwind/cli"

module Sinatra
  module Tailwind
    class Error < StandardError; end

    class << self
      def registered(app)
        app.helpers Sinatra::Tailwind::Setup
      end
    end
  end

  register Tailwind
end
