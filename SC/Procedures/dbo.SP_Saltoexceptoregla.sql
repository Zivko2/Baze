SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_Saltoexceptoregla (@pt int, @fraccionhijo varchar(20), @ARG_CODIGO int, @bsthijo int, @nft_codigo int)   as

SET NOCOUNT ON 
declare @ARC_EXCEPTO varchar(10), @lenexpecto smallint, @BST_APLICAREGLAexc char(1), @prima varchar(20), @ARC_EXCEPTOF varchar(10)
SELECT     @BST_APLICAREGLAexc = BST_APLICAREGLA
FROM         dbo.CLASIFICATLC
WHERE (BST_TIPOORIG ='N')
GROUP BY dbo.CLASIFICATLC.NFT_CODIGO,  dbo.CLASIFICATLC.BST_HIJO,
dbo.CLASIFICATLC.BST_APLICAREGLA
HAVING      (dbo.CLASIFICATLC.NFT_CODIGO = @nft_codigo)  and
	      (dbo.CLASIFICATLC.BST_HIJO =@bsthijo)

	declare cur_excepto cursor for
	/* se saca la partida de excepcion y la cantidad de caracteres (len)*/
	SELECT     ARC_EXCEPTO,  LEN(ARC_EXCEPTO), ARC_EXCEPTOF
	FROM         REGLAORIGENEXCEPTO
	WHERE     (ARG_CODIGO = @ARG_CODIGO)
	open cur_excepto fetch next from cur_excepto into @ARC_EXCEPTO, @lenexpecto, @ARC_EXCEPTOF

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		set @prima= left(replace(@fraccionhijo, '.', ''), @lenexpecto) 
		if @BST_APLICAREGLAexc <> '0'
		begin
			/* se saca solo la parte del campo que se quiere comparar y se le quitan los puntos*/	
--			if @prima in (SELECT left(ARC_EXCEPTO, @lenexpecto)
--								FROM         REGLAORIGENEXCEPTO
--								WHERE     (ARG_CODIGO = @ARG_CODIGO))
			if @prima  between @ARC_EXCEPTO and @ARC_EXCEPTOF
			begin	
				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = -1
				where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
				and dbo.CLASIFICATLC.BST_HIJO = @bsthijo
				
				--print @prima
			end
			
			
		end

	fetch next from cur_excepto into @ARC_EXCEPTO, @lenexpecto, @ARC_EXCEPTOF
	END
CLOSE cur_excepto
DEALLOCATE cur_excepto
GO
