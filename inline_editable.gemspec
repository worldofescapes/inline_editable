require_relative "lib/inline_editable/version"

Gem::Specification.new do |spec|
  spec.name        = "inline_editable"
  spec.version     = InlineEditable::VERSION
  spec.authors     = ["Alan", "mr-koww"]
  spec.email       = ["alan-eng@yandex.ru", "mr-koww@yandex.ru"]
  spec.summary     = "Inline editing for ActiveAdmin and custom URLs"
  spec.description = "Add inline editing capabilities to ActiveAdmin tables and any custom URL endpoints"
  spec.homepage    = "https://github.com/worldofescapes/activeadmin_editable"
  spec.license     = "MIT"

  spec.files = Dir["{lib}/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "activeadmin", ">= 2.0"

  spec.add_development_dependency "rspec-rails"
end
