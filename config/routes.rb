Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
	get '/open', to: 'helper#open'
	get '/all_doctors', to: 'helper#all_doctors'
	get '/all_patients', to: 'helper#all_patients'
	get '/calcelled_appoitments', to: 'helper#cancelled_appoitments'
	post '/book', to: 'helper#book'
end
