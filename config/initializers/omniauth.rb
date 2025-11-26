Rails.application.config.middleware.use OmniAuth::Builder do
  google = Rails.application.credentials.google || {}
  provider :google_oauth2, 
            google['client_id'],
            google['client_secret'],
           {
            scope: 'openid,profile,email',
            prompt: 'select_account',
            access_type: 'online',
           }
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true