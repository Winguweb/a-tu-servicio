Rails.application.routes.draw do
  root to: 'home#show'

  # Authentication
  resources :user_sessions, only: [:create, :destroy]

  delete '/sign_out', to: 'user_sessions#destroy', as: :sign_out
  get '/sign_in', to: 'user_sessions#new', as: :sign_in
  # ---

  # API
  scope '/api' do
    scope '/v1' do
      get '/branches/slug/:slug' => "branches#findBySlug"
      resources :branches, only: %i[index show]
      resources :surveys, only: %i[create]
    end
  end
  # ---
  match '/(departamento/:departamento)' => 'home#show', via: :get

  resources :providers do
    get :autocomplete_provider_search_name, on: :collection
  end

  get '/sobre-el-proyecto' => 'home#about', as: :about
  get '/mapa-de-servicios(/:id)' => 'home#services', as: :services
  get '/datos/descarga/csv/:model', action: :download_csv, controller: :home, as: :data_download_csv, constraints: { model: /(Branch|Provider|Satisfaction|Speciality|WaitingTime|Survey)/ }
  get '/datos/descarga/xls/:model', action: :download_xlsx, controller: :home, as: :data_download_xlsx, constraints: { model: /(Survey)/ }
  get '/datos/descarga/xls/todo', action: :download_all, controller: :home, as: :data_download_all
  get '/datasets' => 'home#datasets', as: :datasets

  get '/apple-touch-icon-precomposed.png', to: redirect('/assets/apple-touch-icon-precomposed.png')
end
