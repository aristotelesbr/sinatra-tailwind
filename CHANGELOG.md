# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2024-12-29
### Added
- CLI commands for managing TailwindCSS installation and configuration:
  - `tailwind install` - Installs TailwindCSS and its dependencies
  - `tailwind build` - Builds CSS files
  - `tailwind watch` - Watches for CSS changes
  - `tailwind setup` - Sets up development environment
- Automatic TailwindCSS configuration with `tailwind.config.js`
- Development environment setup with Procfile.dev
- Automated NPM dependency management
- Basic CSS structure with TailwindCSS directives
- Development script (`bin/dev`) for easy project startup

### Dependencies
- Added Thor for CLI interface
- Added TTY::Prompt for interactive command line
- Added support for NPM package management

## [0.1.0] - 2024-12-29
- Initial release of sinatra-tailwind gem


