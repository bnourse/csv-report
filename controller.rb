require 'sinatra'
require_relative './csv-hash.rb'

ar = AccountsReport.new
ar.set_up_initial_values
ar.create_report

get("/Priya") do
	@account_list = ar.trim_to_one_account("Priya")
	erb :report
end

get("/Sonia") do
	@account_list = ar.trim_to_one_account("Sonia")
	erb :report
end

get("/report") do
	@account_list = ar.accounts
	erb :report
end

get("/") do
	send_file "index.html"
end