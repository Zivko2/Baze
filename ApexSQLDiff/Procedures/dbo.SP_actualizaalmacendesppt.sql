SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_actualizaalmacendesppt] (@fed_indiced int)   as

SET NOCOUNT ON 

		UPDATE dbo.ALMACENDESP
		SET dbo.ALMACENDESP.PID_INDICED= dbo.KARDESPED.KAP_INDICED_PED
		FROM         dbo.PEDIMPDET RIGHT OUTER JOIN
		                      dbo.KARDESPED ON dbo.PEDIMPDET.PID_INDICED = dbo.KARDESPED.KAP_INDICED_PED RIGHT OUTER JOIN
		                      dbo.ALMACENDESP RIGHT OUTER JOIN
		                      dbo.FACTEXPDET ON dbo.ALMACENDESP.FETR_INDICED = dbo.FACTEXPDET.FED_INDICED LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO ON 
		                      dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED
		WHERE     (dbo.ALMACENDESP.FETR_TIPO = 'F' OR
		                      dbo.ALMACENDESP.FETR_TIPO = 'V') AND (dbo.FACTEXPDET.FED_RETRABAJO = 'R') AND (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
		                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') 
		and FETR_INDICED=@fed_indiced and (dbo.KARDESPED.KAP_INDICED_PED is null or dbo.KARDESPED.KAP_INDICED_PED=0
		or dbo.KARDESPED.KAP_INDICED_PED=-1) AND dbo.ALMACENDESP.PID_INDICED<> dbo.KARDESPED.KAP_INDICED_PED


GO
