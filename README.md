# Sinatra::Tailwind

Seamlessly integrate TailwindCSS into your Sinatra applications with a streamlined development workflow.

## Overview

Sinatra::Tailwind bridges the elegance of Sinatra with the power of TailwindCSS, providing a cohesive development experience. This gem offers:

- 🚀 Quick setup with sensible defaults
- 🔄 Live CSS reloading during development
- 🛠 Production-ready CSS optimization
- 📦 Zero configuration required
- 🎨 Full access to TailwindCSS features
- ⚡️ Optimized build process

## Installation

Add the gem to your Gemfile:

```ruby
gem 'sinatra-tailwind'
```

Then run:

```bash
bundle install
```

Or install directly via:

```bash
gem install sinatra-tailwind
```

## Quick Start

1. Install TailwindCSS in your project:

```bash
bundle exec tailwind install
```

2. Add the stylesheet to your layout:

```erb
<!-- views/layout.erb -->
<link rel="stylesheet" href="/css/application.min.css">
```

3. Start using TailwindCSS classes in your views:

```erb
<div class="container mx-auto px-4">
  <h1 class="text-3xl font-bold text-gray-900">
    Welcome to <%= @title %>
  </h1>
</div>
```

## Development Workflow

Sinatra::Tailwind provides a seamless development experience:

```bash
# Start development server with live reloading
foreman start -f Procfile.dev

# Build optimized CSS for production
bundle exec tailwind build
```

## Features

### Live Reloading

Changes to your views and CSS are automatically reflected in your browser, making development faster and more efficient.

### Production Optimization

When building for production, your CSS is automatically:

- Minified for smaller file sizes
- Purged of unused styles
- Optimized for performance

### Customization

Need to customize TailwindCSS? The configuration is fully accessible:

```bash
# Generate a tailwind.config.js file
bundle exec tailwind setup
```

## Best Practices

### Directory Structure

We recommend organizing your Sinatra application like this:

```
my-app/
├── app.rb
├── Procfile.dev          # Development process manager
├── views/
│   └── layout.erb       # Your main layout file
└── public/
    └── css/
        ├── application.css     # Your source CSS
        └── application.min.css # Generated CSS
```

### Examples

A typical Sinatra application using this gem:

```ruby
# app.rb
require 'sinatra'
require 'sinatra/tailwind'

class MyApp < Sinatra::Base
  register Sinatra::Tailwind

  get '/' do
    erb :index
  end
end
```

## Support

- 📘 [Documentation](https://github.com/aristotelesbr/sinatra-tailwind/wiki)
- 🐛 [Issue Tracker](https://github.com/aristotelesbr/sinatra-tailwind/issues)
- 💬 [Discussions](https://github.com/aristotelesbr/sinatra-tailwind/discussions)

## Contributing

We welcome contributions! Please check our [Contributing Guide](CONTRIBUTING.md) for guidelines.

## License

This gem is available as open source under the terms of the [MIT License](LICENSE).
