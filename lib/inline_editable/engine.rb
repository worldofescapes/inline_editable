require 'rails/engine'

module InlineEditable
  class Engine < ::Rails::Engine
    isolate_namespace InlineEditable

    config.to_prepare do
      if defined?(ActiveAdmin)
        ActiveAdmin::BaseController.send :include, InlineEditable::Helper
        ActiveAdmin::Views::Pages::Base.send :include, InlineEditable::Helper
        ActiveAdmin::Views::IndexAsTable.send :include, InlineEditable::Helper
      end
    end
  end
end
