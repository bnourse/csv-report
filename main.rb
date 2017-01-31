require_relative "csv-hash.rb"

ar = AccountsReport.new
ar.set_up_initial_values
ar.create_report
ar.output_account_to_html("Sonia")