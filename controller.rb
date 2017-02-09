require 'sinatra'
require_relative './functions-web.rb'
require 'pry'

enable :sessions

wr = WebRunner.new

get("/report") do
	if params["name"] == nil then @account_list = wr.accounts
	else @account_list = wr.trim_to_one_account(params["name"]) end
	erb :report
end

get("/") do
	erb :index
end

post("/add_row") do
	wr.add_row_to_file(params)
	redirect("/report?name=#{params["account"]}")
end

get("/admin") do
	if session[:loggedin] == true
		@account_names = wr.accounts.keys
		erb :admin, :layout => :adminlayout
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
	if(wr.valid_login(@username,@password))
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