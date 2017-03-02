SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
















































CREATE PROCEDURE [dbo].[SP_FILL_BOM_DESCTEMPALM] (@FED_INDICED INT, @BST_PT Int, @BST_ENTRAVIGOR DateTime, @FED_CANT decimal(38,6), @CODIGOFACTURA INT, @ALMORIGEN INT, @ALMDESTINO INT, @ALMDORIGEN INT, @ALMDDESTINO INT)   as


declare @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_DISCH char(1), @TI_CODIGO char(1), @ME_CODIGO int, @Factconv decimal(28,14), 
    @BST_PERINI datetime, @BST_PERFIN datetime, @ME_GEN int, @BST_TRANS char(1), @BST_TIPOCOSTO char(1), 
    @MA_TIP_ENS char(1), @CF_USATIPOADQUISICION char(1), @CF_NIVELES INT, @BST_PERINI2 datetime,
    @BST_TIPODESC varchar(5)

/*
SELECT     @CF_USATIPOADQUISICION = CF_USATIPOADQUISICION, @CF_NIVELES = CF_NIVELES
FROM         dbo.CONFIGURACION


declare CUR_BOMSTRUCT cursor for
-- incorporacion
SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
                      dbo.BOM_STRUCT.BST_TIP_ENS, 'N' AS BST_TIPODESC
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
                      dbo.BOM_STRUCT.BST_INCORPOR
HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
AND SUM(dbo.BOM_STRUCT.BST_INCORPOR) >0
UNION
--desperdicio
SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_DESP) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
                      dbo.BOM_STRUCT.BST_TIP_ENS, 'D' AS BST_TIPODESC
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
                      dbo.BOM_STRUCT.BST_INCORPOR
HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
AND SUM(dbo.BOM_STRUCT.BST_DESP) >0
UNION
--merma
SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_MERMA) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
                      dbo.BOM_STRUCT.BST_TIP_ENS, 'M' AS BST_TIPODESCFROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
                      dbo.BOM_STRUCT.BST_INCORPOR
HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
AND SUM(dbo.BOM_STRUCT.BST_MERMA) >0


 OPEN CUR_BOMSTRUCT


	FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_DISCH, @TI_CODIGO, 			
	@ME_CODIGO, @FACTCONV, @BST_PERINI, @BST_PERFIN, @ME_GEN, @BST_TRANS, @BST_TIPOCOSTO,
	@MA_TIP_ENS, @BST_TIPODESC

  WHILE (@@fetch_status = 0) 

  BEGIN  

	if @TI_CODIGO<>'P' and @TI_CODIGO<>'S'

		begin
			insert into bom_desctemp(FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
			    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
			    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC,
			   BST_PERTENECE, ALM_ORIGEN, ALM_DESTINO, ALMD_ORIGEN, ALMD_DESTINO)
			values
			(@FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @BST_HIJO, @BST_INCORPOR, @BST_DISCH, @TI_CODIGO, @ME_CODIGO, 
			@FACTCONV, @BST_PERINI, @BST_PERFIN, @ME_GEN, @BST_TRANS, @BST_TIPOCOSTO,
			@MA_TIP_ENS, @FED_CANT, @CODIGOFACTURA, 'B1', @BST_TIPODESC, @BST_PT, @ALMORIGEN, @ALMDESTINO,
			@ALMDORIGEN, @ALMDDESTINO)

		end
	else

	begin

	if @CF_USATIPOADQUISICION='S'
		begin
	
			if @MA_TIP_ENS='F' 
			begin

			
				exec  SP_FILL_BOM_DESCTEMP1 @FED_INDICED, @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, @BST_PERINI, 
				@FED_CANT, @CODIGOFACTURA, @CF_USATIPOADQUISICION, @BST_INCORPOR, @CF_NIVELES, 1, @ALMORIGEN, @ALMDESTINO, @ALMDORIGEN, @ALMDDESTINO
			end

			if @MA_TIP_ENS='C' or @MA_TIP_ENS='A' or @MA_TIP_ENS='E' or @MA_TIP_ENS='O' 

			begin
				insert into bom_desctemp(FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
				    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
				    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE,
					ALM_ORIGEN, ALM_DESTINO, ALMD_ORIGEN, ALMD_DESTINO)
				values
				(@FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @BST_HIJO, @BST_INCORPOR, @BST_DISCH, @TI_CODIGO, @ME_CODIGO, 
				@FACTCONV, @BST_PERINI, @BST_PERFIN, @ME_GEN, @BST_TRANS, @BST_TIPOCOSTO,
				@MA_TIP_ENS, @FED_CANT, @CODIGOFACTURA, 'B1', @BST_TIPODESC, @BST_PT, @ALMORIGEN, @ALMDESTINO,
				@ALMDORIGEN, @ALMDDESTINO)

				--print @MA_TIP_ENS
			end

		end

		else
		begin

			exec  SP_FILL_BOM_DESCTEMP1 @FED_INDICED, @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, @BST_PERINI, 
			@FED_CANT, @CODIGOFACTURA, @CF_USATIPOADQUISICION, @BST_INCORPOR, @CF_NIVELES, 1, @ALMORIGEN, @ALMDESTINO, @ALMDORIGEN, @ALMDDESTINO

		end
	end



	FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_DISCH, @TI_CODIGO, 			
	@ME_CODIGO, @FACTCONV, @BST_PERINI, @BST_PERFIN, @ME_GEN, @BST_TRANS, @BST_TIPOCOSTO,
	@MA_TIP_ENS, @BST_TIPODESC

END

	CLOSE CUR_BOMSTRUCT
	DEALLOCATE CUR_BOMSTRUCT













*/

































GO