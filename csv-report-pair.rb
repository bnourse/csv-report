require 'csv'
require 'pry'

$args = ARGV
$csvFile = "accounts.csv"

$balanceRemaining = 0


$categoryBalanceList = []
$categoryCountList = []
$categoryAvgList = []

$categoryTransactionCount = 0
$categoryBalanceAmount = 0

def userInput
    if $args.length > 0
        accountsRetrieved = [$args[0]]
        
    else 
        accountsRetrieved = findUniqueAccountNames

    end
    return accountsRetrieved
end


###IF USING THE ENTIRE FILE
def findUniqueAccountNames
    accountsUniqueRetrieved = []
    CSV.foreach($csvFile, {headers: true, return_headers: false}) do |row|
        accountsUniqueRetrieved.push(row["Account"].strip)
    end
    
    return accountsUniqueRetrieved.uniq
end

def findUniqueCategoryNames
    categoryUniqueRetrieved = []
    CSV.foreach($csvFile, {headers: true, return_headers: false}) do |row|
        categoryUniqueRetrieved.push(row["Category"].strip)
    end
    
    return categoryUniqueRetrieved.uniq
end

def startProcessing
    accountsRetrieved = userInput
    #binding.pry
    processEachAccountInAccountsList(accountsRetrieved)
end

startProcessing
#$accountUniqueNamesList = accountsRetrieved

$categoryUniqueNamesList = findUniqueCategoryNames

def processEachAccountInAccountsList(accountsRetrieved)
    for i in 0..accountsRetrieved.length-1
        processThisAccount(accountsRetrieved[i])
    end
end

def processThisAccount(accName)
    $balanceRemaining = 0
    
    for x in 0..$categoryUniqueNamesList.length-1
        processThisCategoryForThisAccount(accName, $categoryUniqueNamesList[i])
    end 
        
    for i in 0..$categoryBalanceList.length-1
        $balanceRemaining = $balanceRemaining + $categoryBalanceAmount
    end
    binding.pry
    outputWhichFormat
end

def processThisCategoryForThisAccount(accName, category)
    $categoryTransactionCount = 0
    $categoryBalanceAmount = 0
    processEachTransactionForThisCategory(accName, category)
    $categoryBalanceList.push($categoryBalanceAmount.round(2))
    $categoryCountList.push($categoryTransactionCount)
    updateCategoryAvgList
end

def processEachTransactionForThisCategory(accName, category)
    listOfTransactionsForThisCategory = getTransactionsArray(accName, category)
    
    for i in 0..listOfTransactionsForThisCategory.length-1
        outflowFloat = makeStringIntoFloat(listOfTransactionsForThisCategory[i]["Outflow"])
        inflowFloat = makeStringIntoFloat(listOfTransactionsForThisCategory[i]["Inflow"])
        $categoryTransactionCount = $categoryTransactionCount + 1
        $categoryBalanceAmount = $categoryBalanceAmount - outflowFloat + inflowFloat
    end
end

def makeStringIntoFloat(column)
    column.gsub(/[$]/,'').gsub(/[,]/,'').to_f
end

def getTransactionsArray(accName, category)
    transactions = []
    CSV.foreach($csvFile, {headers: true, return_headers: false}) do |row|
        strippedName = row["Account"].strip
        row["Account"] = strippedName
        strippedCategory = row["Category"].strip
        row["Category"] = strippedCategory
        if ifRelevantTransaction(accName, strippedName, category, strippedCategory) then
            transactions.push(row)
        end
    end
    return transactions
end

def ifRelevantTransaction(wantName, actualName, wantCategory, actualCategory)
    return actualName == wantName && actualCategory == wantCategory
end

def updateCategoryAvgList
    categoryAvg = 0
    if $categoryTransactionCount > 0
        categoryAvg = $categoryBalanceAmount / $categoryTransactionCount
        categoryAvg = categoryAvg.round(2)
    else
        categoryAvg = 0
    end
    $categoryAvgList.push(categoryAvg)
end

processThisCategoryForThisAccount("Sonia", "Entertainment")

def outputWhichFormat
    consoleHeader()
    consoleBody
end

def consoleHeader(accountName, balanceRemaining)
    print ("=" * 80) + "\n"
    print "Account: " + accountName + "... Balance: $" + balanceRemaining.round(2).to_s + "\n"
    print ("=" * 80) + "\n"
    print "Category" + (" " * 22) + "|  " + "Total Spent" + (" " * 4) + "|  " + "Average Transaction" + "\n"
    print ("-" * 29) + " | " + ("-" * 15) + " | " + ("-" * 30) + "\n"
end

def consoleBody
    for i in 0..categoryList.length-1
        if categoryCountList[i] > 0 then
            print categoryList[i] + (" " * (30 - categoryList[i].length)) + "|  " + categoryBalanceList[i].round(2).to_s + (" " * (15 - categoryBalanceList[i].to_s.length)) + "|  " + categoryAvgList[i].round(2).to_s + "\n" 
        end 
    end
    print "\n" + "\n"
end


def consoleOutput(accountName, balanceRemaining)
    consoleHeader(accountName, balanceRemaining)
    consoleBody(categoryList, categoryCountList, categoryBalanceList, categoryAvgList)
end

# def updateBalance
#   update total balance for this account, in this category
#   totalBalance
# end

# def totalBalanceForCategory
#   update overall balance of $ spent
# end

# def ignoreZeroCategories
#   if category has 0 transactions for that account
#       ignore category, set average to 0 (cannot divide by 0)
#   else
#       add category to total for that account
#   end
# end

# def totalBalance
#   add up total amount spent and find ending balance
# end

# def outputConsoleFormat
#   Console Format
# end

# def outputHTML
#   HTML
# end

# def outputCSV
#   CSV format
# end