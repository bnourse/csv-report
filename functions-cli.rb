require_relative "functions.rb"

class CLIRunner
	def initialize
		@cl_options = {}
		@ar = AccountsReport.new
	end

	def run
  		load_cl_options
  		@ar.create_report
		@accounts = @ar.accounts
  		process_cl_account_option
  		output
  	end

	def load_cl_options
	    OptionParser.new do |opt|
	    	opt.on('-a', '--account ACCOUNTNAME', 'Generate report for single account') { |o| @cl_options[:account] = o }
		 	opt.on('-f', '--format FORMAT', 'Specify output format as console, html, or csv') { |o| @cl_options[:format] = o }
		end.parse!
	end

	def process_cl_account_option
		account_name_requested = @cl_options[:account]
		account_requested = @accounts[account_name_requested]  
		if account_name_requested != nil && account_requested != nil
		  # user provided an account name that is in data chop @accounts to just that acct
		  @accounts = {account_name_requested => account_requested}
		end
		if account_name_requested != nil && account_requested == nil
		  # user provided an account name, but that name isn't in data
		  puts "Account name doesn't exist in our file"
		  puts "Valid account names are: #{@accounts.keys.to_s}"
		  puts_help_info_and_terminate
		end #no cl argument, leave @accounts as full list
	end

	def check_for_account_in_cl_options
	  if @cl_options[:account] == nil
	    puts "CSV output requires an account name"
	    puts_help_info_and_terminate
	  end
	end

	def puts_help_info_and_terminate
	  puts "For help, run: ruby csv-hash.rb -h"
	  exit
	end

	def output
		outputFormat = @cl_options[:format]
		if outputFormat == "csv" then check_for_account_in_cl_options end

		o = Outputter.new(@accounts, outputFormat)
		if o.format_is_valid then o.output
		else 
	      puts "Invalid format argument!"
	      puts "Valid formats are: console, csv, html"
	      puts_help_info_and_terminate
	    end 
  	end

end

class Outputter

	def initialize(accounts,formatType)
		@accounts = accounts
		@format = formatType
	end

	def format_is_valid
		valid_formats = ["console","html","csv",nil]
		return valid_formats.include? @format
	end

	def output
	    case @format
	    when nil, "console"
	      output_to_console
	    when "html"
	      output_to_html
	    when "csv"
	      output_to_csv
	    end 
  	end


	def output_to_html
	    @accounts.each do |name, info|
	      puts_html_header(name, info)
	      puts_html_table_open
	      info.categories.each do |category, c_info|
	        puts_html_table_row(category, c_info)
	      end
	      puts_html_table_close
	    end
	end

	def puts_html_header(name, info)
	    puts "<h1>#{name}</h1>"
	    puts "<p>Total Balance: $#{info.pretty_account_balance}</p>"
	    puts "<hr>"
	end

	def puts_html_table_open
	    puts "<table>"
	    puts "\t<tr>"
	    puts "\t\t<th>Category</th>"
	    puts "\t\t<th>Total Spent</th>"
	    puts "\t\t<th>Avg. Transaction</th>"
	    puts "\t</tr>"
	end

	def puts_html_table_row(category, c_info)
		puts "\t<tr>"
	    puts "\t\t<th>#{category}/th>"
	    puts "\t\t<th>$#{c_info.balance_to_s}</th>"
	    puts "\t\t<th>$#{c_info.avg_to_s}</th>"
	    puts "\t</tr>"
	    puts
	end

	def puts_html_table_close
		puts "</table>"
		puts
	end

	def output_to_csv
		account_name = @accounts.keys[0]
		puts "Generating report for #{account_name} at ./report.csv"
		open('report.csv', 'w') do |f|
			f << "Category,Total Spent,Average Transaction\n"
			@accounts.each do |name, info|
				info.categories.each do |category, c_info|
					f << "#{category},#{c_info.balance_to_s},#{c_info.avg_to_s}\n"
				end
			end
		end
	end

	def output_to_console
	    @accounts.each do |name, info|
	      puts_console_header(name, info)
	      info.categories.each do |category, c_info|
	        print "#{category.ljust(28)} | $#{c_info.pretty_balance} | $#{c_info.pretty_avg_transaction}\n"
	      end
	      puts "\n"
	    end
	end

	def puts_console_header(name, info)
	    puts "\n"
	    puts "======================================================================"
	    puts "Account: #{name}... Balance: $#{info.pretty_account_balance}"
	    puts "======================================================================"
	    puts "Category                     | Total Spent | Average Transaction"
	    puts "---------------------------- | ----------- | -------------------------"
	end

end
