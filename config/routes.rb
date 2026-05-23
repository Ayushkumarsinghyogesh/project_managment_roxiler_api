Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Auth
      post   "auth/register", to: "auth#register"
      post   "auth/login",    to: "auth#login"
      get    "auth/me",       to: "auth#me"

      # Projects
      resources :projects, only: %i[index show create update destroy]

      # Tasks — standalone list + create; also nested under projects for context
      resources :tasks, only: %i[index show create update destroy]

      resources :projects, only: [] do
        resources :tasks, only: %i[index create], shallow: true
      end
    end
  end
end
