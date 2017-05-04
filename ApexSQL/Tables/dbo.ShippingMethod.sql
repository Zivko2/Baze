SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShippingMethod] (
		[Oid]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Description]              [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[DeliveryAddress]          [uniqueidentifier] NULL,
		[DeliveryPhoneNumber1]     [uniqueidentifier] NULL,
		[DeliveryPhoneNumber2]     [uniqueidentifier] NULL,
		[VolumeBasedCharges]       [bit] NULL,
		[WeightBasedCharges]       [bit] NULL,
		[OptimisticLockField]      [int] NULL,
		[GCRecord]                 [int] NULL,
		CONSTRAINT [PK_ShippingMethod]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShippingMethod]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ShippingMethod_DeliveryAddress]
	FOREIGN KEY ([DeliveryAddress]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ShippingMethod]
	CHECK CONSTRAINT [FK_ShippingMethod_DeliveryAddress]

GO
ALTER TABLE [dbo].[ShippingMethod]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ShippingMethod_DeliveryPhoneNumber1]
	FOREIGN KEY ([DeliveryPhoneNumber1]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ShippingMethod]
	CHECK CONSTRAINT [FK_ShippingMethod_DeliveryPhoneNumber1]

GO
ALTER TABLE [dbo].[ShippingMethod]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ShippingMethod_DeliveryPhoneNumber2]
	FOREIGN KEY ([DeliveryPhoneNumber2]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ShippingMethod]
	CHECK CONSTRAINT [FK_ShippingMethod_DeliveryPhoneNumber2]

GO
CREATE NONCLUSTERED INDEX [iDeliveryAddress_ShippingMethod]
	ON [dbo].[ShippingMethod] ([DeliveryAddress])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDeliveryPhoneNumber1_ShippingMethod]
	ON [dbo].[ShippingMethod] ([DeliveryPhoneNumber1])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iDeliveryPhoneNumber2_ShippingMethod]
	ON [dbo].[ShippingMethod] ([DeliveryPhoneNumber2])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_ShippingMethod]
	ON [dbo].[ShippingMethod] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShippingMethod] SET (LOCK_ESCALATION = TABLE)
GO
