IF OBJECT_ID('proj.BrokerPortfolio') IS NOT NULL DROP TABLE proj.BrokerPortfolio;
IF OBJECT_ID('proj.Portfolio') IS NOT NULL DROP TABLE proj.Portfolio;
IF OBJECT_ID('proj.Transactions') IS NOT NULL DROP TABLE proj.Transactions;
IF OBJECT_ID('proj.Brokers') IS NOT NULL DROP TABLE proj.Brokers;
IF OBJECT_ID('proj.Clients') IS NOT NULL DROP TABLE proj.Clients;
IF OBJECT_ID('proj.PersonalInfo') IS NOT NULL DROP TABLE proj.PersonalInfo;
IF OBJECT_ID('proj.MarketDay') IS NOT NULL DROP TABLE proj.MarketDay;
IF OBJECT_ID('proj.Symbol') IS NOT NULL DROP TABLE proj.Symbol;
IF OBJECT_ID('proj.Sectors') IS NOT NULL DROP TABLE proj.Sectors;
IF OBJECT_ID('proj.Industries') IS NOT NULL DROP TABLE proj.Industries;
IF OBJECT_ID('proj.Exchange') IS NOT NULL DROP TABLE proj.Exchange;
IF OBJECT_ID('proj.Country') IS NOT NULL DROP TABLE proj.Country;

--go
--CREATE SCHEMA proj

go
CREATE TABLE proj.Country (
	CountryID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(256) NULL
	)

CREATE TABLE proj.Exchange (
	ExchangeID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(256) NULL
	)

CREATE TABLE proj.Industries (
	IndustryID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(256) NULL
	)

CREATE TABLE proj.Sectors (
	SectorID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(256) NULL
	)

CREATE TABLE proj.Symbol (
	SymbolID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(256) NULL,
	CountryID INT NOT NULL REFERENCES proj.Country(CountryID),
	ExchangeID INT NOT NULL REFERENCES proj.Exchange(ExchangeID),
	IndustryID INT NOT NULL REFERENCES proj.Industries(IndustryID),
	SectorID INT NOT NULL REFERENCES proj.Sectors(SectorID))

CREATE TABLE proj.MarketDay (
	[Date] DATE,
	SymbolID INT REFERENCES proj.Symbol(SymbolID),
	Volume INT NULL,
	PriceOpen FLOAT NULL,
	PriceClose FLOAT NULL,
	PRIMARY KEY ([Date], SymbolID))

CREATE TABLE proj.PersonalInfo (
	PersonalInfoID INT PRIMARY KEY IDENTITY,
	Username VARCHAR(64) NOT NULL,
	[Password] VARCHAR(64) NOT NULL,
	Email VARCHAR(64) NOT NULL,
	FName VARCHAR(32) NOT NULL,
	LName VARCHAR(32) NOT NULL,
	Address VARCHAR(128) NOT NULL)

CREATE TABLE proj.Clients (
	ClientID INT PRIMARY KEY IDENTITY,
	PersonalInfoID INT NOT NULL REFERENCES proj.PersonalInfo(PersonalInfoID))

CREATE TABLE proj.Brokers (
	BrokerID INT PRIMARY KEY IDENTITY,
	PersonalInfoID INT NOT NULL REFERENCES proj.PersonalInfo(PersonalInfoID))

CREATE TABLE proj.Transactions (
	TransactionID INT PRIMARY KEY IDENTITY,
	SymbolID INT NOT NULL REFERENCES proj.Symbol(SymbolID),
	ClientID INT NOT NULL REFERENCES proj.Clients(ClientID),
	BrokerID INT NOT NULL REFERENCES proj.Brokers(BrokerID),
	Quantity INT DEFAULT (0),
	Price INT NULL)

CREATE TABLE proj.Portfolio (
	PortfolioID INT IDENTITY PRIMARY KEY NOT NULL,
	[Type] VARCHAR(256) NOT NULL)

CREATE TABLE proj.BrokerPortfolio (
	BrokerID INT NOT NULL REFERENCES proj.Brokers(BrokerID),
	PortfolioID INT NOT NULL REFERENCES proj.Portfolio(PortfolioID),
	PRIMARY KEY(BrokerID, PortfolioID))
