require 'csv'
require 'pry'
require 'optparse'

#Does the work
class Report

	def doReport
		@accountList = AccountList.new
		@accountList.setInitial
		@inputCSV = "accounts.csv"
		generateAccountList(@inputCSV)
		processCommandLine
	end

	def generateAccountList(file)
		CSV.foreach(file, {headers: true, return_headers: false}) do |row|
			accountName = row["Account"].chomp
			if @accountList.doesNotHave(accountName)
				@accountList.addAccount(accountName)
			end
			@accountList.addTransaction(accountName, row)
		end
	end

	def processCommandLine
		processOptions
		accountsToOutput = getAccountsToOutput
		outputFormat = getOutputFormat
		outputReport(accountsToOutput, outputFormat)
	end

	def getAccountsToOutput
		accountsToOutput = []
		if @options.has_key? :account
			if @accountList.doesNotHave(@options[:account]) 
				puts "That account name doesn't exist in this file"
				showUsage
			else 
				accountsToOutput.push(@options[:account])
			end
		else 
			accountsToOutput = @accountList.getAccountNames
		end
		return accountsToOutput
	end

	def processOptions
		@options = {}
		OptionParser.new do |opt|
			opt.on('-a', '--account ACCOUNTNAME', 'Generate report for single account') { |o| @options[:account] = o }
  			opt.on('-f', '--format FORMAT', 'Specify output format as console, html, or csv') { |o| @options[:format] = o }
		end.parse!
	end

	def getOutputFormat
		validFormats = ["console", "csv", "html"]
		outputFormat = "console"
		if @options.has_key? :format
			if validFormats.include? @options[:format]
				outputFormat = @options[:format]
			else
				puts "Invalid format argument"
				showUsage
			end
		end
		return outputFormat
	end

	def showUsage
		puts "Run ruby csv-oo.rb -h for options"
		exit
	end

	def outputReport(accountsToOutput, outputFormat)
		if outputFormat == "console" then outputConsole(accountsToOutput) end
		if outputFormat == "csv" then outputCSV(accountsToOutput) end
		if outputFormat == "html" then outputHTML(accountsToOutput) end
	end

	def outputConsole(accountsToOutput)

	end

	def outputCSV(accountsToOutput)
	end

	def outputHTML(accountsToOutput)
	end

end

#Holds all the accounts
class AccountList
	def setInitial
		#keyed by account name
		@accountsHash = {}
	end

	def addAccount(accountName)
		@newAccount = Account.new
		@newAccount.setInitial
		@accountsHash[accountName] = @newAccount
	end

	def removeAccount(accountName)
		@accountsHash.delete[accountName]
	end

	def doesNotHave(accountName)
		return @accountsHash[accountName] == nil
	end

	def addTransaction(accountName, row)
		@currentAccount = @accountsHash[accountName]
		@currentAccount.addTransaction(row)
	end

	def getAccount(accountName)
		return @accountsHash[accountName]
	end

	def getAccountNames
		return @accountsHash.keys
	end

end


#Holds all the categories for an account
class Account
	def setInitial
		#keyed by category name
		@categoriesHash = {}
		@accountBalance = 0
	end

	def addTransaction(row)
		categoryName = row["Category"].chomp
		if @categoriesHash[categoryName] == nil
			newCategory = Category.new
			newCategory.setInitial
			@categoriesHash[categoryName] = newCategory
		end 
		@categoriesHash[categoryName].addTransaction(row)
		@accountBalance += @categoriesHash
	end

end

#Holds the transactions for a category
class Category

	def setInitial
		@transactionRows = []
		@transactionCount = 0
		@categoryBalance = 0
		@categoryAverage = 0
	end

	def addTransaction(row)
		@transactionRows.push(row)
		@transactionCount += 1
		inflow = self.floatValue(row["Inflow"])
		outflow = self.floatValue(row["Outflow"])
		@categoryBalance += inflow - outflow
		@categoryBalance = @categoryBalance.round(2)
		@categoryAverage = (@categoryBalance / @transactionCount).round(2)
	end

	def floatValue(amountString)
		return amountString.gsub(/[,\$]/, "").to_f.round(2)
	end

	def getBalance
		return @categoryBalance
	end
end

report = Report.new
report.doReport