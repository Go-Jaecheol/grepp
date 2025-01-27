Rails.application.routes.draw do
  resources :reservations do
    collection do
      get :available
    end
  end
end
