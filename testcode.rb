require 'csv'
require 'pry'

def getAccounts(inputCSV)
    accounts = []
    CSV.foreach(inputCSV, {headers: true, return_headers: false}) do |row|
        accounts.push(row["Account"].strip)
    end
    return accounts.uniq
end

def getCategories(inputCSV)
    categories = []
    CSV.foreach(inputCSV, {headers: true, return_headers: false}) do |row|
        categories.push(row["Category"].strip)
    end
    return categories.uniq
end

def listTransactions(name, category, inputCSV)
    transactions = []
    CSV.foreach(inputCSV, {headers: true, return_headers: false}) do |row|
        strippedName = row["Account"].strip
        row["Account"] = strippedName
        strippedCategory = row["Category"].strip
        row["Category"] = strippedCategory
        if strippedName == name then
        	if strippedCategory == category then
            	transactions.push(row)
            end
        end
    end
    return transactions
end


def getStartingBalance(name, inputCSV)
	transactions = []
    CSV.foreach(inputCSV, {headers: true, return_headers: false}) do |row|
        strippedName = row["Account"].strip
        row["Account"] = strippedName
        strippedPayee = row["Payee"].strip
        row["Payee"] = strippedPayee
        if strippedName == name then
        	if strippedPayee == "STARTING BALANCE" then
            	transactions.push(row)
            end
        end
    end
    return transactions[0]["Inflow"].gsub(/[$]/,'').gsub(/[,]/,'').to_f
end

csvFile="accounts.csv"

accountsArray = getAccounts(csvFile)
for accountName in accountsArray 
    #For loop that will loop twice, once for each account name, in this case "Priya" and "Sonia".
    
    accountCategories = getCategories(csvFile)
    totalSpent = 0
    startingBalance = getStartingBalance(accountName,csvFile)
    balanceRemaining = startingBalance * -1

    categoryList = []
    categorySpentList = []
    categoryCountList = []
    categoryAvgList = []

    for category in accountCategories
    	categoryTransactions = listTransactions(accountName, category, csvFile)
    	categoryTransactionCount = 0
    	categorySpent = 0
    	categoryList.push(category)
   
	    for transaction in categoryTransactions
	        #Loops for each transaction for Priya and Sonia. Stripping the "$" and "," then converting to integer.
	        transactionCategory = transaction[3]
	        transactionOutflow = transaction[4].gsub(/[$]/,'').gsub(/[,]/,'').to_f
	        transactionInflow = transaction[5].gsub(/[$]/,'').gsub(/[,]/,'').to_f
	        categories = getCategories(csvFile)
	        #binding.pry
	        categoryTransactionCount = categoryTransactionCount + 1
	        categorySpent = categorySpent  + transactionOutflow - transactionInflow

	    end
	    categorySpentList.push(categorySpent)
	    categoryCountList.push(categoryTransactionCount)

	    if categoryTransactionCount > 0 
	    	categoryAvg = categorySpent / categoryTransactionCount
	    else
	    	categoryAvg = 0
	    end

	    categoryAvgList.push(categoryAvg)


	end

	for categorySpent in categorySpentList
		balanceRemaining = balanceRemaining - categorySpent
	end

	#console output stuff goes here
	#remember to skip outputting a category if categoryCountList[i] == 0
	print "Account: " + accountName + "... Balance: $" + balanceRemaining.round(2).to_s + "\n"
	for i in 0..categoryList.length-1
		#binding.pry
		if categoryCountList[i] > 0 then
			print categoryList[i] + " " + categorySpentList[i].round(2).to_s + " " + categoryAvgList[i].round(2).to_s + "\n" 
		end 
	end


end