if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
    key: "_swftlabslims_session",
    domain: ".swftserver.com", 
    same_site: :none,
    secure: true
else
  Rails.application.config.session_store :cookie_store,
    key: "_swftlabslims_session",
    same_site: :lax,
    secure: false
end
