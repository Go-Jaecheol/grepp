Rails.application.routes.draw do
  post "/login", to: "auth#login"
  resources :reservations do
    get :available, on: :collection
    patch :confirm, on: :member
    patch :cancel, on: :member
  end
end
