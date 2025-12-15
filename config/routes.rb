Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :health_check

  # Authentication routes
  get "/login", to: "sessions#new"
  get "/auth/google_oauth2/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  root "application#index"

  # Top level routes
  get "/experiments", to: "experiments#index", as: :experiments
  get "/inventory", to: "inventory#index", as: :inventory
  get "/products", to: "products#index", as: :products
  get "/admin", to: "admin#index", as: :admin
  get "/inventory/cakes/:id", to: "products/cakes#redirect_to_index"


  # Admin routes
  namespace :admin do
    resources :equipment_types, only: [:index, :new, :create, :edit, :update] 
    resources :chemical_types, only: [:index, :new, :create, :edit, :update]
    resources :feedstock_types, only: [:index, :new, :create, :edit, :update]
    resources :nop_reaction_types, only: [:index, :new, :create, :edit, :update]
    resources :qnc_checks_configs, only: [:index, :new, :create, :edit, :update]
  end

  # Experiments routes
  namespace :experiments do
    resources :nop_processes, only: [:index, :show, :edit, :update] do
      collection do
        match :select_if_standalone_batch, via: [:get, :post]

        get :new_standalone_batch
        post :create_standalone_batch

        get :new_effluent_reuse_batch
        post :create_effluent_reuse_batch

        get :batch_number
      end
      resources :images, only: [:create, :show], controller: "/images"
      resources :comments, only: [:create, :update], controller: "/comments"
      resources :data_files, only: [:create, :show], controller: "/data_files"
    end

    resources :qnc_checks, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        get :qr_code
        patch :mark_completed
      end

      resources :comments, only: [:create, :update], controller: "/comments"
      resources :data_files, only: [:create, :show], controller: "/data_files"
    end 
  end

  # Inventory routes (proper namespace)
  namespace :inventory do
    resources :equipments, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        get :qr_code
      end 

      resources :images, only: [:create, :show], controller: "/images"
      resources :comments, only: [:create, :update], controller: "/comments"
    end

    resources :chemicals, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        get :qr_code
      end

      resources :comments, only: [:create, :update], controller: "/comments"
      resources :usages, only: [:create, :index, :update], controller: "/usages"
    end

    resources :feedstocks, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        get :qr_code
      end

      resources :images, only: [:create, :show], controller: "/images"
      resources :images, only: [:create, :show], controller: "/images"
      resources :comments, only: [:create, :update], controller: "/comments"
      resources :usages, only: [:create, :index, :update], controller: "/usages"
      resources :data_files, only: [:create, :show], controller: "/data_files"
    end

    resources :library_samples, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        get :qr_code
      end

      resources :comments, only: [:create, :update], controller: "/comments"
    end
  end

  # Products routes
  namespace :products do
    resources :cakes, only: [:index, :new, :create, :show, :edit, :update] do
      member do
        get :qr_code
      end

      resources :images, only: [:create, :show], controller: "/images"
      resources :comments, only: [:create, :update], controller: "/comments"
      resources :data_files, only: [:create, :show], controller: "/data_files"
      resources :usages, only: [:create, :index, :update], controller: "/usages"
    end
  end
end
