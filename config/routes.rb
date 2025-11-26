Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :health_check

  root "application#index"
end
