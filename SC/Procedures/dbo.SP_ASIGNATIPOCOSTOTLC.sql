SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_ASIGNATIPOCOSTOTLC] (@SPI_CODIGO INT)   as

		EXEC SP_DROPTABLE 'TempTipoCostotlc'

	SELECT  BOM_STRUCT.BST_CODIGO, 
	esGravable=case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
				         FROM CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO
				         WHERE CERTORIGMP.SPI_CODIGO = @SPI_CODIGO
					 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= getdate() AND CERTORIGMP.CMP_VFECHA >= getdate()) and
  				         pa_origen in (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO = @SPI_CODIGO) then
					'X' else (case when ma_servicio='S' then 'X' else 'S' end) end,
	esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
		esMP=case when cft_Tipo in ('R', 'L', 'M', 'O') then 'S' else 'N' end,
		esSUB=case when cft_Tipo ='S' then 'S' else 'N' end, 'Z' AS bst_tipocosto
		into dbo.TempTipoCostotlc
			FROM         BOM_STRUCT INNER JOIN
			                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO


	update TempTipoCostotlc
	set bst_tipocosto=case when esMP = 'S' then (
			case when esGravable = 'S'
			then 
			 	(case when esAnadido = 'N'   -- MP Gravable 
				then  'A'				else   -- MP Gravable Aadida
				'B'
				end)
			else
				(case when esGravable = 'N' -- MP No Gravable
				then 
					(case when esAnadido = 'N'   -- MP No Gravable
					then 
					'C'
					else -- MP No Gravable Anyadida  
						'D'
					end)
				when esGravable = 'X'  -- esGravable ='X'   MP No Gravable, pero gravable para usa
				then 
					(case when esAnadido = 'N'   
					then 
						'N'
					else -- MP No Gravable Anyadida, , pero gravable para usa
						'P'
					end)
				end)
			end)
		when esSUB='S'
		then 
		'S'	
		else
			(case when esGravable = 'S' or  esGravable = 'X'-- Empaque Gravable para usa
			then 
				'E'
			else -- Empaque No Gravable
				'F'
			end)
		end































GO
