SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CONCILIAENTRYREVISION]   as

		insert into IMPCONCILIALOG(iml_mensaje)
	SELECT     'Entry:'+BrokerCode collate database_default +'-'+EntryNumber collate database_default +', InvNo:'+SupplierInvNo collate database_default +', HTS:'+HarmonizedNo collate database_default +', PartNo.:'+PartNumber collate database_default +', Ctry:'+Country collate database_default +
	', (Quantity: Intrade= '+convert(varchar(50),
	(select vi.Quantity from TempEntryConcilia vi 
	where vi.BrokerCode=Z.BrokerCode and vi.EntryNumber=Z.EntryNumber and vi.SupplierInvNo=Z.SupplierInvNo and vi.PartNumber=Z.PartNumber and
	vi.Country=Z.Country and vi.HarmonizedNo=Z.HarmonizedNo and vi.Texto collate database_default ='INTRADE'))
	+' Archivo= '+
	convert(varchar(50),
	(select va.Quantity from TempEntryConcilia va 
	where va.BrokerCode=Z.BrokerCode and va.EntryNumber=Z.EntryNumber and va.SupplierInvNo=Z.SupplierInvNo and va.PartNumber=Z.PartNumber and
	va.Country=Z.Country and va.HarmonizedNo=Z.HarmonizedNo and va.Texto collate database_default ='ENTRY AGENCIA'))+')'
	FROM         TempEntryConcilia Z
	WHERE     (Texto collate database_default = 'Z DIFERENCIA') AND (Quantity != 0) and PartNumber is not null


	insert into IMPCONCILIALOG(iml_mensaje)
	SELECT     'Entry:'+BrokerCode collate database_default +'-'+EntryNumber collate database_default +', InvNo:'+SupplierInvNo collate database_default +', HTS:'+HarmonizedNo collate database_default +', PartNo.:'+PartNumber collate database_default +', Ctry:'+Country collate database_default +
	', (Commercial Value: Intrade= '+convert(varchar(50),
	(select vi.CommercialValue from TempEntryConcilia vi 
	where vi.BrokerCode=Z.BrokerCode and vi.EntryNumber=Z.EntryNumber and vi.SupplierInvNo=Z.SupplierInvNo and vi.PartNumber=Z.PartNumber and
	vi.Country=Z.Country and vi.HarmonizedNo=Z.HarmonizedNo and vi.Texto collate database_default ='INTRADE'))
	+' Archivo= '+
	convert(varchar(50),
	(select va.CommercialValue from TempEntryConcilia va 
	where va.BrokerCode=Z.BrokerCode and va.EntryNumber=Z.EntryNumber and va.SupplierInvNo=Z.SupplierInvNo and va.PartNumber=Z.PartNumber and
	va.Country=Z.Country and va.HarmonizedNo=Z.HarmonizedNo and va.Texto collate database_default ='ENTRY AGENCIA'))+')'
	FROM         TempEntryConcilia Z
	WHERE     (Texto collate database_default = 'Z DIFERENCIA') AND (CommercialValue != 0) and PartNumber is not null


	insert into IMPCONCILIALOG(iml_mensaje)
	SELECT     'Entry:'+BrokerCode collate database_default +'-'+EntryNumber collate database_default +', InvNo:'+SupplierInvNo collate database_default +', HTS:'+HarmonizedNo collate database_default +', PartNo.:'+PartNumber collate database_default +', Ctry:'+Country collate database_default +
	', (Duty Value: Intrade= '+convert(varchar(50),
	(select vi.DutyValue from TempEntryConcilia vi 
	where vi.BrokerCode=Z.BrokerCode and vi.EntryNumber=Z.EntryNumber and vi.SupplierInvNo=Z.SupplierInvNo and vi.PartNumber=Z.PartNumber and
	vi.Country=Z.Country and vi.HarmonizedNo=Z.HarmonizedNo and vi.Texto collate database_default ='INTRADE'))
	+' Archivo= '+
	convert(varchar(50),
	(select va.DutyValue from TempEntryConcilia va 
	where va.BrokerCode=Z.BrokerCode and va.EntryNumber=Z.EntryNumber and va.SupplierInvNo=Z.SupplierInvNo and va.PartNumber=Z.PartNumber and
	va.Country=Z.Country and va.HarmonizedNo=Z.HarmonizedNo and va.Texto collate database_default ='ENTRY AGENCIA'))+')'
	FROM         TempEntryConcilia Z
	WHERE     (Texto collate database_default = 'Z DIFERENCIA') AND (DutyValue != 0) and PartNumber is not null
GO
