SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_MaestrocostTraslape]   as

	
		SELECT     MA_CODIGO 
	into dbo.[#TempMaestrocostTraslape]
	FROM         MAESTROCOST
	WHERE TCO_CODIGO=1
	GROUP BY CONVERT(varchar(50), MA_CODIGO) + '_' + CONVERT(varchar(50), MA_PERFIN, 101), MA_CODIGO
	HAVING      (COUNT(*) > 1)
	
	select ma_codigo, mac_codigo, MA_PERINI, MA_PERFIN, MA_PERFIN AS MA_PERFINPOS
	into dbo.[#TempMaestrocost]
	from MAESTROCOST 
	WHERE TCO_CODIGO=1 and ma_codigo in (select ma_codigo from #TempMaestrocostTraslape)
	order by ma_codigo, mac_codigo desc
	
	DECLARE @X DATETIME, @XANT DATETIME
	
	SET @X='01/01/9999'
	SET @XANT='01/01/9999'
	
	update #TempMaestrocost
	set MA_PERFINPOS=@X, @X=CASE WHEN @XANT=MA_PERFIN THEN MA_PERFIN ELSE @XANT-1 END, @XANT=CASE WHEN @XANT IS NOT NULL AND @XANT=MA_PERINI THEN @XANT ELSE MA_PERINI END
	
	
	update maestrocost
	set maestrocost.MA_PERFIN=#TempMaestrocost.MA_PERFINPOS
	from Maestrocost, #TempMaestrocost
	where Maestrocost.mac_codigo= #TempMaestrocost.mac_codigo



























GO
