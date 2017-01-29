require "csv"

class AccountInfo
  def set_up_initial_values
    @tally = 0.00
    @categories = {}
  end

  def update_tally(amount)
    @tally += amount
  end

  def add_category(category_name)
    @categories[category_name] = Category.new
    @categories[category_name].set_up_initial_values
  end

  def pretty_tally
    return @tally.round(2)
  end

  def already_has_category(category_name)
    return (@categories[category_name] != nil)
  end

  def category(category_name)
    return @categories[category_name]
  end

  def categories
    return @categories
  end
end

class Category
  def set_up_initial_values
    @tally = 0.00
    @num_transactions = 0
    @average_transaction_cost = 0.00
  end

  def add_transaction(amount)
    @tally += amount
    @num_transactions += 1
    @average_transaction_cost = @tally / @num_transactions
  end

  def pretty_tally
    @tally.round(2).to_s.ljust(10)
  end

  def pretty_avg_transaction
    @average_transaction_cost.round(2).to_s.ljust(20)
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

accounts = {}

CSV.foreach("accounts.csv", {headers: true, return_headers: false}) do |row|
  # Add a key for each account to the accounts Hash.
  account = row["Account"].chomp

  if !accounts[account]
    accounts[account] = AccountInfo.new
    accounts[account].set_up_initial_values
  end

  # Set the account which is being affected by this iteration.
  current_account = accounts[account]

  # Clean up outflow and inflow.
  outflow = Outflow.new
  outflow.set_value(row["Outflow"])
  inflow = Inflow.new
  inflow.set_value(row["Inflow"])
  
  transaction_amount = inflow.to_f - outflow.to_f

  # Keep a tally for current balance of the account.
  current_account.update_tally(transaction_amount)

  category = row["Category"].chomp

  # Initialize category.
  if !current_account.already_has_category(category)
    current_account.add_category(category)
  end

  # Add transaction for that category.
  current_account.category(category).add_transaction(transaction_amount)
end

#  Display

accounts.each do |name, info|
  puts "\n"
  puts "======================================================================"
  puts "Account: #{name}... Balance: $#{info.pretty_tally}"
  puts "======================================================================"
  puts "Category                     | Total Spent | Average Transaction"
  puts "---------------------------- | ----------- | -------------------------"
  info.categories.each do |category, c_info|
    print "#{category.ljust(28)} | $#{c_info.pretty_tally} | $#{c_info.pretty_avg_transaction}\n"
  end
  puts "\n"
end