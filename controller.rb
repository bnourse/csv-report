require 'sinatra'
require_relative './csv-hash.rb'

ar = AccountsReport.new
ar.set_up_initial_values
ar.create_report

get("/report") do
	selection = params["name"]
	if selection == nil then @account_list = ar.accounts
	else @account_list = ar.trim_to_one_account(selection) end
	erb :report
end

get("/") do
	send_file "index.html"
end