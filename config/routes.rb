Rails.application.routes.draw do

  root 'static_pages#home'
#   root 'daysheet#index'
#  root :to => "static_pages#rmm_home", :constraints => { :domain => "renewmymeds.ca" }

  devise_for :users, controllers: { registrations: "my_registrations" }
  get '/users/', to: 'users#index'
  get '/switch_to/:id', to: 'users#switch_to', as: :switch_user
#  get  '/switch_to/:id', to: 'sessions#switch_to', as: :switch_user

  get '/ra_messages/index(/:id)' => 'ra_messages#find', constraints: { query_string: /findstr/ }
  get 'ra_messages/index'
  
  get '/forms/index(/:id)' => 'forms#find', constraints: { query_string: /findstr/ }
  get '/forms/index'

  get '/claims/index(/:id)' => 'claims#find', constraints: { query_string: /findstr/ }
  get '/claims/index' 
  post '/claims/index' 

  get '/charts/index' => 'charts#find', constraints: { query_string: /findstr/ }
  get '/charts/index'

  get '/daily_charts/index' => 'daily_charts#find', constraints: { query_string: /findstr/ }
  get '/daily_charts/index'
  post '/daily_charts/index'
  get '/drugs/index' => 'drugs#find', constraints: { query_string: /findstr/ }
  get '/drugs/index' 
  get '/providers/index' => 'providers#find', constraints: { query_string: /findstr/ }
  get '/providers/index' 
  get '/reports/index' => 'reports#find', constraints: { query_string: /findstr/ }
  get '/reports/index' 
  get '/procedures/index' => 'procedures#find', constraints: { query_string: /findstr/ }
  get '/procedures/index' 
  get '/diagnoses/index' => 'diagnoses#find', constraints: { query_string: /findstr/ }
  get '/diagnoses/index' 
  get '/doctors/index' => 'doctors#find', constraints: { query_string: /findstr/ }
  get '/doctors/index' 
  
  post '/set_doctor', to: 'daysheet#set_doctor'
  get '/set_doctor', to: 'daysheet#set_doctor' 
  
  get '/daysheet/index', to: 'daysheet#index', as: :daysheet
  get '/vaccines/index', to:  "vaccines#find", constraints: { query_string: /findstr/ }
  get '/vaccines/index' 
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/news', to: 'static_pages#news'
  get  '/terms', to: 'static_pages#terms'
  get  '/privacy', to: 'static_pages#privacy'

  post  '/patients(/:id)/card', to: 'patients#card'
  get '/patients(/:id)/card', to: 'patients#card'

  get '/visits' => 'visits#daysheet', constraints: { query_string: /date/ }
  get '/visits' => 'visits#index'
  get '/billings' => 'billings#index'
  post '/billings/export_csv', to: 'billings#export_csv'
  post '/billings/export_edt', to: 'billings#export_edt'
  post '/billings/export_cabmd', to: 'billings#export_cabmd'
  get "/procedures/get_by_code", to: "procedures#get_by_code" 
  get "/procedures/get", to: "procedures#get" 
  get "/drugs/get", to: "drugs#get" 

  get "/patients/get", to: "patients#get"
  post "/users/lookup", to: "users#lookup"  # lookup by dob and last 4 digits of HC
  
  resources :users
  resources :patients do
    get 'label', on: :member
    get 'addrlabel', on: :member
    get 'chart', on: :member
    get 'visit_history', on: :member
    resources :invoices do
      get 'invoice', on: :member
    end
    resources :letters, :referrals, :charts, :medications, :prescriptions, :patient_docs
    resources :visits do  # , shallow: true         #, only: [:show, :create, :destroy, :new, :index]
      get 'visitform', on: :member
      get 'receipt', on: :member
      get 'sendclaim', on: :member
      get 'addcash', on: :member
      get 'addvoicenote', on: :member
      get 'cancel', on: :member
      resources :documents
    end
  end
  
  resources :ra_messages, :ra_accounts, :ra_errcodes, :doctors, :diagnoses, :procedures, :providers, 
	    :drugs, :vaccines, :export_files, :claim_errors

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  resources :claims do
    resources :services
  end

  get 'budget', to: 'paystubs#budget'
  get 'billed_visits', to: 'billings#billed_visits_this_cycle'
  get 'unpaid_visits', to: 'visits#unpaid_visits'
  
  resources :edt_files, :forms, :invoices, :letters, :referrals, :daily_charts, :charts, :prescriptions, :paystubs, :reports  do
     get 'download', on: :member
     get 'export', on: :member
  end

  resources :schedules

# resources :billings     # historical billing table - not used
  
end
