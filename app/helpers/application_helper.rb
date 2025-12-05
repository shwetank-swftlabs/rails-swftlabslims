module ApplicationHelper
  #
  # Converts base, sub, sup into HTML-safe formatted variable notation
  #
  def var(base, sub = nil, sup = nil)
    html = +"<span class='var-symbol' style='text-transform: none;'>#{ERB::Util.html_escape(base)}"
    html << "<sub>#{ERB::Util.html_escape(sub)}</sub>" if sub.present?
    html << "<sup>#{ERB::Util.html_escape(sup)}</sup>" if sup.present?
    html << "</span>"
    html.html_safe
  end

  #
  # Store symbol *components*, not lambdas or HTML
  #
  FIELD_SYMBOLS = {
    "m_F"                => ["m", "F"],
    "u_F"                => ["u", "F"],
    "V_H"                => ["V", "H"],
    "c_H"                => ["c", "H"],
    "c_H_prime"          => ["c", "H", "'"],
    "V_H_prime"          => ["V", "H", "'"],
    "c_H_double_prime"   => ["c", "H", "''"],
    "V_H_double_prime"   => ["V", "H", "''"],
    "R_M"                => ["R", "M"],
    "V_Q"                => ["V", "Q"],
    "V_cE"               => ["V", "cE"],
    "pH_cE"              => ["pH", "cE"],
    "V_dE"               => ["V", "dE"],
    "pH_dE"              => ["pH", "dE"],
    "m_solid"            => ["m", "solid"],
    "u_solid"            => ["u", "solid"],
    "pH_solid"           => ["pH", "solid"],
    "t_R"                => ["t", "R"]
  }.freeze

  #
  # Render a symbol by looking up its base/sub/sup
  #
  def field_symbol(key)
    base, sub, sup = FIELD_SYMBOLS[key]
    return unless base
    var(base, sub, sup)
  end

  def email_to_name(email)
    email.split("@").first.humanize || email
  end
end
