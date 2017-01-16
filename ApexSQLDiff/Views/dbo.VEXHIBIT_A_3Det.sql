SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* mano de obra y valor agregado gravable*/
CREATE VIEW dbo.VEXHIBIT_A_3Det
with encryption as
SELECT     SUM(CSA_MO_DIR_FO) AS CSA_MO_DIR_FO, 
                      SUM(CSA_VA_GRAV) AS CSA_VA_GRAV, 
                      CS_CODIGO, FE_CODIGO, AR_FRACCION
FROM        (SELECT     SUM(dbo.FACTEXPDET.FED_GRA_MO * dbo.FACTEXPDET.FED_CANT) AS CSA_MO_DIR_FO, 
	                      SUM(dbo.FACTEXPDET.FED_GRA_GI * dbo.FACTEXPDET.FED_CANT) AS CSA_VA_GRAV, dbo.VRELCSFACTEXP.CS_CODIGO, 
	                      dbo.ARANCEL.AR_FRACCION, FACTEXP.FE_CODIGO
	FROM         dbo.ARANCEL RIGHT OUTER JOIN
	                      dbo.FACTEXPDET ON dbo.ARANCEL.AR_CODIGO = dbo.FACTEXPDET.AR_IMPFO RIGHT OUTER JOIN
	                      dbo.VRELCSFACTEXP LEFT OUTER JOIN
	                      dbo.FACTEXP ON dbo.VRELCSFACTEXP.FE_CODIGO = dbo.FACTEXP.FE_CODIGO ON 
	                      dbo.FACTEXPDET.FE_CODIGO = dbo.VRELCSFACTEXP.FE_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE     (dbo.FACTEXP.TN_CODIGO = 2) OR
	                      (dbo.FACTEXP.TN_CODIGO = 6) OR
	                      (dbo.FACTEXP.TN_CODIGO = 7) OR
	                      (dbo.FACTEXP.TN_CODIGO = 5) OR
	                      (dbo.FACTEXP.TN_CODIGO = 8) OR
	                      (dbo.FACTEXP.TN_CODIGO = 9)
	GROUP BY dbo.VRELCSFACTEXP.CS_CODIGO, dbo.ARANCEL.AR_FRACCION, FACTEXP.FE_CODIGO
	) EXHIBIT_A_3a
GROUP BY CS_CODIGO, FE_CODIGO, AR_FRACCION



GO
