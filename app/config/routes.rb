Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # modify endpoint paths so that it uses the /login endpoint for better readability
  root "search#index"
  resources :passwords, param: :token
  resources :users
  get "courses/query" => "courses#query", as: :courses_query
  resources :courses

  get "login" => "sessions#new", as: :new_session
  post "login" => "sessions#create", as: :session
  delete "logout" => "sessions#destroy", as: :logout

  get "user_guide", to: "user_guides#show"  # This will map to the 'show' action in UserGuidesController

  # Endpoints
  get "trends" => "trends#index", as: :trends
  get "search" => "search#index", as: :search
  get "compare" => "compare#index", as: :compare

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # configure endpoint for Letter Opener
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
