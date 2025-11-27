module FormHelper
  def default_form_field(f, field, label_text:, required: false, &block)
    render "shared/forms/default_form_field",
           f: f,
           field: field,
           label_text: label_text,
           required: required,
           &block
  end
end
