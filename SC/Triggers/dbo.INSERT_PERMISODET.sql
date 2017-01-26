SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE TRIGGER [INSERT_PERMISODET] ON dbo.PERMISODET  
FOR INSERT 
AS 
begin 
DECLARE @saldo decimal(38,6), @cantidad decimal(38,6), @ped_enuso char(1), @CostoTotal decimal(38,6), @SaldoValor decimal(38,6)
	select @saldo = PED_SALDO, @cantidad = PED_CANT, @CostoTotal = PED_COSTOT, @SaldoValor = PED_SALDOCOSTOT, @ped_enuso=ped_enuso from inserted 
 
	if (@saldo <> @cantidad) and @ped_enuso='N'
	UPDATE PERMISODET 
	SET PED_SALDO = PED_CANT 
	 WHERE PED_INDICED IN (SELECT PED_INDICED FROM INSERTED) 
	AND PED_SALDO < PED_CANT and ped_enuso='N'
 
 
 
end































GO
