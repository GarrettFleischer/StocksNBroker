IF OBJECT_ID('proj.BrokerPortfolios') IS NOT NULL DROP TABLE proj.BrokerPortfolios;
IF OBJECT_ID('proj.Portfolios') IS NOT NULL DROP TABLE proj.Portfolios;
IF OBJECT_ID('proj.Transactions') IS NOT NULL DROP TABLE proj.Transactions;
IF OBJECT_ID('proj.Brokers') IS NOT NULL DROP TABLE proj.Brokers;
IF OBJECT_ID('proj.Clients') IS NOT NULL DROP TABLE proj.Clients;
IF OBJECT_ID('proj.PersonalInfo') IS NOT NULL DROP TABLE proj.PersonalInfo;
IF OBJECT_ID('proj.MarketDays') IS NOT NULL DROP TABLE proj.MarketDays;
IF OBJECT_ID('proj.Symbols') IS NOT NULL DROP TABLE proj.Symbols;
IF OBJECT_ID('proj.Sectors') IS NOT NULL DROP TABLE proj.Sectors;
IF OBJECT_ID('proj.Industries') IS NOT NULL DROP TABLE proj.Industries;
IF OBJECT_ID('proj.Exchanges') IS NOT NULL DROP TABLE proj.Exchanges;
IF OBJECT_ID('proj.Countries') IS NOT NULL DROP TABLE proj.Countries;
GO

--CREATE SCHEMA proj

/** BEGIN TABLES **/

	CREATE TABLE proj.Countries 
	(
			CountryID		INT				PRIMARY KEY IDENTITY
		,	[Name]			VARCHAR(256)	NULL
	)

	CREATE TABLE proj.Exchanges
	(
			ExchangeID		INT				PRIMARY KEY IDENTITY
		,	[Name]			VARCHAR(256)	NULL
	)

	CREATE TABLE proj.Industries 
	(
			IndustryID		INT				PRIMARY KEY IDENTITY
		,	[Name]			VARCHAR(256)	NULL
	)

	CREATE TABLE proj.Sectors 
	(
			SectorID		INT				PRIMARY KEY IDENTITY
		,	[Name]			VARCHAR(256)	NULL
	)

	CREATE TABLE proj.Symbols 
	(
			SymbolID		INT				PRIMARY KEY IDENTITY
		,	[Name]			VARCHAR(256)	NULL
		,	CountryID		INT				NOT NULL REFERENCES proj.Countries(CountryID)
		,	ExchangeID		INT				NOT NULL REFERENCES proj.Exchanges(ExchangeID)
		,	IndustryID		INT				NOT NULL REFERENCES proj.Industries(IndustryID)
		,	SectorID		INT				NOT NULL REFERENCES proj.Sectors(SectorID)
	)

	CREATE TABLE proj.MarketDays 
	(
			[Date]			DATE
		,	SymbolID		INT				REFERENCES proj.Symbols(SymbolID)
		,	Volume			INT				NOT NULL
		,	PriceOpen		FLOAT			NOT NULL
		,	PriceClose		FLOAT			NOT NULL

		,	PRIMARY KEY ([Date], SymbolID)
	)

	-- Password is sha256 which is always 64 characters
	CREATE TABLE proj.PersonalInfo 
	(
			PersonalInfoID	INT				PRIMARY KEY IDENTITY
		,	Username		VARCHAR(64)		NOT NULL
		,	[Password]		CHAR(64)		NOT NULL
		,	Email			VARCHAR(64)		NOT NULL
		,	FName			VARCHAR(32)		NOT NULL
		,	LName			VARCHAR(32)		NOT NULL
		,	[Address]		VARCHAR(128)	NOT NULL
	)

	CREATE TABLE proj.Clients 
	(
			ClientID		INT				PRIMARY KEY IDENTITY
		,	PersonalInfoID	INT				NOT NULL REFERENCES proj.PersonalInfo(PersonalInfoID)
	)

	CREATE TABLE proj.Brokers
	(
			BrokerID		INT				PRIMARY KEY IDENTITY
		,	PersonalInfoID	INT				NOT NULL REFERENCES proj.PersonalInfo(PersonalInfoID)
	)

	CREATE TABLE proj.Transactions 
	(
			TransactionID	INT				PRIMARY KEY IDENTITY
		,	SymbolID		INT				NOT NULL REFERENCES proj.Symbols(SymbolID)
		,	ClientID		INT				NOT NULL REFERENCES proj.Clients(ClientID)
		,	BrokerID		INT				NOT NULL REFERENCES proj.Brokers(BrokerID)
		,	Quantity		INT				NULL DEFAULT (0)
		,	Price			INT				NULL
	)

	CREATE TABLE proj.Portfolios 
	(
			PortfolioID		INT				PRIMARY KEY IDENTITY
		,	[Type]			VARCHAR(256)	NOT NULL
	)

	CREATE TABLE proj.BrokerPortfolios 
	(
			BrokerID		INT				NOT NULL REFERENCES proj.Brokers(BrokerID)
		,	PortfolioID		INT				NOT NULL REFERENCES proj.Portfolios(PortfolioID)

		,	PRIMARY KEY(BrokerID, PortfolioID)
	)

/** END TABLES **/


/** BEGIN INDEXES **/

	CREATE INDEX IX_Countries_Name
		ON proj.Countries ([Name])


	CREATE INDEX IX_Exchanges_Name
		ON proj.Exchanges ([Name])


	CREATE INDEX IX_Industries_Name
		ON proj.Countries ([Name])


	CREATE INDEX IX_Sectors_Name
		ON proj.Sectors ([Name])


	CREATE INDEX IX_Symbols_Name
		ON proj.Symbols ([Name])
	
	CREATE INDEX IX_Symbols_CountryID
		ON proj.Symbols (CountryID)

	CREATE INDEX IX_Symbols_ExchangeID
		ON proj.Symbols (ExchangeID)

	CREATE INDEX IX_Symbols_IndustryID
		ON proj.Symbols (IndustryID)

	CREATE INDEX IX_Symbols_SectorID
		ON proj.Symbols (ExchangeID)


	CREATE INDEX IX_MarketDays_Date
		ON proj.MarketDays ([Date])

	CREATE INDEX IX_MarketDays_SymbolID
		ON proj.MarketDays (SymbolID)


	CREATE INDEX IX_PersonalInfo_Username
		ON proj.PersonalInfo (UserName)

	CREATE INDEX IX_PersonalInfo_Password
		ON proj.PersonalInfo ([Password])

	CREATE INDEX IX_PersonalInfo_Email
		ON proj.PersonalInfo (Email)

	CREATE INDEX IX_PersonalInfo_FName
		ON proj.PersonalInfo (FName)

	CREATE INDEX IX_PersonalInfo_LName
		ON proj.PersonalInfo (LName)

	CREATE INDEX IX_PersonalInfo_Address
		ON proj.PersonalInfo ([Address])


	CREATE INDEX IX_Clients_PersonalInfoID
		ON proj.Clients (PersonalInfoID)


	CREATE INDEX IX_Brokers_PersonalInfoID
		ON proj.Brokers (PersonalInfoID)


	CREATE INDEX IX_Transactions_SymbolID
		ON proj.Transactions (TransactionID)

	CREATE INDEX IX_Transactions_ClientID
		ON proj.Transactions (ClientID)

	CREATE INDEX IX_Transactions_BrokerID
		ON proj.Transactions (BrokerID)

	CREATE INDEX IX_Transactions_Price
		ON proj.Transactions (Price)


	CREATE INDEX IX_Portfolios_Type
		ON proj.Portfolios ([Type])


	CREATE INDEX IX_BrokerPortfolios_BrokerID
		ON proj.BrokerPortfolios (BrokerID)

	CREATE INDEX IX_BrokerPortfolios_PortfolioID
		ON proj.BrokerPortfolios (PortfolioID)

/** END INDEXES **/