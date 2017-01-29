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

args = ARGV
    
csvFile = "accounts.csv"

if args.length > 0 
    #if we are passed an account name in the command line
    #only loop over the single account
    accountsArray = [args[0]]
else
    #loop over all the accounts
    accountsArray = getAccounts(csvFile)
end

for accountName in accountsArray 
    #For loop that will loop twice, once for each account name, in this case "Priya" and "Sonia".
    
    categoryList = getCategories(csvFile)
    balanceRemaining = 0

    categoryBalanceList = []
    categoryCountList = []
    categoryAvgList = []

    for category in categoryList
        categoryTransactions = listTransactions(accountName, category, csvFile)
        categoryTransactionCount = 0
        categoryBalance = 0
   
        for transaction in categoryTransactions
            #Loops for each transaction for Priya and Sonia. Stripping the "$" and "," then converting to integer.
            transactionOutflow = transaction[4].gsub(/[$]/,'').gsub(/[,]/,'').to_f
            transactionInflow = transaction[5].gsub(/[$]/,'').gsub(/[,]/,'').to_f
            categoryTransactionCount = categoryTransactionCount + 1
            categoryBalance = categoryBalance  - transactionOutflow + transactionInflow
        end

        categoryBalanceList.push(categoryBalance.round(2))
        categoryCountList.push(categoryTransactionCount)

        if categoryTransactionCount > 0 
            categoryAvg = categoryBalance / categoryTransactionCount
        else
            categoryAvg = 0
        end

        categoryAvgList.push(categoryAvg)


    end

    for categoryBalance in categoryBalanceList
        balanceRemaining = balanceRemaining + categoryBalance
    end


    #console output stuff goes here
    #remember to skip outputting a category if categoryCountList[i] == 0
    print ("=" * 80) + "\n"
    print "Account: " + accountName + "... Balance: $" + balanceRemaining.round(2).to_s + "\n"
    print ("=" * 80) + "\n"
    print "Category" + (" " * 22) + "|  " + "Total Spent" + (" " * 4) + "|  " + "Average Transaction" + "\n"
    print ("-" * 29) + " | " + ("-" * 15) + " | " + ("-" * 30) + "\n"
    for i in 0..categoryList.length-1
        
        if categoryCountList[i] > 0 then
            print categoryList[i] + (" " * (30 - categoryList[i].length)) + "|  " + categoryBalanceList[i].round(2).to_s + (" " * (15 - categoryBalanceList[i].to_s.length)) + "|  " + categoryAvgList[i].round(2).to_s + "\n" 
        end 

    end
    print "\n" + "\n"

end



