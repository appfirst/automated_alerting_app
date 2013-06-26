AppfirstAlerting::Application.routes.draw do
  resources :requests


  resources :alerts

  root :to => "alerts#index"
  match "/call" => "application#call", :via => :get
  match "/init" => "application#init", :via => :get
  match "/new_alert" => "alerts#new"
  match "/new_request" => "requests#new"
  match "/populate_database" => "application#populate_database"

end
