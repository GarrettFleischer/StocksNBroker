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

IF OBJECT_ID('proj.ClientBalance') IS NOT NULL DROP VIEW proj.ClientBalance;
IF OBJECT_ID('proj.MarketDaySymbols') IS NOT NULL DROP VIEW proj.MarketDaySymbols;
IF OBJECT_ID('proj.BrokerInfo') IS NOT NULL DROP VIEW proj.BrokerInfo

IF OBJECT_ID('proj.highestVolumeForDate') IS NOT NULL DROP PROCEDURE proj.highestVolumeForDate;

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
		,	[Date]			DateTime		NOT NULL	
		,	Quantity		INT				NULL DEFAULT (0)
		,	Price			INT				NULL
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
		
/** END INDEXES **/

/** BEGIN VIEWS **/
	go
	CREATE VIEW proj.ClientBalance (ClientName, BrokerName, Symbols, Balance) AS
	(
		SELECT pic.FName + pic.LName ClientName, pib.FName + pib.LName BrokerName, s.Name AS Symbols, SUM(Price * ABS(Quantity)) AS Balance
		FROM proj.Transactions AS t
			JOIN proj.Clients AS c
				ON t.ClientID = c.ClientID
			JOIN proj.PersonalInfo AS pic
				ON c.PersonalInfoID = pic.PersonalInfoID
			JOIN proj.Brokers AS b
				ON t.BrokerID = b.BrokerID
			JOIN proj.PersonalInfo AS pib
				ON b.PersonalInfoID = pib.PersonalInfoID
			JOIN proj.Symbols AS s
				ON s.SymbolID = t.SymbolID
		GROUP BY pic.FName + pic.LName, pib.Fname + pib.LName, s.Name
	);

	go
	CREATE VIEW proj.MarketDaySymbols (Symbols, Date, Volume, PriceOpen, PriceClose, Sectors, Industries, Exchanges, Countries) AS
	(
		SELECT s.Name AS Symbols, md.Date, md.Volume, md.PriceOpen, md.PriceClose, sec.Name AS Sectors, i.Name AS Industries, e.Name AS Exchanges, c.Name AS Countries
		FROM proj.Symbols AS s
			JOIN proj.MarketDays AS md
				ON s.SymbolID = md.SymbolID
			JOIN proj.Sectors AS sec
				ON sec.SectorID = s.SectorID
			JOIN proj.Industries AS i
				ON i.IndustryID = s.IndustryID
			JOIN proj.Exchanges AS e
				ON e.ExchangeID = s.ExchangeID
			JOIN proj.Countries AS c
				ON c.CountryID = s.CountryID
	);

	go
	CREATE VIEW proj.BrokerInfo (BrokerID, [Name], Username, Email, Address, ClientID, ClientName, SectorName) AS
	(
		SELECT b.BrokerID, pib.FName + pib.LName, pib.Username, pib.Email, pib.Address, c.ClientID, pic.FName + pic.LName, sec.Name
		FROM proj.Transactions AS t
			JOIN proj.Brokers AS b
				ON t.BrokerID = b.BrokerID
			JOIN proj.PersonalInfo AS pib
				ON pib.PersonalInfoID = b.PersonalInfoID
			JOIN proj.Clients AS c
				ON c.ClientID = t.ClientID
			JOIN proj.PersonalInfo AS pic
				ON pic.PersonalInfoID = c.PersonalInfoID
			JOIN proj.Symbols AS s
				ON s.SymbolID = t.SymbolID
			JOIN proj.Sectors AS sec
				ON sec.SectorID = s.SectorID
	);

/** END VIEWS **/

/** BEGIN QUERIES **/

	-- Highest volume of the given day
	go
	CREATE PROCEDURE proj.highestVolumeForDate
	(
		@Date Date
	)
	AS
		SELECT TOP (1) md.Date, sec.SectorID, sec.Name AS SectorName, SUM(md.Volume) AS TotalVolume
		FROM proj.MarketDays AS md
			JOIN proj.Symbols AS s
				ON md.SymbolID = s.SymbolID
			JOIN proj.Sectors AS sec
				ON s.SectorID = sec.SectorID
		WHERE md.Date = @Date
		GROUP BY md.Date, sec.SectorID, sec.Name
		ORDER BY Volume DESC;

/** END QUERIES **/

/** BEGIN INSERTS **/

	go
	INSERT INTO proj.PersonalInfo
	(Username, Password, Email, FName, LName, Address)
	VALUES	('Bob.Marley','dontworry','bob.marley@hotmail.com','Bob','Marley','Nine Miles, Saint Ann, Jamaica'),
			('Ozzy.Osbourne', 'hellsbells', 'ozzy.osbourne@gmail.com','Ozzy','Osbourne','Los Angeles, California'),
			('James.Hetfield', 'unforgiven', 'james.hetfield@yahoo.com',	'James', 'Hetfield', 'Los Angeles, California'),
			('John.Lennon',	'yellowSubmarine',	'john.lennon@aol.com', 'John', 'Lennon', 'Manhattan, New York City, NY'),
			('Steven.Tyler',	'dreamOn', 'steven.tyler@gmail.com', 'Steven', 'Tyler',	'Hollywood, California'),
			('Robert.Plant',	'stairwayToHeaven',	'robert.plant@hotmail.com',	'Robert', 'Plant', 'England'),
			('Brian.Johnson', 'highwayToHell', 'brian.johnson@gmail.com', 'Brian', 'Johnson', 'Kangaroo Island, Australia');

	go
	INSERT INTO proj.Clients
	(PersonalInfoID)
	VALUES ('1'), ('2'), ('3'), ('4'), ('5')

	go
	INSERT INTO proj.Brokers
	(PersonalInfoID)
	VALUES ('6'), ('7')

go
	INSERT INTO proj.Transactions 
	(SymbolID, ClientID, BrokerID, [Date], Quantity, Price)
	VALUES	(401, 1, 1, '2016-11-30', 500, -6),
			(2400, 1, 1, '2016-11-30', 1000, -0.96),
			(2226, 1, 1, '2016-11-30', 50, -150),
			(1234, 2, 1, '2016-11-30', 450, -25),
			(12, 2, 1, '2016-11-30', 325, -1.75),
			(456, 2, 1, '2016-11-30', 40, -25),
			(678, 3, 1, '2016-11-30', 25, -50.25),
			(2578, 3, 1, '2016-11-30', 50, -5),
			(1543, 3, 1, '2016-11-30', 1000, -0.52),
			(1673, 4, 2, '2016-11-30', 2500, -0.67),
			(1367, 4, 2, '2016-11-30', 3500, -0.01),
			(467, 4, 2, '2016-11-30', 1200, -3),
			(356, 5, 2, '2016-11-30', 550, -8),
			(235, 5, 2, '2016-11-30', 400, -5),
			(124, 5, 2, '2016-11-30', 1000, -3.45),
			(52, 6, 2, '2016-11-30', 4325, -0.32),
			(586, 6, 2, '2016-11-30', 3232, -0.58),
			(1854, 6, 2, '2016-11-30', 674, -2.46),

			(401, 1, 1, '2016-12-1', -250, 8),
			(2400, 1, 1, '2016-12-1', -1000, 0.50),
			(2226, 1, 1, '2016-12-1', -40, 158),
			(1234, 2, 1, '2016-12-1', -450, 20),
			(12, 2, 1, '2016-12-1', -100, 1.95),
			(456, 2, 1, '2016-12-1', -40, 30),
			(678, 3, 1, '2016-12-1', -15, 51.32),
			(2578, 3, 1, '2016-12-1', -50, 4.50),
			(1543, 3, 1, '2016-12-1', -500, 0.69),
			(1673, 4, 2, '2016-12-1', -1500, 0.90),
			(1367, 4, 2, '2016-12-1', -2500, 0.05),
			(467, 4, 2, '2016-12-1', -500, 3.50),
			(356, 5, 2, '2016-12-1', -250, 8.94),
			(235, 5, 2, '2016-12-1', -400, 4.23),
			(124, 5, 2, '2016-12-1', -100, 3.50),
			(52, 6, 2, '2016-12-1', -2325, 0.57),
			(586, 6, 2, '2016-12-1', -2232, 0.75),
			(1854, 6, 2, '2016-12-1', -674, 3.46);

/** END INSERTS **/