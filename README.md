# Inline Editable

Inline editing for tables and custom endpoints with Stimulus.

## Features

- 📝 **Inline text editing** - Click to edit text fields directly in tables
- ☑️ **Checkbox support** - Toggle boolean values instantly  
- 📋 **Select dropdowns** - Choose from predefined options
- 🌐 **Custom URL support** - Works with any API endpoint
- 🎨 **Customizable styling** - Built-in CSS classes with override options
- ⚡ **Real-time updates** - Changes saved automatically via AJAX
- 🔒 **Error handling** - User-friendly error messages
- 🎯 **Accessibility** - ARIA labels and keyboard navigation

## Installation

### 1. Add the Ruby gem

Add to your `Gemfile`:

```ruby
gem 'inline_editable'
```

### 2. Add the JavaScript package

```bash
npm install inline-editable
# or
yarn add inline-editable
```

### 3. Setup JavaScript

In your JavaScript file (e.g., `app/assets/javascripts/application.js`):

```javascript
import { createInlineEditController } from 'inline-editable';
import { Application, Controller } from "@hotwired/stimulus";

const application = Application.start();
const InlineEditController = createInlineEditController(Controller);
application.register("inline-edit", InlineEditController);
```


## Usage

### Basic text field

```ruby
column :comment do |record|
  inline_edit(record, :comment)
end
```

### Select dropdown

```ruby
column :status do |record|
  inline_edit(record, :status, as: :select, collection: [
    ['Active', 'active'],
    ['Inactive', 'inactive'],
    ['Pending', 'pending']
  ])
end
```

### Custom URL endpoint

```ruby
# Using a custom URL instead of the default ActiveAdmin resource URL
column :status do |record|
  inline_edit(record, :status, url: '/api/v1/custom_update/123')
end
```

### Custom URL with dynamic parameters

```ruby
# Using a dynamic URL based on record attributes
column :price do |product|
  inline_edit(product, :price, url: "/api/products/#{product.id}/update_price")
end
```

### Using in any Rails views

```ruby
# In any Rails view
def render_editable_field(record, attribute)
  inline_edit(record, attribute, url: url_for([:api, record]))
end
```

### Checkbox

```ruby
column :is_active do |record|
  inline_edit(record, :is_active, as: :checkbox)
end
```

### With custom CSS classes

```ruby
column :priority do |record|
  inline_edit(record, :priority, css_class: 'priority-field')
end
```

## Field Types

| Type | Description | Example |
|------|-------------|---------|
| `:input` | Text field (default) | `inline_edit(record, :name)` |
| `:select` | Dropdown with options | `inline_edit(record, :status, as: :select, collection: options)` |
| `:checkbox` | Boolean toggle | `inline_edit(record, :active, as: :checkbox)` |

## Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `as` | Symbol | Field type (`:input`, `:select`, `:checkbox`) | `:input` |
| `collection` | Array | Options for select field `[['Label', 'value'], ...]` | `nil` |
| `css_class` | String | Additional CSS classes | `""` |

## Controller Requirements

Your controller must support JSON updates:

```ruby
# In your controller
controller do
  def update
    resource = MyModel.find(params[:id])
    if resource.update(permitted_params[:my_model])
      respond_to do |format|
        format.html { redirect_to resource_path(resource) }
        format.json { render json: { success: true, my_model: resource.as_json } }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { success: false, errors: resource.errors }, status: :unprocessable_entity }
      end
    end
  end
end
```

## Browser Support

- Modern browsers with ES2017+ support
- Requires Stimulus 3.0+

## Development

```bash
# Clone the repository
git clone https://github.com/worldofescapes/inline_editable.git

# Install dependencies
bundle install
npm install

# Build the JavaScript package
npm run build
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
