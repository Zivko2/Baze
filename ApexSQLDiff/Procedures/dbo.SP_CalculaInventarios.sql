SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE PROCEDURE dbo.SP_CalculaInventarios (@fecha DATETIME, @tipo char(1)='I')   as

-- @fecha fecha del inventario IVF_MESREFERENCIA
SET NOCOUNT ON
DECLARE @ma_codigo INTEGER,@end_saldogen decimal(38,6), @ivf_codigo INTEGER,@ivfd_can_gen decimal(38,6),@ma_noparte varchar(30),@fe_codigo INTEGER,
		@fed_saldogen decimal(38,6), @CantRestante decimal(38,6), @fed_indiced integer, @bst_pt integer, @bst_nivel char(1),@fechaini DATETIME,@fechafin DATETIME,
	    @FECHA_STRUCT DATETIME,@info varchar(100), @hora varchar(50), @CantPorDesc decimal(38,6), @id integer, @SaldosTotPed decimal(38,6), @SaldoPed decimal(38,6),@Inventario decimal(38,6),
	@ma_generico int, @CantxGenerico decimal(38,6), @CantaDescargar decimal(38,6)
	

--@tipo es I=No parte , G=Generico
-- PID_SALDOGEN saldo actual del pedimento
-- END_SALDOGEN cantidad actual en inventarios
-- FED_SALDOGEN es la cantidad que se descargaria

TRUNCATE TABLE TEMP_INVENTARIOS;
dbcc checkident (TEMP_INVENTARIOS,reseed,0) WITH NO_INFOMSGS
exec sp_droptable  'BOM_DESCTEMP'
exec sp_CreaBOM_DESCTEMP


-- Inserta los saldos de los pedimentos completos, pero solo donde la fecha del pedimento es menor que la fecha parametro 
	INSERT INTO TEMP_INVENTARIOS (MA_CODIGO, PI_FOLIO, PI_FECHA,PID_INDICED,PID_SALDOGEN,NOPARTE,TIPO, MA_GENERICO) 
	SELECT MA_CODIGO,NoPedimento, FechaPedimento,PID_INDICED,sum(PID_SALDOGEN),PID_NOPARTE,'N' , MA_GENERICO
	FROM VINVENTARIOCONCILIA 
	WHERE FechaPedimento <  (convert(DATETIME,@fecha)+1)  
	GROUP BY MA_CODIGO, NoPedimento, FechaPedimento, PID_INDICED,PID_NOPARTE, MA_GENERICO
	HAVING sum(PID_SALDOGEN) > 0

--Explosiona los Inventarios Fisicos y los Inserta en la Tabla TEMP_INVENTARIOS

	select @ivf_codigo=IVF_CODIGO from INVENTARIOFIS
	where IVF_TIPO = 'N' AND IVF_MESREFERENCIA = @fecha	

		exec sp_ExpInventarioFis @ivf_codigo


			-- se inserta lo que se encuentra en inventarios
			update TEMP_INVENTARIOS 
			SET END_SALDOGEN = isnull((select SUM(FED_CANT*BST_INCORPOR*FACTCONV) from BOM_DESCTEMP
		 				where BST_HIJO=TEMP_INVENTARIOS.ma_codigo
						having SUM(FED_CANT*BST_INCORPOR*FACTCONV) > 0),0)
			WHERE TIPO = 'N'


			INSERT INTO TEMP_INVENTARIOS (MA_CODIGO,END_SALDOGEN,NOPARTE,TIPO)
			select BST_HIJO, isnull(SUM(FED_CANT*BST_INCORPOR*FACTCONV),0) as IVFD_CANGEN, MA_NOPARTE, 'N'
			from BOM_DESCTEMP
			left outer join MAESTRO on MAESTRO.MA_CODIGO = BOM_DESCTEMP.BST_HIJO
			where FE_CODIGO=@ivf_codigo and BST_HIJO not in (select MA_CODIGO from TEMP_INVENTARIOS)
			group by BST_HIJO, MA_NOPARTE
			having SUM(FED_CANT*BST_INCORPOR*FACTCONV) > 0






-- Calcula las Cantidades pendientes por descargar por pedimento
declare curMA_CODIGO cursor for
	-- cantidad total en pedimentos menos la cantidad total en  inventarios
	select MA_CODIGO, Sum(PID_SALDOGEN) - END_SALDOGEN 
	from TEMP_INVENTARIOS where PI_FOLIO is not null  and TIPO = 'N'
	GROUP BY MA_CODIGO, END_SALDOGEN
	HAVING Sum(PID_SALDOGEN) - END_SALDOGEN >0
	order by MA_CODIGO
open curMA_CODIGO
fetch next from curMA_CODIGO into @ma_codigo, @CantPorDesc
while (@@fetch_status = 0)
begin
	if @CantPorDesc > 0
	begin 
		declare curPEDIMENTOS cursor for
			-- saldo en pedimentos		
			select ID, PID_SALDOGEN 
			from TEMP_INVENTARIOS 	
			where TIPO = 'N'  and MA_CODIGO = @ma_codigo 
			order by PI_FECHA
		open curPEDIMENTOS
		fetch next from curPEDIMENTOS into @id, @SaldoPed
		
		while (@@fetch_status = 0) and (@CantPorDesc > 0)
		begin
		
			if @CantPorDesc < @SaldoPed 
			begin
				update TEMP_INVENTARIOS set FED_SALDOGEN = @CantPorDesc where ID = @id
				SET @CantPorDesc = 0
			end

			else
			begin
				update TEMP_INVENTARIOS set FED_SALDOGEN = @SaldoPed where ID = @id
				SET @CantPorDesc = @CantPorDesc - @SaldoPed
			end

			fetch next from curPEDIMENTOS into @id, @SaldoPed

		end
		close curPEDIMENTOS
		deallocate curPEDIMENTOS
	end

	fetch next from curMA_CODIGO into @ma_codigo, @CantPorDesc
end
close curMA_CODIGO
deallocate curMA_CODIGO

if @tipo='G'
begin
	-- los registros que no encontro por numero de parte se va por generico, pero como seguramente ya se incluyeron para descargar, se le regresa la cantidad.
	declare curMA_GENERICO cursor for
		SELECT     MA_GENERICO, SUM(CANTIDAD)
		FROM         VCONCILIAGEN
		WHERE MA_GENERICO IN 
				(SELECT TEMP_INVENTARIOS1.MA_GENERICO FROM         dbo.TEMP_INVENTARIOS AS TEMP_INVENTARIOS1
				WHERE     (TEMP_INVENTARIOS1.TIPO = 'N') AND (TEMP_INVENTARIOS1.PID_SALDOGEN > TEMP_INVENTARIOS1.FED_SALDOGEN))
		GROUP BY MA_GENERICO
		ORDER BY MA_GENERICO
	open curMA_GENERICO
	fetch next from curMA_GENERICO into @ma_generico, @CantxGenerico
	while (@@fetch_status = 0)
	begin
			declare curRegresaCant cursor for
				SELECT     TOP 100 PERCENT ID, FED_SALDOGEN
				FROM         dbo.TEMP_INVENTARIOS
				WHERE     (TIPO = 'N') AND (PID_SALDOGEN > FED_SALDOGEN) AND MA_GENERICO =@ma_generico 
				ORDER BY PI_FECHA DESC
			open curRegresaCant
			fetch next from curRegresaCant into @id, @CantaDescargar
			
			while (@@fetch_status = 0) and (@CantxGenerico > 0)
			begin
	    		
				if @CantxGenerico < @CantaDescargar 
				begin
					update TEMP_INVENTARIOS 
					set FED_SALDOGEN = FED_SALDOGEN-@CantxGenerico 
					where ID = @id
	
					SET @CantxGenerico = 0
				end
				else
				begin
					update TEMP_INVENTARIOS 
					set FED_SALDOGEN = 0
					where ID = @id
	
					SET @CantxGenerico = @CantxGenerico - @CantaDescargar
				end
	
				fetch next from curRegresaCant into @id, @CantaDescargar
	
			end
			close curRegresaCant
			deallocate curRegresaCant
	
		fetch next from curMA_GENERICO into @ma_generico, @CantxGenerico
	end
	close curMA_GENERICO
	deallocate curMA_GENERICO
end


GO
