Rails.application.routes.draw do
  root to: 'home#show'

  scope '/api' do
    scope '/v1' do
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
  get '/mapa-de-servicios' => 'home#services', as: :services
  get '/datos/descarga/:model', action: :download, controller: :home, as: :donations_download, constraints: { model: /(Branch|Provider|Satisfaction|Speciality|WaitingTime|Survey)/ }
   

  get '/apple-touch-icon-precomposed.png', to: redirect('/assets/apple-touch-icon-precomposed.png')
end
