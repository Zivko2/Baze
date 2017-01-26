SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_fillpedimpprueba] (@picodigo int)   as

SET NOCOUNT ON 
declare @ccp_tipo varchar(5)

	if exists(select * from pedimpprueba where pi_codigo=@picodigo)
	delete from pedimpprueba where pi_codigo=@picodigo

	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@picodigo)

	if @ccp_tipo <>'RE'
	begin
		insert into pedimpprueba (PI_CODIGO, PIS_FOLIODOC, PIS_FECHADOC, PRU_CODIGO, PIS_IMPUESTOUSA)
		SELECT     @picodigo, dbo.ENTRYSUM.ET_ENTRY_NO, dbo.ENTRYSUM.ET_FEC_ENTRYS, 2, ROUND(SUM(isnull(dbo.ENTRYSUM.ET_DLLS_RATE,0)),6)
		FROM         dbo.ENTRYSUM INNER JOIN
		                      dbo.FACTEXP ON dbo.ENTRYSUM.ET_CODIGO = dbo.FACTEXP.ET_CODIGO
		WHERE     (dbo.FACTEXP.PI_CODIGO = @picodigo) 
		and dbo.ENTRYSUM.ET_ENTRY_NO not in (select PIS_FOLIODOC from pedimpprueba where pi_codigo= @picodigo)
		GROUP BY dbo.ENTRYSUM.ET_ENTRY_NO, dbo.ENTRYSUM.ET_FEC_ENTRYS
		HAVING SUM(isnull(dbo.ENTRYSUM.ET_DLLS_RATE,0))>0
	
	end
	else
	begin
		insert into pedimpprueba (PI_CODIGO, PIS_FOLIODOC, PIS_FECHADOC, PRU_CODIGO, PIS_IMPUESTOUSA)
		SELECT     @picodigo, dbo.ENTRYSUM.ET_ENTRY_NO, dbo.ENTRYSUM.ET_FEC_ENTRYS, 2, ROUND(SUM(isnull(dbo.ENTRYSUM.ET_DLLS_RATE,0)),6)
		FROM         dbo.ENTRYSUM INNER JOIN
		                      dbo.FACTEXP ON dbo.ENTRYSUM.ET_CODIGO = dbo.FACTEXP.ET_CODIGO
		WHERE     (dbo.FACTEXP.PI_RECTIFICA = @picodigo) 
		and dbo.ENTRYSUM.ET_ENTRY_NO not in (select PIS_FOLIODOC from pedimpprueba where pi_codigo= @picodigo)
		GROUP BY dbo.ENTRYSUM.ET_ENTRY_NO, dbo.ENTRYSUM.ET_FEC_ENTRYS
		HAVING SUM(isnull(dbo.ENTRYSUM.ET_DLLS_RATE,0))>0
	
	end



GO
