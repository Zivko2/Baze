SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_EXPLOSIONA_FACT_PARA_INV (@fechaini DATETIME, @fechafin datetime)   as


DECLARE @ma_codigo INTEGER,@end_saldogen decimal(38,6), @ivf_codigo INTEGER,@ivfd_can_gen decimal(38,6),@ma_noparte varchar(30),@fe_codigo INTEGER,
		@fed_saldogen decimal(38,6), @CantRestante decimal(38,6), @fed_indiced integer, @bst_pt integer, @bst_nivel char(1),
	    @FECHA_STRUCT DATETIME,@info varchar(100), @hora varchar(50)
		
--CALCULA INVENTARIO NORMAL
	exec sp_droptable 'TempBOM_ESTRUCTDESC'
	exec sp_creaTempBOM_ESTRUCTDESC

          DECLARE CUR_BOM_STRUCTDESC CURSOR FOR	
		SELECT     TOP 100 PERCENT dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FED_FECHA_STRUCT
		FROM         dbo.FACTEXP LEFT OUTER JOIN
		                      dbo.CONFIGURATFACT ON dbo.FACTEXP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO LEFT OUTER JOIN
		                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.FACTEXPDET.FED_RETRABAJO = 'N' OR dbo.FACTEXPDET.FED_RETRABAJO = 'A' OR dbo.FACTEXPDET.FED_RETRABAJO = 'O' OR 
		                      dbo.FACTEXPDET.FED_RETRABAJO = 'C') AND (dbo.FACTEXP.FE_FECHA >= @fechaini) AND 
		                      (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR
		                      dbo.CONFIGURATIPO.CFT_TIPO = 'S') AND (dbo.FACTEXP.FE_FECHA <= @fechafin) 
			AND (dbo.FACTEXP.FE_DESCARGADA = 'N')  
			AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') 
			AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A')  AND (dbo.FACTEXP.FE_CANCELADO = 'N') 
		GROUP BY dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FED_FECHA_STRUCT
		HAVING      (dbo.FACTEXPDET.FED_FECHA_STRUCT IS NOT NULL)
		ORDER BY dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FED_FECHA_STRUCT
	OPEN CUR_BOM_STRUCTDESC


	FETCH NEXT FROM CUR_BOM_STRUCTDESC INTO @MA_CODIGO, @FECHA_STRUCT
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		if exists (select * from bom_struct where bsu_subensamble=@ma_codigo and bst_perini<=@FECHA_STRUCT
				and bst_perfin>=@FECHA_STRUCT)
			begin
	
				select @info=ma_noparte +' '+ma_noparteaux from maestro where ma_codigo=@MA_CODIGO


				select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
				print '<========= Llenando tabla TempBOM_ESTRUCTDESC' + convert(varchar(11), @MA_CODIGO) + + convert(varchar(50), @FECHA_STRUCT) + ', '+@hora+'=========>' 
		
			
				exec SP_FILL_TempBOM_ESTRUCTDESC @MA_CODIGO, @FECHA_STRUCT
			end	
	
	FETCH NEXT FROM CUR_BOM_STRUCTDESC INTO @MA_CODIGO, @FECHA_STRUCT
	
	END
	
	CLOSE CUR_BOM_STRUCTDESC
	DEALLOCATE CUR_BOM_STRUCTDESC


-- explosionando por fuera
	exec sp_droptable  'BOM_DESCTEMP'
	exec sp_CreaBOM_DESCTEMP

	begin
		INSERT INTO BOM_DESCTEMP(FE_CODIGO, FED_INDICED, FED_CANT, BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
		BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, 
		MA_TIP_ENS, BST_NIVEL, BST_TIPODESC, BST_PERTENECE)
	
	
		SELECT     TOP 100 PERCENT dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_CANT, dbo.TempBOM_ESTRUCTDESC.BST_PT, 
		                      dbo.TempBOM_ESTRUCTDESC.BST_ENTRAVIGOR, dbo.TempBOM_ESTRUCTDESC.BST_HIJO, dbo.TempBOM_ESTRUCTDESC.BST_INCORPOR, 
		                      dbo.TempBOM_ESTRUCTDESC.BST_DISCH, dbo.TempBOM_ESTRUCTDESC.TI_CODIGO, dbo.TempBOM_ESTRUCTDESC.ME_CODIGO, 
		                      dbo.TempBOM_ESTRUCTDESC.FACTCONV, dbo.TempBOM_ESTRUCTDESC.BST_PERINI, dbo.TempBOM_ESTRUCTDESC.BST_PERFIN, 
		                      dbo.TempBOM_ESTRUCTDESC.ME_GEN, dbo.TempBOM_ESTRUCTDESC.BST_TRANS, dbo.TempBOM_ESTRUCTDESC.BST_TIPOCOSTO, 
		                      dbo.TempBOM_ESTRUCTDESC.MA_TIP_ENS, 
		                      dbo.TempBOM_ESTRUCTDESC.BST_NIVEL, dbo.TempBOM_ESTRUCTDESC.BST_TIPODESC, dbo.TempBOM_ESTRUCTDESC.BST_PERTENECE
		FROM         dbo.FACTEXPDET INNER JOIN
		                      dbo.TempBOM_ESTRUCTDESC ON dbo.FACTEXPDET.MA_CODIGO = dbo.TempBOM_ESTRUCTDESC.BST_PT AND 
		                      dbo.FACTEXPDET.FED_FECHA_STRUCT = dbo.TempBOM_ESTRUCTDESC.BST_ENTRAVIGOR RIGHT OUTER JOIN
		                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.FACTEXPDET.FED_RETRABAJO = 'N' OR dbo.FACTEXPDET.FED_RETRABAJO = 'C' OR
		                      dbo.FACTEXPDET.FED_RETRABAJO = 'A') AND (dbo.FACTEXP.FE_FECHA>=@fechaini AND  dbo.FACTEXP.FE_FECHA<=@fechafin) AND (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR
		                      dbo.CONFIGURATIPO.CFT_TIPO = 'S') AND dbo.FACTEXPDET.FED_TIP_ENS <>'A'
		GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.FED_CANT, dbo.TempBOM_ESTRUCTDESC.BST_PT, 
		                      dbo.TempBOM_ESTRUCTDESC.BST_ENTRAVIGOR, dbo.TempBOM_ESTRUCTDESC.BST_HIJO, dbo.TempBOM_ESTRUCTDESC.BST_INCORPOR, 
		                      dbo.TempBOM_ESTRUCTDESC.BST_DISCH, dbo.TempBOM_ESTRUCTDESC.TI_CODIGO, dbo.TempBOM_ESTRUCTDESC.ME_CODIGO, 
		                      dbo.TempBOM_ESTRUCTDESC.FACTCONV, dbo.TempBOM_ESTRUCTDESC.BST_PERINI, dbo.TempBOM_ESTRUCTDESC.BST_PERFIN, 
		                      dbo.TempBOM_ESTRUCTDESC.ME_GEN, dbo.TempBOM_ESTRUCTDESC.BST_TRANS, dbo.TempBOM_ESTRUCTDESC.BST_TIPOCOSTO, 
		                      dbo.TempBOM_ESTRUCTDESC.MA_TIP_ENS, 
		                      dbo.TempBOM_ESTRUCTDESC.BST_NIVEL, dbo.TempBOM_ESTRUCTDESC.BST_TIPODESC, dbo.TempBOM_ESTRUCTDESC.BST_PERTENECE
	end


-----------------------------------------------------------


declare curFACTURAS cursor for
select factexp.fe_codigo from factexpdet
left outer join factexp on factexpdet.fe_codigo = factexp.fe_codigo 
where (fe_estatus='D' or fe_estatus='P') and fe_fecha >= @fechaini and fe_fecha <= @fechafin
and factexpdet.ti_codigo in (select ti_codigo from configuratipo where cft_tipo in ('R', 'P', 'E', 'S', 'T', 'L', 'M', 'O'))
group by factexp.fe_codigo,factexp.fe_fecha
order by factexp.fe_fecha
open curFACTURAS
fetch next from curFACTURAS into @fe_codigo
while (@@fetch_status = 0)
begin
		exec SP_ExplosionDescFactExpInv @FE_CODIGO

	fetch next from curFACTURAS into @fe_codigo

end
close curFACTURAS
deallocate curFACTURAS


	EXEC SP_DROPTABLE 'RELFEDGENERICO'
	EXEC SP_DROPTABLE 'RELFEDGENERICO1'

	SELECT     FE_CODIGO, FED_INDICED, BST_HIJO, FED_CANT, substring(BST_NIVEL,1,1)AS BST_NIVEL, 
		(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=BST_HIJO) AS MA_GENERICO,
		(SELECT FE_FECHA FROM FACTEXP WHERE FE_CODIGO=FE_CODIGO) AS FE_FECHA
	INTO dbo.RELFEDGENERICO
	FROM  BOM_DESCTEMP
	WHERE BST_INCORPOR IS NOT NULL AND FED_CANT>0 and  FED_CANT is not null and BST_INCORPOR>0 AND (FACT_INV = 'F')  
	GROUP BY FE_CODIGO, FED_INDICED, BST_HIJO, substring(BST_NIVEL,1,1), FED_CANT
	HAVING  FED_CANT > 0 AND  SUM(BST_INCORPOR * FACTCONV * FED_CANT) IS NOT NULL


	-- genera una agrupacion de la tabla RELFEDGENERICO
	SELECT     FE_CODIGO, FED_INDICED, MA_GENERICO, FED_CANT, FE_FECHA
	INTO dbo.RELFEDGENERICO1
	FROM         RELFEDGENERICO
	GROUP BY FE_CODIGO, FED_INDICED, MA_GENERICO, FED_CANT, FE_FECHA



	alter table [factexpdet] disable trigger [Update_FactExpDet]

	update FACTEXPDET 
	set FED_RETRABAJO = 'E' 
	where FED_INDICED 
		in (select fed_indiced from RELFEDGENERICO1 group by fed_indiced)
	and  FED_RETRABAJO <> 'E'

	alter table [factexpdet] enable trigger [Update_FactExpDet]






































GO
