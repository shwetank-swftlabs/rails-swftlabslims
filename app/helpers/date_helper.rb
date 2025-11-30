module DateHelper
  def format_date(date)
    date.present? ? date.strftime("%b %d %Y") : "N/A"
  end
end
