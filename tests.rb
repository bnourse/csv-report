require_relative "csv-hash.rb"

def test_equality(expected, actual)
  if expected == actual
    puts "Pass"
  else
    puts "Fail. Expected #{expected}, but got #{actual}."
  end
end

def test_account_balance_update(test_starting_balance, test_trans_amount)
  ai = AccountInfo.new
  ai.set_balance(test_starting_balance)
  test_balance = test_starting_balance + test_trans_amount

  test_equality(test_balance, ai.update_balance(test_trans_amount))
end

def test_category_balance_update(test_starting_balance, test_trans_amount)
  c = Category.new
  c.set_balance(test_starting_balance)
  test_balance = test_starting_balance + test_trans_amount

  test_equality(test_balance, test_trans_amount)
end

def test_category_list
  ar = AccountsReport.new
  ar.set_up_initial_values
  ar.set_input_filename("testdata.csv")
  ar.create_report
  expected_values_for_bob = ["Allowance", "Household Goods"].sort

  test_equality(expected_values_for_bob, ar.get_categories_for_account("Bob").keys.sort)
end

test_account_balance_update(0, 20)
test_category_balance_update(0, 100)
test_category_list