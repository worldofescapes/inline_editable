module ActiveadminEditable
  module Helper
    def inline_edit(record, attribute, options = {})
      value = record.send(attribute)
      as_type = options[:as] || :input
      unique_id = "inline-edit-#{SecureRandom.hex(6)}"
      
      content_tag(:div, data: build_common_attributes(record, attribute, value, as_type, options)) do
        safe_join([
          build_display_element(as_type, value, options, unique_id),
          build_edit_form(as_type, attribute, value, options, unique_id),
          build_error_element
        ].compact)
      end
    end
    
    private
    
    def build_common_attributes(record, attribute, value, as_type, options)
      attrs = {
        controller: "inline-edit",
        "inline-edit-url-value" => url_for([:qs_admin, record]),
        "inline-edit-field-value" => attribute.to_s,
        "inline-edit-original-value" => value.to_s
      }
      
      attrs["inline-edit-field-type-value"] = as_type.to_s if as_type != :input
      attrs["inline-edit-collection-value"] = options[:collection].to_json if options[:collection].present?
      
      attrs
    end
    
    def build_display_element(as_type, value, options, unique_id)
      css_class = "inline-edit-display #{options[:css_class] || ''}"
      display_value = format_display_value(as_type, value, options[:collection])
      
      if as_type == :checkbox
        [
          content_tag(:span, "", 
            class: css_class,
            style: "display: none;",
            data: { "inline-edit-target" => "display" }
          ),
          build_checkbox(value, unique_id, options[:attribute])
        ]
      else
        content_tag(:span, display_value, 
          class: css_class,
          style: "cursor: pointer; padding: 2px 5px; border-radius: 3px; transition: background-color 0.2s;",
          onmouseover: "this.style.backgroundColor='#f5f5f5';",
          onmouseout: "this.style.backgroundColor='';",
          data: { 
            "inline-edit-target" => "display",
            action: "click->inline-edit#showForm"
          }
        )
      end
    end
    
    def format_display_value(as_type, value, collection)
      case as_type
      when :checkbox
        build_checkbox(value, nil, nil)
      when :select
        if collection.present?
          item = collection.find { |i| i[0].to_s == value.to_s }
          item ? item[1] : (value.present? ? value : "-")
        else
          value.present? ? value : "-"
        end
      else
        value.present? ? value : "-"
      end
    end
    
    def build_checkbox(value, unique_id, attribute)
      checkbox_attrs = {
        "inline-edit-target" => "input",
        action: "change->inline-edit#submitFormAndHide"
      }
      
      check_box_tag(
        "inline_edit_#{attribute}",
        "1",
        value.present? && value.to_s != "0",
        id: unique_id,
        data: checkbox_attrs,
        style: "width: 18px; height: 18px; cursor: pointer;"
      )
    end
    
    def build_edit_form(as_type, attribute, value, options, unique_id)
      return nil if as_type == :checkbox
      
      content_tag(:div, class: "inline-edit-form", 
        data: { "inline-edit-target" => "form" },
        style: "display: none;") do
        
        safe_join([
          build_accessibility_label(attribute, unique_id),
          build_input_element(as_type, attribute, value, options, unique_id)
        ])
      end
    end
    
    def build_accessibility_label(attribute, unique_id)
      content_tag(:label, "Редактирование поля #{attribute}", 
        id: "#{unique_id}-label", 
        style: "position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0;"
      )
    end
    
    def build_input_element(as_type, attribute, value, options, unique_id)
      case as_type
      when :select
        build_select_element(attribute, value, options, unique_id)
      else
        build_text_field(attribute, value, unique_id)
      end
    end
    
    def build_select_element(attribute, value, options, unique_id)
      collection = options[:collection]
      
      options_html = if collection.present?
        collection.map do |val, label|
          selected = val.to_s == value.to_s ? ' selected="selected"' : ''
          # Используем атрибут data-html для передачи HTML
          # Экранируем кавычки в HTML
          escaped_html = label.to_s.gsub('"', '&quot;').gsub("'", '&#39;')
          "<option value=\"#{val}\"#{selected} data-html=\"#{escaped_html}\">#{label}</option>"
        end.join.html_safe
      end
      
      select_tag(
        "inline_edit_#{attribute}",
        options_html,
        id: unique_id,
        class: "default-select",
        "aria-labelledby" => "#{unique_id}-label",
        data: {
          action: "change->inline-edit#submitFormAndHide keydown->inline-edit#handleKeydown blur->inline-edit#hideForm",
          "inline-edit-target" => "input"
        },
        escape: false
      )
    end
    
    def build_text_field(attribute, value, unique_id)
      text_field_tag(
        "inline_edit_#{attribute}",
        value.present? ? value : "",
        id: unique_id,
        class: "inline-edit-input",
        "aria-labelledby" => "#{unique_id}-label",
        data: {
          # Используем только одно событие для отправки формы
          action: "keydown->inline-edit#handleKeydown focusout->inline-edit#submitFormAndHide",
          "inline-edit-target" => "input"
        }
      )
    end
    
    def build_error_element
      content_tag(:div, "", 
        class: "inline-edit-error", 
        style: "color: red; font-size: 12px; margin-top: 4px; display: none;",
        data: { "inline-edit-target" => "error" }
      )
    end
  end
end
