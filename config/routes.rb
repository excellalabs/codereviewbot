Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'tests#main'

  mount Blazer::Engine, at: "blazer"
end
