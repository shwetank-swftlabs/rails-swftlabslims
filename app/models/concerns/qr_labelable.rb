module QrLabelable
  extend ActiveSupport::Concern

  # Any model including this concern gets:
  #
  #   qr_label_pdf(url:, text_lines: default_label_text)
  #

  def qr_label_pdf(url:, title: default_label_title, text_lines: default_label_text)
    QrLabelService.new(
      resource: self,
      url: url,
      title: title,
      text_lines: text_lines,
    ).generate_pdf
  end

  # Models can override this if needed
  def default_label_text
    []
  end

  def default_label_title
    "QR CODE"
  end
end
