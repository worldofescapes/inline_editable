require 'rails/engine'

module ActiveadminEditable
  class Engine < ::Rails::Engine
    isolate_namespace ActiveadminEditable

    config.to_prepare do
      if defined?(ActiveAdmin)
        ActiveAdmin::BaseController.send :include, ActiveadminEditable::Helper
        ActiveAdmin::Views::Pages::Base.send :include, ActiveadminEditable::Helper
        ActiveAdmin::Views::IndexAsTable.send :include, ActiveadminEditable::Helper
      end
    end
  end
end
