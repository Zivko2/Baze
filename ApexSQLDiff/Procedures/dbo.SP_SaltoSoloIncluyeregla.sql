SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_SaltoSoloIncluyeregla (@pt int, @fraccionhijo varchar(20), @ARG_CODIGO int, @bsthijo int, @nft_codigo int, @regla smallint=1)   as

SET NOCOUNT ON 
declare @ARM_PARTIDAMP int, @ARM_PARTIDAMPF int, @lenIncluye smallint, @BST_APLICAREGLAInc char(1)
SELECT     @BST_APLICAREGLAInc = BST_APLICAREGLA
FROM         dbo.CLASIFICATLC
WHERE (BST_TIPOORIG ='N')
GROUP BY dbo.CLASIFICATLC.NFT_CODIGO,  dbo.CLASIFICATLC.BST_HIJO,
dbo.CLASIFICATLC.BST_APLICAREGLA
HAVING      (dbo.CLASIFICATLC.NFT_CODIGO = @nft_codigo)  and
	      (dbo.CLASIFICATLC.BST_HIJO =@bsthijo)
--select * from comboboxes where cb_field='BST_TIPOORIG'

	declare cur_Incluye cursor for
	/* se saca la partida de excepcion y la cantidad de caracteres (len)*/
	SELECT     ARM_PARTIDAMP,  ARM_PARTIDAMPF, LEN(ARM_PARTIDAMP)
	FROM         REGLAORIGENMP
	WHERE     (ARG_CODIGO = @ARG_CODIGO)
	open cur_Incluye fetch next from cur_Incluye into @ARM_PARTIDAMP, @ARM_PARTIDAMPF, @lenIncluye

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		if @BST_APLICAREGLAInc <> '0'
		begin
			/* se saca solo la parte del campo que se quiere comparar y se le quitan los puntos*/	
			if @fraccionhijo  between left(@ARM_PARTIDAMP ,len(@fraccionhijo)) and left(@ARM_PARTIDAMPF ,len(@fraccionhijo))
			begin	
				update dbo.CLASIFICATLC
				set BST_APLICAREGLA = @regla
				where dbo.CLASIFICATLC.nft_codigo = @nft_codigo
				and dbo.CLASIFICATLC.BST_HIJO = @bsthijo
				
			end
			
			
		end

	fetch next from cur_Incluye into @ARM_PARTIDAMP, @ARM_PARTIDAMPF, @lenIncluye
	END
CLOSE cur_Incluye
DEALLOCATE cur_Incluye
GO
