<div align="center">
  <h1>Sinatra::Tailwind</h1>
  <p>Simple TailwindCSS integration for Sinatra applications.</p>

  <img src="logo.png" alt="Sinatra Tailwind" width="400">
</div>

## Overview

Sinatra::Tailwind provides zero-configuration TailwindCSS setup for Sinatra applications. This gem offers:

- 🚀 Instant setup with smart defaults
- 🔄 Automatic CSS reloading
- 🛠 Production-ready builds
- 📦 Zero configuration
- 🎨 Full TailwindCSS features

## Installation

Add to your Gemfile:

```ruby
gem 'sinatra-tailwind'
```

Then run:

```bash
bundle install
bundle exec tailwind install
```

## Usage

1. Add the stylesheet to your layout:

```erb
<!-- views/layout.erb -->
<link rel="stylesheet" href="/css/application.min.css">
```

2. Use TailwindCSS in your views:

```erb
<div class="container mx-auto p-4">
  <h1 class="text-3xl font-bold">Hello World</h1>
</div>
```

## Development

Start the development server:

```bash
./bin/dev
```

Or manually:

```bash
bundle exec tailwind watch  # Watch CSS changes
bundle exec ruby app.rb     # Run Sinatra server
```

## Commands

```bash
tailwind install  # Install TailwindCSS
tailwind watch   # Watch for changes
tailwind build   # Build for production
tailwind setup   # Configure development
```

## Project Structure

```
my-app/
├── app.rb
├── Procfile.dev
├── bin/
│   └── dev
├── views/
│   └── layout.erb
└── public/
    └── css/
        ├── application.css
        └── application.min.css
```

## Configuration

TailwindCSS configuration is available in `tailwind.config.js`:

```js
module.exports = {
  content: ['./views/**/*.{erb,haml,slim}', './public/**/*.{html,js}'],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

## Example Application

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

Bug reports and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT License](LICENSE)
