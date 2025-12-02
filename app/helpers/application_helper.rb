module ApplicationHelper
  #
  # Converts base, sub, sup into HTML-safe formatted variable notation
  #
  def var(base, sub = nil, sup = nil)
    html = +"<span class='var-symbol'>#{ERB::Util.html_escape(base)}"
    html << "<sub>#{ERB::Util.html_escape(sub)}</sub>" if sub.present?
    html << "<sup>#{ERB::Util.html_escape(sup)}</sup>" if sup.present?
    html << "</span>"
    html.html_safe
  end

  #
  # Store symbol *components*, not lambdas or HTML
  #
  FIELD_SYMBOLS = {
    "c_H_prime"          => ["c", "H", "'"],
    "V_H_prime"          => ["V", "H", "'"],
    "c_H_double_prime"   => ["c", "H", "''"],
    "V_H_double_prime"   => ["V", "H", "''"]
  }.freeze

  #
  # Render a symbol by looking up its base/sub/sup
  #
  def field_symbol(key)
    base, sub, sup = FIELD_SYMBOLS[key]
    return unless base
    var(base, sub, sup)
  end
end
