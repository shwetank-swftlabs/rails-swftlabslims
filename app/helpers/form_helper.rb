module FormHelper
  def default_form_field(f, field, label_text:, required: false, &block)
    render "shared/forms/default_form_field",
           f: f,
           field: field,
           label_text: label_text,
           required: required,
           &block
  end

  def inline_quantity_field(f, amount_field, amount_label, unit_field: nil, default_units: nil, unit_options: nil, required: false)
    # Default unit_options to ApplicationRecord::AMOUNT_UNITS if not provided
    unit_options ||= ApplicationRecord::AMOUNT_UNITS if defined?(ApplicationRecord::AMOUNT_UNITS)

    content_tag :div, class: "mb-3" do
      concat(
        content_tag(:label, class: "form-label fw-bold mb-1 d-block") do
          concat amount_label
          concat(content_tag(:span, " *", class: "text-danger")) if required
        end
      )

      # Flex container for inline elements
      concat(
        content_tag(:div, { class: "d-flex gap-2 align-items-center" }) do
          # Amount field
          req_attr = required ? { required: true } : {}
          concat(
            f.number_field(amount_field,
              { class: "form-control",
                placeholder: "Enter quantity",
                step: :any,
                min: 0,
                style: "max-width: 150px" }.merge(req_attr)
            )
          )

          # Unit field or default units display
          if unit_field.present? && unit_options.present?
            # Use unit_field as a select dropdown
            concat(
              f.select(unit_field,
                unit_options.is_a?(Hash) ? unit_options.map { |k, v| [v, k] } : unit_options,
                {},
                { class: "form-control", style: "max-width: 120px" }
              )
            )
          elsif default_units.present?
            # Display default_units as text
            concat(
              content_tag(:span, default_units, class: "ms-2")
            )
          end
        end
      )
    end
  end
end
