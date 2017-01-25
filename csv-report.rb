require 'csv'

def csvReport
	accounts = CSV.read('accounts.csv')
	cleanAccounts = clean(accounts)
	accountNames = getUniqueAccountNames(cleanAccounts)
	puts accountNames.inspect
end

def clean(accounts)
	cleanedAccounts = []
	for row in accounts 
		cleanedRow = []
		for cell in row
			#tried with cleanCell = cell.gsub(/\\n/,'')
			#Strip cleans whitespace before and after
			#there may be data that it screws up

			#cleanCell = cell.strip
			cleanedCell = cell.gsub(/\n/,"")
			cleanedRow.push(cleanedCell)
		end
		cleanedAccounts.push(cleanedRow)
	end
	return cleanedAccounts
end

def getUniqueAccountNames(accounts)
	accountNames = []
	for row in accounts
		accountNames.push(row[0])
	end
	accountNames.shift
	uniqueAccountNames = accountNames.uniq
end

csvReport