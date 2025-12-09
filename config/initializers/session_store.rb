if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
    key: "_swftlabslims_session",
    domain: "swftlabslims.com", 
    expires_after: 24.hours,
    same_site: :none,
    secure: true
else if Rails.env.staging?
  Rails.application.config.session_store :cookie_store,
    key: "_swftlabslims_session",
    domain: ".swftserver.com", 
    expires_after: 24.hours,
    same_site: :none,
    secure: true
else
  Rails.application.config.session_store :cookie_store,
    key: "_swftlabslims_session",
    domain: ".localhost", 
    expires_after: 24.hours,
    same_site: :lax,
    secure: false
end
