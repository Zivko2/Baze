SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















CREATE PROCEDURE [dbo].[SP_DescargaSelEquipo] (@FE_CODIGO INT, @fechaDesc Datetime)   as

SET NOCOUNT ON 
declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO),0)+1 FROM KARDESPED 

	
	if not exists (select * from kardespedtemp where kap_codigo >@consecutivo)
	dbcc checkident (kardespedtemp, reseed, @consecutivo) WITH NO_INFOMSGS

	INSERT INTO KARDESPEDTemp (KAP_FACTRANS, KAP_INDICED_FACT, KAP_INDICED_PED, 
	MA_HIJO, KAP_TIPO_DESC, KAP_CANTDESC, 
	KAP_CantTotADescargar, KAP_Saldo_FED, KAP_ESTATUS)

	SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.PID_INDICED, 
			dbo.PEDIMPDET.MA_CODIGO AS MA_HIJO,  'N', ROUND(dbo.FACTEXPDET.FED_CANT*dbo.FACTEXPDET.EQ_GEN,6), 
			ROUND(dbo.FACTEXPDET.FED_CANT*dbo.FACTEXPDET.EQ_GEN,6) AS KAP_CantTotADescargar, 0, 'D'
	FROM         dbo.MAESTRO RIGHT OUTER JOIN
	                      dbo.PEDIMPDET ON dbo.MAESTRO.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO LEFT OUTER JOIN
	                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICED LEFT OUTER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
	WHERE     (dbo.FACTEXPDET.PID_INDICED <> - 1) AND dbo.FACTEXP.FE_CODIGO=@FE_CODIGO

	if exists (select * from kardespedtemp where kap_factrans=@FE_CODIGO)
	EXEC SP_FILL_KARDESPED

	update factexpdet
	set fed_descargado='S'
	 where fe_codigo=@FE_CODIGO and pid_indiced<>-1

	if not exists (select fed_indiced from factexpdet where fe_codigo=@FE_CODIGO
	and pid_indiced=-1)
	UPDATE FACTEXP
	SET fe_fechadescarga=@fechaDesc
	WHERE FE_CODIGO=@FE_CODIGO


	exec SP_ACTUALIZAESTATUSFACTEXP @FE_CODIGO





























GO
