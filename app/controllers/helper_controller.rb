require 'net/http'
require 'json'



class HelperController < ApplicationController
	
	# GET /open
	# GET /open.json
	def open
		#@start_date = Date.parse(params[:StartDate])
		@start_date = Date.parse('2020/11/1')
  		#@end_date = Date.parse(params[:EndDate])
  		@end_date = params[:EndDate]
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
  				@start_time = @start_time + (30*60)
  				slot[:endTime] = @start_time.strftime("%H:%M").to_s
  				curr_date.push(slot)
  			end

  			
  			@days = @days - 1
  			@start_date = @start_date + 1
			@result.push(curr_date)
 		end
 		render json: @result, status: 200
	end

	# GET /all_doctors
	# GET /all_doctors.json
	def all_doctors  #call external api to get all doctors
		@id = 1.to_i
		@dr = "abcd, abcd"
		@result = []
		while @id <= 10
			curr = {}
			curr[:id] = @id.to_s
			curr[:name] = @dr
			@result.push(curr) 
			@id = @id + 1
		end
		render json: @result, status: 200
	end

	# GET /all_patients
	# GET /all_patients.json
	def all_patients #call external api to get all patients
		@id = 1.to_i
		@patient = "abcd, abcd"
		@result = []
		while @id <= 10
			curr = {}
			curr[:id] = @id.to_s
			curr[:name] = @patient
			@result.push(curr) 
			@id = @id + 1
		end
		render json: @result, status: 200
	end


	def book
		tele_visit = params[:isTeleVisit]
		user_token = params[:user_token]

		puts "tele_visit is " + tele_visit
		puts "user_token is " + user_token
		
		body = {}
    	body[:patient_id] = params[:PatientID].to_s
    	body[:doctor_id] = params[:DoctorID].to_s
    	body[:start_time] = params[:startDateTime].to_s
    	body[:end_time] = params[:endDateTime].to_s


		uri = URI('https://sdpm-appointment-service.herokuapp.com:4040/appointment')
    	http = Net::HTTP.new(uri.host, uri.port)
    	req = Net::HTTP::Post.new(uri.path.concat("?tele_visit=#{tele_visit}&user_token=#{user_token}"), 'Content-Type' => 'application/json')
    	req.body = body.to_json
    	res = http.request(req)
    	puts "response #{res.body}"
    	#render json: res, status: 200
	rescue => e
    	puts "failed #{e}"
    	#render json: #{e}, status: 404
	end

	#this will give details of an existing appoitment based on the id as paer vishnus's api
	def already_booked_appoitments

		id = params[:id]
		#user_token = params[:user_token]
		uri = URI('https://sdpm-appointment-service.herokuapp.com:4040/appointment')
    	http = Net::HTTP.new(uri.host, uri.port)
    	req = Net::HTTP::Get.new(uri.path.concat("?patient_id=#{id}"), 'Content-Type' => 'application/json')
    	#req.body = body.to_json
    	res = http.request(req)
    	puts "response #{res.body}"

    	#render json: res, status: 200
	rescue => e
    	puts "failed #{e}"
    	#render json: #{e}, status: 404
	end

	#this will give details of cancelled appoitments
	def cancelled_appoitments
		id = params[:id]
		uri = URI(' https://sdpm-appointment-service.herokuapp.com:4040/cancelled_appointments')
    	http = Net::HTTP.new(uri.host, uri.port)
    	req = Net::HTTP::Get.new(uri.path.concat("?&doctor_id=#{id}"), 'Content-Type' => 'application/json')
    	req.body = body.to_json
    	res = http.request(req)

    	puts "response #{res.body}"

    	#render json: res, status: 200
	rescue => e
    	puts "failed #{e}"
    	#render json: #{e}, status: 404
	end

	#this will allow canceling the previosuly booked appoitment
	def cancel_appoitnment
	
		body = {}
		body[:calcel_reason] = "testing from patient."
		uri = URI('https://sdpm-appointment-service.herokuapp.com:4040/appointment')
    	http = Net::HTTP.new(uri.host, uri.port)
    	req = Net::HTTP::DELETE.new(uri.path.concat("/#{id}?&doctor_id=#{doctor_id}"), 'Content-Type' => 'application/json')
    	req.body = body.to_json
    	res = http.request(req)

    	puts "response #{res.body}"

    	#render json: res, status: 200
	rescue => e
    	puts "failed #{e}"
    	#render json: #{e}, status: 404
	end

	#this will add an open slot or doctor availability
	def add_open_slot

	end


end