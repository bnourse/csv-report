require 'sinatra'
require_relative './csv-hash.rb'
require 'pry'

enable :sessions

ar = AccountsReport.new
ar.set_up_initial_values
ar.create_report

get("/report") do
	if params["name"] == nil then @account_list = ar.accounts
	else @account_list = ar.trim_to_one_account(params["name"]) end
	erb :report
end

get("/") do
	erb :index
end

post("/add_row") do
	ar.add_row_to_file(params)
	redirect("/report?name=#{params["account"]}")
end

get("/admin") do
	if session[:loggedin] == true
		@account_names = ar.accounts.keys
		erb :admin
	else
		redirect "/login"
	end
end

get("/login") do
	erb :login
end

post("/login") do
	@username = params["username"]
	@password = params["password"]
	if(ar.valid_login(@username,@password))
		session[:loggedin] = true
		redirect "/admin"
	else
		redirect "/login"
	end
end

get("/logout") do
	session.delete(:loggedin)
	redirect "/"
end

post("/logout") do
	session.delete(:loggedin)
	redirect "/"
end