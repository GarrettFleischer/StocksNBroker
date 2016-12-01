import csv
import pandas_datareader.data as web
import datetime
import pymssql
conn = pymssql.connect(server='aura.students.cset.oit.edu', user='DAL', password='TeamMGM', database='DiscoverCode')
cursor = conn.cursor()

start = datetime.datetime(2016, 11, 22)
end = datetime.datetime(2016, 11, 29)

companyList = []
yahooList = []
# finance_data = []

with open("companylist.csv", 'r') as FCompany:
    companyReader = csv.DictReader(FCompany, dialect='excel')
    companyList = list(companyReader)

with open("yahoolist.csv", 'r') as FYahoo:
    yahooReader = csv.DictReader(FYahoo, dialect='excel')
    yahooList = list(yahooReader)

for company in companyList:
    for yahoo in yahooList:
        if company["Symbol"].lower() == yahoo["Ticker"].lower():
            try:
                finance_data = (web.DataReader(company["Symbol"], 'yahoo', start, end))

                SectorID = 0
                IndustryID = 0
                ExchangeID = 0
                CountryID = 0

                # SECTORS
                cursor.execute("SELECT SectorID FROM proj.Sectors WHERE Name = '" + company["Sector"] + "'")
                row = cursor.fetchone()
                if row:
                    SectorID = row[0]
                else:
                    cursor.execute("INSERT INTO proj.Sectors (Name) VALUES ('" + company["Sector"] + "')")
                    SectorID = cursor.lastrowid.real

                # INDUSTRIES
                cursor.execute("SELECT IndustryID FROM proj.Industries WHERE Name = '" + company["industry"] + "'")
                row = cursor.fetchone()
                if row:
                    IndustryID = row[0]
                else:
                    cursor.execute("INSERT INTO proj.Industries (Name) VALUES ('" + company["industry"] + "')")
                    IndustryID = cursor.lastrowid.real

                # EXCHANGES
                cursor.execute("SELECT ExchangeID FROM proj.Exchanges WHERE Name = '" + yahoo["Exchange"] + "'")
                row = cursor.fetchone()
                if row:
                    ExchangeID = row[0]
                else:
                    cursor.execute("INSERT INTO proj.Exchanges (Name) VALUES ('" + yahoo["Exchange"] + "')")
                    ExchangeID = cursor.lastrowid.real

                # COUNTRIES
                cursor.execute("SELECT CountryID FROM proj.Countries WHERE Name = '" + yahoo["Country"] + "'")
                row = cursor.fetchone()
                if row:
                    CountryID = row[0]
                else:
                    cursor.execute("INSERT INTO proj.Countries (Name) VALUES ('" + yahoo["Country"] + "')")
                    CountryID = cursor.lastrowid.real

                cursor.execute("INSERT INTO proj.Symbols (Name, SectorID, IndustryID, ExchangeID, CountryID) VALUES ('" + company["Symbol"] + "'," + str(SectorID) + "," + str(IndustryID) + "," + str(ExchangeID) + "," + str(CountryID) + ")")
                SymbolID = cursor.lastrowid.real

                for index, row in finance_data.iterrows():
                    cursor.execute("INSERT INTO proj.MarketDays (Date, SymbolID, Volume, PriceOpen, PriceClose) VALUES ('" + str(index) + "'," + str(SymbolID) + "," + str(row['Volume']) + "," + str(row['Open']) + "," + str(row['Close']) + ")")

            except:
                print('Error for: ' + company["Symbol"])

conn.commit()
conn.close()