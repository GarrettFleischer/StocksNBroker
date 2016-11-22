import csv



with open("companylist.csv", 'r') as FCompany:
    companyList = csv.DictReader(FCompany, dialect='excel')
    for company in companyList:
        with open("yahoolist.csv", 'r') as FYahoo:
            yahooList = csv.DictReader(FYahoo, dialect='excel')
            for yahoo in yahooList:
                if company["Symbol"].lower() == yahoo["Ticker"].lower():
                    print(company["Symbol"])