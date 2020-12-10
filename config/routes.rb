Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
	get '/open', to: 'helper#open'

	get '/all_patients', to: 'helper#all_patients'

	get '/all_doctors', to: 'helper#all_doctors'

	post '/create_appoitment', to: 'helper#create_appoitment'

	get '/get_all_appoitments', to: 'helper#get_all_appoitments'

	get '/get_appoitment', to: 'helper#get_appoitment'

	put '/update_appointment_status', to: 'helper#update_appointment_status'

	get '/find_all_charts', to: 'helper#find_all_charts'

	get '/download_chart', to: 'helper#download_chart'

	get '/generate_report', to: 'helper#generate_report'

	get '/cancelled_appoitments', to: 'helper#cancelled_appoitments'

  	get '/get_billing_codes', to: 'helper#get_billing_codes'

	post '/post_billing_codes', to: 'helper#post_billing_codes'

	get '/download_consultation_summary', to: 'helper#download_consultation_summary'

	post '/upload_consultation_summary', to: 'helper#upload_consultation_summary'

  	post '/upload_charts', to: 'helper#upload_charts'

	delete '/cancel_appoitment', to: 'helper#cancel_appoitment'

	get '/single_patient_info', to: 'helper#single_patient_info'
	
	#get '/all_slots', to: 'helper#all_slots'


  #### TELEVISIT APIS ROUTES###
  	
  	#post '/create_session', to: 'helper#create_session'

	get '/get_session', to: 'helper#get_session'

  	get '/start_session', to: 'helper#start_session'

  	get '/end_session', to: 'helper#end_session'

  	delete '/cancel_session', to: 'helper#cancel_session'

  	get '/get_billing_time', to: 'helper#get_billing_time'

end
