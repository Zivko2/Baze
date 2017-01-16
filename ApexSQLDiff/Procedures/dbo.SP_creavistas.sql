SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_creavistas] (@fechaini varchar(11), @fechafin varchar(11))   as


		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vInvXDescRetorno]') and OBJECTPROPERTY(id, N'IsView') = 1)
	drop view [dbo].[vInvXDescRetorno]
	
	exec ('CREATE VIEW dbo.vInvXDescRetorno
	AS
	SELECT     SUM(dbo.FACTEXPDET.FED_CANT * dbo.FACTEXPDET.EQ_GEN) AS CANT, dbo.FACTEXPDET.MA_GENERICO
	FROM         dbo.FACTEXPDET LEFT OUTER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATFACT ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO
	WHERE     (dbo.FACTEXPDET.FED_DISCHARGE = ''S'') AND (dbo.FACTEXP.FE_CANCELADO = ''N'') AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = ''A'') AND 
	                      (dbo.FACTEXP.FE_FECHA >= '''+@fechaini+''') AND (dbo.FACTEXP.FE_FECHA <= '''+@fechafin+''')
	GROUP BY dbo.FACTEXPDET.MA_GENERICO')


	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VInvCantDescGen]') and OBJECTPROPERTY(id, N'IsView') = 1)
	drop view [dbo].[VInvCantDescGen]

	exec ('CREATE VIEW dbo.VInvCantDescGen
	AS
	SELECT     round(SUM(dbo.FACTEXPDET.FED_CANT * dbo.RETRABAJO.RE_INCORPOR * dbo.RETRABAJO.FACTCONV),6) AS CANT, dbo.RETRABAJO.MA_GENERICO
	FROM         dbo.RETRABAJO INNER JOIN
	                      dbo.FACTEXPDET ON dbo.RETRABAJO.FETR_INDICED = dbo.FACTEXPDET.FED_INDICED LEFT OUTER JOIN
		dbo.FACTEXP ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
		dbo.CONFIGURATFACT ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO
	WHERE     (dbo.FACTEXPDET.FED_RETRABAJO = ''E'' OR
	             dbo.FACTEXPDET.FED_RETRABAJO = ''D'') AND (dbo.FACTEXP.FE_CANCELADO = ''N'') 
		AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = ''A'') and (dbo.FACTEXP.FE_FECHA >= '''+@fechaini+''') AND (dbo.FACTEXP.FE_FECHA <= '''+@fechafin+''')
	GROUP BY dbo.RETRABAJO.MA_GENERICO')


	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VInvCantDescGen1]') and OBJECTPROPERTY(id, N'IsView') = 1)
	drop view [dbo].[VInvCantDescGen1]


	exec ('CREATE VIEW dbo.VInvCantDescGen1
	AS
	SELECT     round(SUM(KAP_CANTDESC),6) AS KAP_CANTDESC, KAP_PADRESUST
	FROM         dbo.KARDESPED
	WHERE     (KAP_FACTRANS IN
	                          (SELECT     fe_codigo
	                            FROM          factexp
	                            WHERE      fe_fecha >= '''+@fechaini+''' AND fe_fecha <= '''+@fechafin+'''))
	GROUP BY KAP_PADRESUST')

GO
