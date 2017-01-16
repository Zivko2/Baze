SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE dbo.[fillpedExpArt303] (@picodigo int)   as

SET NOCOUNT ON 

	UPDATE PEDIMP
	SET PI_ADVMNIMPMEX = round(isnull((select SUM(PIB_ADVMNIMPMEX) from PEDIMPDETB where pi_codigo=pedimp.pi_codigo),0),0),
	PI_ADVMNIMPUSA = round(isnull((select SUM(PIB_ADVMNIMPUSA) from PEDIMPDETB where pi_codigo=pedimp.pi_codigo),0),0),
	PI_EXCENCION = round(isnull((select SUM(PIB_EXCENCION) from PEDIMPDETB where pi_codigo=pedimp.pi_codigo),0),0),
	PI_IMPORTECONTRSINRECARGOS= round(isnull((select SUM(PIB_IMPORTECONTRSINRECARGOS) from PEDIMPDETB where pi_codigo=pedimp.pi_codigo),0),0),
	PI_IMPORTERECARGOS = round(isnull((select SUM(PIB_IMPORTERECARGOS) from PEDIMPDETB where pi_codigo=pedimp.pi_codigo),0),0), 
	PI_IMPORTECONTR = round(isnull((select SUM(PIB_IMPORTECONTR) from PEDIMPDETB where pi_codigo=pedimp.pi_codigo),0),0), 
	PI_IMPORTECONTRUSD = round(isnull((select SUM(PIB_IMPORTECONTRUSD) from PEDIMPDETB where pi_codigo=pedimp.pi_codigo),0),0)
	WHERE PI_CODIGO =@picodigo










GO
