SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Staged].[SynchronizeVendorBillingInformationWithPAR]
AS

BEGIN

	INSERT INTO VendorBillingInformation (Oid, Name, ContactName, 
			DefaultCurrency, ExternalReferenceCode)
		SELECT NEWID(), 
			LTRIM(RTRIM(ParVendor.Name)) COLLATE DATABASE_DEFAULT, 
			LTRIM(RTRIM(ParVendor.ContactName)) COLLATE DATABASE_DEFAULT, 
			ParVendor.Currency COLLATE DATABASE_DEFAULT,
			CONVERT(VARCHAR(100), ParVendor.ID)
		FROM	[PNGBRANCH_FOR_APEX].[Par].[Apex].[Vendor] ParVendor
		WHERE   CONVERT(VARCHAR(100), ParVendor.ID) COLLATE DATABASE_DEFAULT Not IN (SELECT ExternalReferenceCode FROM VendorBillingInformation WHERE ExternalReferenceCode Is Not null)

	UPDATE VendorBillingInformation 
		SET Name = LTRIM(RTRIM(ParVendor.Name)) COLLATE DATABASE_DEFAULT,
			ContactName = LTRIM(RTRIM(ParVendor.ContactName)) COLLATE DATABASE_DEFAULT,
			DefaultCurrency = ParVendor.Currency COLLATE DATABASE_DEFAULT
		FROM VendorBillingInformation VBI 
				INNER JOIN [PNGBRANCH_FOR_APEX].[Par].[Apex].[Vendor] ParVendor ON CONVERT(VARCHAR(100), ParVendor.ID) COLLATE DATABASE_DEFAULT = VBI.ExternalReferenceCode
		WHERE VBI.ExternalReferenceCode is not null 
			AND (VBI.Name <> LTRIM(RTRIM(ParVendor.Name)) COLLATE DATABASE_DEFAULT
			  OR IsNull(VBI.ContactName, '') <> LTRIM(RTRIM(ParVendor.ContactName)) COLLATE DATABASE_DEFAULT
			  OR ISNULL(VBI.DefaultCurrency, '') <> ParVendor.Currency COLLATE DATABASE_DEFAULT)
	
	--Synchronization of the phone numbers and address from the accpac.

	DECLARE @Phone1ID UNIQUEIDENTIFIER, @Phone2ID UNIQUEIDENTIFIER, @AddressID UNIQUEIDENTIFIER
	--Import Address and phone information for Vendor's
	DECLARE @ExternalVendorID INT, @VendorAddress VARCHAR(100), @VendorCity  VARCHAR(100)
	DECLARE @VendorState VARCHAR(100), @VendorPostalCode VARCHAR(100)
	DECLARE @VendorCountry VARCHAR(100), @VendorPhone VARCHAR(100), @VendorPhone2 VARCHAR(100)
 
	DECLARE c_VendorAddress Cursor FOR 
		SELECT	[ID],
				LTRIM(RTRIM(IsNull([AddressLine1], ''))) + LTRIM(RTRIM(IsNull(' ; ' + [AddressLine2], ''))),
				LTRIM(RTRIM([City])),
				LTRIM(RTRIM([State])),
				LTRIM(RTRIM([PostalCode])),
				LTRIM(RTRIM([Country])),
				LTRIM(RTRIM([Phone1])),
				LTRIM(RTRIM([Phone2]))
		FROM	[PNGBRANCH_FOR_APEX].[Par].[Apex].[Vendor]

	OPEN c_VendorAddress

	FETCH NEXT FROM c_VendorAddress INTO
		@ExternalVendorID, @VendorAddress, @VendorCity, @VendorState, @VendorPostalCode, @VendorCountry, @VendorPhone, @VendorPhone2

	WHILE (@@FETCH_STATUS <> -1) BEGIN

		--Initialize Variables
		SELECT @AddressID = NULL, @Phone1ID = NULL, @Phone2ID = NULL

		--Prepare the Phone & Fax
		IF NOT @VendorPhone Is Null AND NOT EXISTS(SELECT * FROM VendorBillingInformation VBI LEFT JOIN PhoneNumber P ON P.Oid = VBI.PhoneNumber1 WHERE Number = @VendorPhone) BEGIN
			SET @Phone1ID = NEWID()
			INSERT INTO PhoneNumber (Oid, Number, PhoneType)
				VALUES (@Phone1ID, @VendorPhone, 'Phone')
		END		
		IF NOT @VendorPhone2 Is Null AND NOT EXISTS(SELECT * FROM VendorBillingInformation VBI LEFT JOIN PhoneNumber P ON P.Oid = VBI.PhoneNumber2 WHERE Number = @VendorPhone2) BEGIN
			SET @Phone2ID = NEWID()
			INSERT INTO PhoneNumber (Oid, Number, PhoneType)
				VALUES (@Phone2ID, @VendorPhone2, 'Phone')
		END

		IF	NOT @VendorAddress Is Null OR
			NOT @VendorCity Is Null OR
			NOT @VendorState Is Null OR
			NOT @VendorPostalCode Is Null OR
			NOT @VendorCountry Is Null BEGIN
		
			--Check if there is something different between the address on record for the vendor
			--in apex and the address from PAR
			IF NOT EXISTS(	SELECT	*
							FROM	VendorBillingInformation VBI LEFT JOIN Address A ON A.Oid = VBI.Address
							WHERE	A.Street = @VendorAddress
									AND A.City = @VendorCity
									AND A.StateProvince = @VendorState
									AND A.Country = (SELECT Oid FROM Country WHERE Name = @VendorCountry)
									AND A.ZipPostal = @VendorPostalCode) BEGIN
				--Handle the Country & Address together
				SET @AddressID = NEWID()
				IF NOT @VendorCountry Is Null BEGIN
					--Check if this country already exists
					IF NOT EXISTS(SELECT * FROM Country WHERE Name = @VendorCountry)
						INSERT INTO Country (Oid, Name) VALUES (NEWID(), @VendorCountry)

					INSERT INTO Address (Oid, Street, City, StateProvince, Country, ZipPostal)
						SELECT	@AddressID, @VendorAddress, @VendorCity, @VendorState, 
								Oid, @VendorPostalCode
						FROM	Country
						WHERE	Name = @VendorCountry

				END ELSE BEGIN
					INSERT INTO Address (Oid, Street, City, StateProvince, ZipPostal)
						VALUES (@AddressID, @VendorAddress, @VendorCity, @VendorState, @VendorPostalCode)
				END
			END
		END

		--Now that we have Address and Phone IDs, update the Vendor record
		UPDATE VendorBillingInformation 
			SET Address = CASE WHEN @AddressID Is Null THEN Address ELSE @AddressID END,
				PhoneNumber1 = CASE WHEN @Phone1ID Is Null THEN PhoneNumber1 ELSE @Phone1ID END,
				PhoneNumber2 = CASE WHEN @Phone2ID Is Null THEN PhoneNumber2 ELSE @Phone2ID END
		WHERE ExternalReferenceCode = @ExternalVendorID
		
		FETCH NEXT FROM c_VendorAddress INTO
			@ExternalVendorID, @VendorAddress, @VendorCity, @VendorState, @VendorPostalCode, @VendorCountry, @VendorPhone, @VendorPhone2

	END

	CLOSE c_VendorAddress
	DEALLOCATE c_VendorAddress
			  
	--attempt to replicate the random generator that XPO uses to mark a record deleted
	UPDATE VendorBillingInformation SET GCRecord = CONVERT(BIGINT, ROUND(((1999999999 - 10000000 -1) * RAND() + 10000000), 0)) 
	WHERE ExternalReferenceCode is not null AND ExternalReferenceCode NOT IN (SELECT CONVERT(VARCHAR(100), ID) COLLATE DATABASE_DEFAULT from [PNGBRANCH_FOR_APEX].[Par].[Apex].[Vendor])

	--Finally, if a vendor gets reactivated in the source system, then undelete it from Apex
	UPDATE VendorBillingInformation SET GCRecord = NULL
	WHERE	GCRecord is not null 
			AND ExternalReferenceCode is not null 
			AND ExternalReferenceCode IN (SELECT CONVERT(VARCHAR(100), ID) COLLATE DATABASE_DEFAULT from [PNGBRANCH_FOR_APEX].[Par].[Apex].[Vendor])

END
GO
