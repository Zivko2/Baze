SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_FILL_KARDESPED] (@tipo char(1)=A)   as

SET NOCOUNT ON 

if @tipo is null
set @tipo='A'

	if @tipo='A'
	begin
		insert into KARDESPED (KAP_CODIGO,KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, 
		                      KAP_CANTDESC, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, 
		                      KAP_FISCOMP, KAP_PADREMAIN)
		
		SELECT      KAP_CODIGO,KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, 
		                      KAP_CANTDESC,KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, 
		                      KAP_FISCOMP, KAP_PADREMAIN
		FROM        KARDESPEDTemp where KAP_CODIGO not in (select kap_codigo from kardesped)
	             order by KAP_CODIGO
	end
	else
	begin
		insert into KARDESPED (KAP_CODIGO,KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, 
		                      KAP_CANTDESC, KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, 
		                      KAP_FISCOMP, KAP_PADREMAIN)
		
		SELECT      KAP_CODIGO,KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, MA_HIJO, KAP_TIPO_DESC, KAP_ESTATUS, 
		                      KAP_CANTDESC,KAP_CantTotADescargar, KAP_Saldo_FED, KAP_PADRESUST, 
		                      KAP_FISCOMP, KAP_PADREMAIN
		FROM        KARDESPEDTemp where KAP_CODIGO not in (select kap_codigo from kardesped) and KAP_ESTATUS='D'
	             order by KAP_CODIGO
	end

	if exists(select * from KARDESPEDTemp WHERE KAP_CODIGO in (select kap_codigo from kardesped))
	DELETE FROM KARDESPEDTemp WHERE KAP_CODIGO in (select kap_codigo from kardesped)






































GO
