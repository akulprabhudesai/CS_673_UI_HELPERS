require 'net/http'
require 'json'
require 'rest-client'

class HelperController < ApplicationController
	#skip_before_action :verify_authenticity_token
	
	# GET /open
	# GET /open.json
	def open # mock api
		@start_date = Date.parse(params[:StartDate])
		#@start_date = Date.parse('2020/11/1')
  		@end_date = Date.parse(params[:EndDate])
  		#@end_date = params[:EndDate]
		#@end_date = Date.parse('2020/11/2')
  		@doctor_id = (params[:doctorID])
  		#@doctor_id = 1
  		if @end_date == nil
  			@days = 1
  		else
  			@end_date = Date.parse(@end_date.to_s)
  			@days = (@end_date - @start_date + 1).to_i
  		end
  		puts @start_date
  		puts @end_date
		
   		@result = []
  		
  		#calculate all available time slots between 9am to 5pm for each available day
  		while @days > 0
  			curr_date = []
  			@start_time = Time.parse('9:00', @start_date)
  			@end_time = Time.parse('17:00', @start_date)
			
  			while (@end_time - @start_time) > 0
  				slot = {}
  				slot[:title] = "Available"
  				slot[:startDate] = @start_date
  				slot[:startTime] = @start_time.strftime("%H:%M").to_s
  				slot[:endDate] = @start_date
  				@start_time = @start_time + (60*60)
  				slot[:endTime] = @start_time.strftime("%H:%M").to_s
  				curr_date.push(slot)
  			end

  			
  			@days = @days - 1
  			@start_date = @start_date + 1
			@result.push(curr_date)
 		end
 		render json: @result, status: 200
	end

	#Get patient name and id for all patients (external call) working
	def all_patients
		#response = RestClient.get 'https://web.njit.edu/~as2757/ControlPatientIntake/api.php', 
		#	 {Token:"0s4ijqfrAJs07JwcVcBS", Type:"APIR", Data:[]}.to_json
			result = []
			 response = RestClient::Request.execute(
  				method:  :get, 
  				url:     "https://web.njit.edu/~as2757/ControlPatientIntake/api.php",
  				payload: { Token:'0s4ijqfrAJs07JwcVcBS', Type:'APIR', Data:[]}.to_json
			)
		res = JSON.parse(response)
		res["ReturnData"]["patients"].each do |item|
			curr = {}
			patient = item["patient_first_name"].to_s + " " +  item["patient_last_name"].to_s
			id = item["patient_id"].to_s
			curr[:id] = id
			curr[:name] = patient
			result.push(curr) 
		end

		render :json => result 
	end

	#working
	def single_patient_info
		patient_id = params[:patient_id]
		result = []
		response = RestClient::Request.execute(
				method:  :get,
				url:     "https://web.njit.edu/~as2757/ControlPatientIntake/api.php",
				payload: { Token:'0s4ijqfrAJs07JwcVcBS', Type:'SPIRBPID', Data:{"patient_id":patient_id }}.to_json
		)
		res = JSON.parse(response)
		render :json => res["ReturnData"]
	end

	#Get doctor name and id for all doctor (external call) mock api
	# def all_doctors
	# 	@id = 1.to_i
	# 	@dr = []
	# 	@dr.push("Dr Dean Jones")
	# 	@dr.push("Dr Steve Smith")
	# 	@dr.push("Dr James Anderson")
	# 	@dr.push("Dr Trent Boult")
	# 	@dr.push("Dr John Mathews")
	# 	@result = []
	# 	for i in 1..5
	# 		curr = {}
	# 		curr[:id] = i.to_i
	# 		curr[:name] = @dr[i-1]
	# 		@result.push(curr) 
	# 		@id = @id + 1
	# 	end
	# 	render json: @result, status: 200
	# end

	def all_doctors
		response = RestClient::Request.execute(
				method:  :get,
				url:     "http://melange.online/Dr_app/Api_data_dr.php?dr=1"
		)

		render :json => response

	end

	#Create an appointment (working)
	def create_appoitment
		#tele_visit = "true"
		tele_visit = params[:tele_visit]
		
		#user_token = params[:user_token]
		patient_id = params[:patient_id]
		doctor_id = params[:doctor_id]
		start_time = params[:start_time]
		end_time = params[:end_time]
		
		curr = {}

    	curr["patient_id"] = patient_id.to_s
    	curr["doctor_id"] = doctor_id.to_s
    	curr["start_time"] = start_time
    	curr["end_time"] = end_time


		#puts curr
		resp = RestClient::Request.execute(
				method:  :get,
				url:     "https://web.njit.edu/~as2757/ControlPatientIntake/api.php",
				payload: { Token:'0s4ijqfrAJs07JwcVcBS', Type:'SPIRBPID', Data:{"patient_id":params[:patient_id] }}.to_json
		)
		
		res = JSON.parse(resp)
		# puts "res is "
		# puts res
		#byebug
		email = res["ReturnData"]["patient_emailid"]
		#puts "email is " + email
		#email = "vd276@njit.edu"

    	#appoitment[:appointment] = curr.json

    	#response = RestClient.post 'https://sdpm-appointment-service.herokuapp.com/appointment',
    	#{'patient_id' => patient_id, 'doctor_id' => doctor_id, 'start_time' => start_time, 'end_time' => end_time },
    	#	 {params: {tele_visit: tele_visit, user_token: user_token}}
	
		response = RestClient::Request.execute(
  		method:  :post,
				url:     "https://sdpm-appointment-service.herokuapp.com/appointment?tele_visit=#{tele_visit}&email=#{email}",
				payload: {appointment: curr},
  				#params: {tele_visit: tele_visit}
  				#payload: {appointment: patient_id.to_i, doctor_id: doctor_id.to_i, start_time: start_time, end_time: end_time }
			)
    	puts response
		render json: response, status: 201
	end

	#Get all appointments based on patient_id or doctor_id (working)
	def get_all_appoitments

		id = params[:id]
		#id = 18
		response = RestClient.get 'https://sdpm-appointment-service.herokuapp.com/appointment', {params: {doctor_id: id}}
    	render json: response
	end

	#Get an appointment by ID (working)
	def get_appoitment
		id = params[:id]
		#user_token = params[:user_token]
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}"

		response = RestClient::Request.execute(
  		method:  :get, 
				url:     url,
			)

		render :json => response
	end

	#Update appointment status: (working)
	def  update_appointment_status
		id = params[:id]
		#user_token = params[:user_token]
		appointment_status = params[:appointment_status]

		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}?appointment_status=#{appointment_status}"

		response = RestClient::Request.execute(
  		method:  :put, 
 			url:     url
		)

		render :json => response
	end

	#Upload charts for appointment (pending)
	# def upload_charts
	# 	user_token = params[:user_token]
	# 	url = 'https://sdpm-appointment-service.herokuapp.com/appointment/' + id.to_s + "/charts"
	# end

	#Find all charts for an appointment
	def find_all_charts #(working)
		id = params[:id]
		#user_token = params[:user_token]
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/charts"
		#user_token = params[:user_token]
		response = RestClient::Request.execute(
  		method:  :get, 
 			url:     url
		)
		render :json => response
	end


	#Download a chart for an appointment(working)
	def download_chart
		id = params[:id]
		chart_id = params[:chart_id]
		#user_token = params[:user_token]
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/charts/#{chart_id}"
		response = RestClient::Request.execute(
  		method:  :get, 
 			url:     url
		)
		res = response.headers[:content_disposition].to_s.split(";")
		puts res[1].to_s.split("=")[1]
		filename = res[1].to_s.split("=")[1]
		send_data response.body, filename: filename[1..(filename.length-2)], disposition: "attachment"
	end


	#Generate a report of an appointment (working)
	def generate_report
		id = params[:id]
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/report"
		response = RestClient::Request.execute(
  		method:  :get, 
 			url:     url
		)

		render :json => response
	end

	#this will give details of cancelled appoitments (working)
	def cancelled_appoitments
		doctor_id = params[:doctor_id]
		patient_id = params[:patient_id]
		url = ""

		if doctor_id != nil
			url = "https://sdpm-appointment-service.herokuapp.com/cancelled_appointments?doctor_id=#{doctor_id}"
		elsif patient_id != nil
			url = "https://sdpm-appointment-service.herokuapp.com/cancelled_appointments?patient_id=#{patient_id}"
		end
		response = RestClient::Request.execute(
				method:  :get,
				url:     url
		)

		render :json => response
	end

	#Get billing codes to an appointment (working)
	def get_billing_codes
		id = params[:id]
		#user_token = params[:user_token]
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/billing_codes"
		response = RestClient::Request.execute(
  		method:  :get,
 			url:     url
		)

		render :json => response
	end


	#Post billing codes to an appointment (working)
	def post_billing_codes
		id = params[:id]
		#user_token = params[:user_token]
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/billing_codes"
		response = RestClient::Request.execute(
  		method:  :post, 
 			url:     url,
 			payload: {billing_codes: params[:billing_codes].to_json}
		)

		render :json => response
	end

	#Download a consultation summary for an appointment (working)
	def download_consultation_summary
		id = params[:id]
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/consultation_summary?download_type=#{params[:type]}"

		response = RestClient::Request.execute(
  		method:  :get, 
 			url:     url
		)
		if params[:type] === "file"
			res = response.headers[:content_disposition].to_s.split(";")
			puts res[1].to_s.split("=")[1]
			filename = res[1].to_s.split("=")[1]
			send_data response.body, filename: filename[1..(filename.length-2)], disposition: "attachment"
		else
			render json: response
		end
	end

	# Upload consultation summary for appointment: (pending)
	# def  upload_consultation_summary
	# 	id = params[:id]
	# 	user_token = params[:user_token]
	# 	url = 'https://sdpm-appointment-service.herokuapp.com/appointment/' + id.to_s + "/consultation_summary"
	#
	# 	response = RestClient::Request.execute(
  # 			method:  :post,
  # 			url:     url.to_s,
  # 			params: {user_token: user_token}
	# 	)
	#
	# 	render :json => response
	# end

	#this will allow canceling the previosuly booked appoitment (pending)
	def cancel_appoitment
	
		appointment_id = params[:appointment_id].to_i
		doctor_id = params[:doctor_id]
		patient_id = params[:patient_id]


		if doctor_id != nil
			url_cur = "https://sdpm-appointment-service.herokuapp.com/appointment/#{appointment_id}"
			response = RestClient::Request.execute(
			 		method:  :get,
			 		url:     url_cur,
			 		)
			#puts "response is"
			#puts response
			res = JSON.parse(response)
			patient_id = res["patient_id"]
			resp = RestClient::Request.execute(
					method:  :get,
					url:     "https://web.njit.edu/~as2757/ControlPatientIntake/api.php",
					payload: { Token:'0s4ijqfrAJs07JwcVcBS', Type:'SPIRBPID', Data:{"patient_id":patient_id }}.to_json
			)
			
			res = JSON.parse(resp)
			# puts "res is "
			# puts res
			# #byebug
			email = res["ReturnData"]["patient_emailid"]
			#email = "ap2559@njit.edu"
			url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{appointment_id}?doctor_id=#{doctor_id}&email=#{email}"
		elsif patient_id != nil
			resp = RestClient::Request.execute(
					method:  :get,
					url:     "https://web.njit.edu/~as2757/ControlPatientIntake/api.php",
					payload: { Token:'0s4ijqfrAJs07JwcVcBS', Type:'SPIRBPID', Data:{"patient_id":params[:patient_id] }}.to_json
			)
			
			res = JSON.parse(resp)
			# puts "res is "
			# puts res
			# #byebug
			email = res["ReturnData"]["patient_emailid"]
			#email = "ap2559@njit.edu"
			#puts "email is " + email
			url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{appointment_id}?patient_id=#{patient_id}&email=#{email}"
			
		end



		#url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{appoitment_id}?doctor_id=#{id}"
		#puts "url is " + url 
		#puts "appoitment_id is " + appoitment_id
		#puts "id is " + id
    	#response = RestClient.delete url.to_s, {params: {doctor_id: id}}
    	response = RestClient::Request.execute(
  				 method:  :delete, 
   				url:     url,
   				payload: {cancel_reason: params[:cancel_reason]}
			)
    	#puts "response is "
		#puts response
    	render json: response
	end
	
	def upload_consultation_summary #(working)
		id = params[:id]
		#byebug
		#file = "C:/Users/prabh/Desktop/test.txt"
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/upload_consultation_summary"
		response = RestClient::Request.execute(
				method:  :post,
				url:      url,
				payload: {summary: params[:summary]}
				#payload: {summary: params[:summary], file: params[:file]}
		)
		#response = RestClient.post(url,{'upload' => file},)
		puts response
		render json: response
	end

	def upload_charts #(working)
		id = params[:id]
		#byebug
		url = "https://sdpm-appointment-service.herokuapp.com/appointment/#{id}/charts"
		count = params[:files_count]
		puts "count is " + count
		res = {}
		res[:files_count] = params[:files_count]
		for i in 1..count.to_i do
			file = "file" + i.to_s
			#res = res + "file" + i.to_s + ":" + "params[" + file + "]"
			res[file.parameterize.to_sym] = params[file.parameterize.to_sym]
		end
		puts res
		response = RestClient::Request.execute(
				method:  :post,
				url:      url,
				payload: res
		)
		render json: response
	end




	############ TELEVISIT SERVICE APIS ################
	# def create_session #(working but sometimes url goes down)
	# 	#puts params[:appointment_id]
	# 	url = "https://televisit-service.herokuapp.com/televisit"
	# 	response = RestClient::Request.execute(
	# 			method:  :post,
	# 			url:      url,
	# 			payload: {appointment_id: params[:appointment_id]}.to_json
	# 			)
	# 	render json: response
	# end


	def get_session #(working)
		appoitment_id = params[:appoitment_id]
		#user_token = params[:user_token]
		url = "https://televisit-service.herokuapp.com/televisit/#{appoitment_id}"
		response = RestClient::Request.execute(
  		method:  :get, 
				url:      url,
		)
		render json: response
	end

	def start_session #(working)
		appoitment_id = params[:appoitment_id]
		url = "https://televisit-service.herokuapp.com/televisit/#{appoitment_id}/start"
		response = RestClient::Request.execute(
				method:  :get,
				url:      url,
				)
		render json: response
	end

	def end_session  #(working)
		appoitment_id = params[:appoitment_id]
		url = "https://televisit-service.herokuapp.com/televisit/#{appoitment_id}/end"
		response = RestClient::Request.execute(
				method:  :get,
				url:      url,
				)
		render json: response
	end

	def cancel_session #(working)
		appoitment_id = params[:appoitment_id].to_i
		url = "https://televisit-service.herokuapp.com/televisit/#{appoitment_id}"
		response = RestClient::Request.execute(
				method:  :delete,
				url:      url,
				)
		render json: response

	end

	def get_billing_time #(working)
		appoitment_id = params[:appoitment_id]
		url = "https://televisit-service.herokuapp.com/televisit/#{appoitment_id}/billing_time"
		response = RestClient::Request.execute(
				method:  :get,
				url:      url,
				)
		render json: response
	end


end