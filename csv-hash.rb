# Usage: ruby csv-hash.rb [options]
#     -a, --account ACCOUNTNAME        Generate report for single account
#     -f, --format FORMAT              Specify output format as console, html, or csv
# Defaults to all accounts, console formatted

require "csv"
require "pry"
require "optparse"

class AccountInfo
  def set_up_initial_values
    @account_balance = 0.00
    @categories = {}
  end

  def update_balance(amount)
    @account_balance += amount
  end

  def add_category(category_name)
    @categories[category_name] = Category.new
    @categories[category_name].set_up_initial_values
  end

  def pretty_account_balance
    return @account_balance.round(2)
  end

  def already_has_category(category_name)
    return (@categories[category_name] != nil)
  end

  def get_category(category_name)
    return @categories[category_name]
  end

  def categories
    return @categories
  end
end

class Category
  def set_up_initial_values
    @category_balance = 0.00
    @num_transactions = 0
    @average_transaction_balance = 0.00
  end

  def add_transaction(amount)
    @category_balance += amount
    @num_transactions += 1
    @average_transaction_balance = @category_balance / @num_transactions
  end

  def pretty_balance
    @category_balance.round(2).to_s.ljust(10)
  end

  def pretty_avg_transaction
    @average_transaction_balance.round(2).to_s.ljust(20)
  end
end

class Outflow
  def set_value(number_string_from_csv)
    @value = number_string_from_csv.gsub(/[,\$]/, "").to_f.round(2)
  end

  def to_f
    return @value
  end
end

class Inflow
  def set_value(number_string_from_csv)
    @value = number_string_from_csv.gsub(/[,\$]/, "").to_f.round(2)
  end

  def to_f
    return @value
  end
end

class AccountsReport
  def set_up_initial_values
    @accounts = {}
    @cl_options = {} 
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
    binding.pry
  end

  def create_report
    load_cl_options
    CSV.foreach("accounts.csv", {headers: true, return_headers: false}) do |row|
      # Add a key for each account to the accounts Hash.
      account_name = row["Account"].chomp

      if !@accounts[account_name]
        @accounts[account_name] = AccountInfo.new
        @accounts[account_name].set_up_initial_values
      end

      # Set the account which is being affected by this iteration.
      current_account = @accounts[account_name]

      # Clean up outflow and inflow.
      outflow = Outflow.new
      outflow.set_value(row["Outflow"])
      inflow = Inflow.new
      inflow.set_value(row["Inflow"])
      
      transaction_balance = inflow.to_f - outflow.to_f

      current_account.update_balance(transaction_balance)

      current_category = row["Category"].chomp

      # Initialize category.
      if !current_account.already_has_category(current_category)
        current_account.add_category(current_category)
      end

      current_account.get_category(current_category).add_transaction(transaction_balance)
    end
    process_cl_account_option
  end

  def output
    case @cl_options[:format]
    when nil, "console"
      output_to_console
    when "html"
      output_to_html
    when "csv"
      output_to_csv
    else
      puts "Invalid format argument!"
      puts "Valid formats are: console, csv, html"
      puts_help_info_and_terminate
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

  def output_to_html
    puts "outputting html : #{@accounts.keys.to_s}"
  end

  def output_to_csv
    puts "outputting csv : #{@accounts.keys.to_s}"
  end

  def puts_help_info_and_terminate
    puts "For help, run: ruby csv-hash.rb -h"
    exit
  end

end

ar = AccountsReport.new
ar.set_up_initial_values
ar.create_report
ar.output
