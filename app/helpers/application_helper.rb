module ApplicationHelper
  def var(base, sub = nil, sup = nil)
    html = "<span class='var-symbol'>#{ERB::Util.html_escape(base)}"

    html += "<sub>#{ERB::Util.html_escape(sub)}</sub>" if sub.present?
    html += "<sup>#{ERB::Util.html_escape(sup)}</sup>" if sup.present?

    html += "</span>"

    html.html_safe
  end
end
