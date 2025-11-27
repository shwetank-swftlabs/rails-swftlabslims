module PageHelper
  def page_title
    @breadcrumbs&.last&.dig(:name) || ''
  end
end