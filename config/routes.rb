Rails.application.routes.draw do
  get '/' => 'home#index', as: :home

  get '/api/v1/branches' => 'branches#index'
  get '/api/v1/branches/:id' => 'branches#show'
  # ---
  match '/(departamento/:departamento)' => 'home#index', via: :get

  get '/comparar' => 'compare#index'
  get '/comparar/:selected_providers' => 'compare#index', as: :compare
  get '/agregar' => 'compare#add'

  resources :providers do
    get :autocomplete_provider_search_name, on: :collection
  end

  get '/sobre-el-proyecto' => 'home#about', as: :about
  get '/mapa-de-servicios' => 'home#services', as: :services

  get '/404' => 'errors#not_found'
  get '/500' => 'errors#internal_server_error'

  get '/apple-touch-icon-precomposed.png', to: redirect('/assets/apple-touch-icon-precomposed.png')
end
