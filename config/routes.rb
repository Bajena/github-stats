Rails.application.routes.draw do
  resources :repositories do
    get "more", on: :collection
  end
  resources :issues
  resources :users
  get "/", to: redirect("/users")
end
