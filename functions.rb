# Usage: ruby csv-hash.rb [options]
#     -a, --account ACCOUNTNAME        Generate report for single account
#     -f, --format FORMAT              Specify output format as console, html, or csv
#     -h, --help                       Shows help info
# Defaults to all accounts, console formatted

require "csv"
require "pry"
require "optparse"

class AccountInfo
  def initialize
    @account_balance = 0.00
    @categories = {}
  end

  def update_balance(amount)
    @account_balance += amount
  end

  def set_balance(amount)
    @account_balance = amount
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

  def balance
    return @account_balance
  end
end

class Category
  def set_up_initial_values
    @category_balance = 0.00
    @num_transactions = 0
    @average_transaction_balance = 0.00
  end

  def add_transaction(amount)
    update_balance(amount)
    @num_transactions += 1
    update_transaction_balance
  end

  def update_transaction_balance
    @average_transaction_balance = @category_balance / @num_transactions
  end

  def update_balance(amount)
    @category_balance += amount
  end

  def pretty_balance
    @category_balance.round(2).to_s.ljust(10)
  end

  def pretty_avg_transaction
    @average_transaction_balance.round(2).to_s.ljust(20)
  end

  def balance_to_s
    @category_balance.round(2).to_s
  end

  def avg_to_s
    @average_transaction_balance.round(2).to_s
  end

  def set_balance(amount)
    @category_balance = amount
  end

  def balance
    @category_balance
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
  def initialize
    @accounts = {}
    @input_filename = "accounts.csv"
  end

  def set_input_filename(filename)
    @input_filename = filename
  end

  def create_report

    CSV.foreach(@input_filename, {headers: true, return_headers: false}) do |row|
      # Add a key for each account to the accounts Hash.
      account_name = row["Account"].chomp

      if !@accounts[account_name]
        @accounts[account_name] = AccountInfo.new
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

  end

  def get_categories_for_account(account_name)
    return @accounts[account_name].categories
  end

  def trim_to_one_account(account_name_requested)
    account_requested = @accounts[account_name_requested]
    account = {account_name_requested => account_requested}
    return account
  end

  def accounts
    @accounts
  end

end