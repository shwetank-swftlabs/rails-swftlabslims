Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :health_check

  # Authentication routes
  get "/login", to: "sessions#new"
  get "/auth/google_oauth2/callback", to: "sessions#create"

  root "application#index"
end
