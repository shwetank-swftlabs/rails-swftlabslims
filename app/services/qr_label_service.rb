# app/services/qr_label_service.rb
require "prawn"
require "rqrcode"
require "rqrcode_png"

class QrLabelService
  MM_TO_PT = 2.83465
  LABEL_WIDTH_MM  = 90     # 90mm wide
  LABEL_HEIGHT_MM = 29     # 29mm tall

  def initialize(resource:, url:, text_lines:, title: nil)
    @resource   = resource
    @url        = url
    @text_lines = text_lines
    @title      = title
  end

  def generate_pdf
    qr_png = generate_qr_png
    pdf    = build_pdf(qr_png)
    pdf.render
  end

  private

  # --------------------------------
  # DIMENSIONS
  # --------------------------------
  def label_width_pt   = LABEL_WIDTH_MM  * MM_TO_PT
  def label_height_pt  = LABEL_HEIGHT_MM * MM_TO_PT

  def qr_box_size_pt
    # QR is full height 29mm × 29mm
    label_height_pt
  end

  # --------------------------------
  # QR CODE GENERATION
  # --------------------------------
  def generate_qr_png
    qr = RQRCode::QRCode.new(
      @url,
      level: :h,
      size: 6
    )

    qr.as_png(
      resize_gte_to: 500,
      resize_exactly_to: false,
      fill: "white",
      color: "black",
      border_modules: 4
    )
  end

  # --------------------------------
  # PDF BUILDING (NO ROTATION)
  # --------------------------------
  def build_pdf(qr_png)
    Prawn::Document.new(
      page_size: [label_width_pt, label_height_pt],
      margin: 0
    ) do |pdf|

      pdf.font("Courier", style: :bold)

      # -----------------------------
      # QR CODE ON LEFT SIDE
      # -----------------------------
      pdf.image StringIO.new(qr_png.to_s),
                at: [0, label_height_pt],
                width:  qr_box_size_pt,
                height: qr_box_size_pt

      # -----------------------------
      # TEXT AREA PLACEMENT
      # -----------------------------
      text_box_x     = qr_box_size_pt + (2 * MM_TO_PT) # 2mm padding
      text_box_width = label_width_pt - text_box_x - (2 * MM_TO_PT)

      pdf.bounding_box(
        [text_box_x, label_height_pt - (2 * MM_TO_PT)],
        width: text_box_width,
        height: label_height_pt - (4 * MM_TO_PT)
      ) do

        # -----------------------------
        # TITLE (ALL CAPS, PROMINENT)
        # -----------------------------
        if @title.present?
          pdf.text @title.to_s.upcase,
                   size: 12,
                   style: :bold,
                   leading: 3
          pdf.move_down 3
        end

        # -----------------------------
        # BODY TEXT
        # -----------------------------
        @text_lines.each do |line|
          pdf.text line.to_s, size: 10, leading: 1
        end
      end

    end
  end
end
