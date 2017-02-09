require_relative "functions.rb"

class WebRunner
	def initialize
		@ar = AccountsReport.new
		@ar.create_report
		@cfm = CSVFileModifier.new
		@auth = Authorizer.new
	end

	def ar
		@ar
	end

	def add_row_to_file(row_hash)
		@cfm.add_row_to_file(row_hash)
		@ar = AccountsReport.new
		@ar.create_report
	end

	def accounts
		@ar.accounts
	end

	def trim_to_one_account(name)
		@ar.trim_to_one_account(name)
	end

	def valid_login(username, password)
		@auth.valid_login(username,password)
	end	
end

class CSVFileModifier
	def initialize
		@csv_filename = "accounts.csv"
	end

	def set_csv_filename(filename)
		@csv_filename = filename
	end

	def add_row_to_file(row_hash)
		csv_line = make_csv_line(row_hash)
		append_to_csv_file(csv_line)

	end

	def make_csv_line(row_hash)
		output = "#{row_hash["account"]},#{row_hash["date"]},#{row_hash["payee"]},#{row_hash["category"]},#{row_hash["outflow"]},#{row_hash["inflow"]}\n"
	end

	def append_to_csv_file(csv_line)
		open(@csv_filename, 'a') do |f|
			f.puts csv_line
		end
	end

end

class Authorizer

	def initialize
		@logins_file = "./logins.csv"
		@logins_hash = get_logins_hash
	end

	def set_logins_file(filename)
		@logins_file = filename
	end

	def valid_login(uname,pword)
		is_valid = false
			if @logins_hash.key? uname
			  if @logins_hash[uname] == pword
			    is_valid = true
			  end
			end
		return is_valid
	end

	def get_logins_hash
		logins_hash = {}
			CSV.foreach(@logins_file, {headers: true, return_headers: false}) do |row|
				logins_hash[row["username"]] = row["password"]
			end
		return logins_hash
	end

end