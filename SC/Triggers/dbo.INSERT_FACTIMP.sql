SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















CREATE TRIGGER [INSERT_FACTIMP] ON dbo.FACTIMP 
FOR INSERT
AS
SET NOCOUNT ON
declare @CF_CONS_IMP char(1), @FI_USACONSOLIDADO char(1)


	select @FI_USACONSOLIDADO=FI_USACONSOLIDADO from inserted
	select @CF_CONS_IMP=CF_CONS_IMP from configuracion


	if not update(FI_FOLIO)
	UPDATE FACTIMP
	SET FI_FOLIO=UPPER(RTRIM(FI_FOLIO))
	WHERE FI_CODIGO IN (SELECT FI_CODIGO FROM INSERTED)


	IF @CF_CONS_IMP='S' and @FI_USACONSOLIDADO<>'S'
	update factimp
	set FI_USACONSOLIDADO='S'
	where fi_codigo in (select fi_codigo from inserted)















GO
