require 'rails/engine'

module InlineEditable
  class Engine < Rails::Engine
    initializer 'inline_editable' do
      ActiveSupport.on_load(:action_view) { include InlineEditable::Helper }
    end
  end
end
