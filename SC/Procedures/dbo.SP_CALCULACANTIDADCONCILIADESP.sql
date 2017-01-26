SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CALCULACANTIDADCONCILIADESP]   as

declare @id int, @SaldoPed decimal(38,6), @ma_codigo int, @CantPorDesc decimal(38,6)


	declare curMA_CODIGO cursor for
		select MA_CODIGO, round(Sum(PID_SALDOGEN) - END_SALDOGEN,6)
		from tempConciliaDesp where PATENTE_FOLIO is not null 
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
				select CODIGO, PID_SALDOGEN 
				from tempConciliaDesp 	
				where MA_CODIGO = @ma_codigo 
				order by PI_FEC_ENT
			open curPEDIMENTOS
			fetch next from curPEDIMENTOS into @id, @SaldoPed
			
			while (@@fetch_status = 0) and (@CantPorDesc > 0)
			begin
			
				if @CantPorDesc < @SaldoPed 
				begin
					update tempConciliaDesp 
					set FED_SALDOGEN = @CantPorDesc
					where codigo = @id

					SET @CantPorDesc = 0
				end
	
				else
				begin
					update tempConciliaDesp 
					set FED_SALDOGEN = @SaldoPed 
					where codigo = @id
					
					SET @CantPorDesc = round(@CantPorDesc - @SaldoPed,6)
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



		exec sp_droptable 'tempConciliaDespFaltantes'
		
		CREATE TABLE [dbo].[tempConciliaDespFaltantes] (
			[MA_NOPARTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[PI_CODIGO] [int] ,
			[PATENTE_FOLIO] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[MA_CODIGO] [int],
			[PI_FEC_ENT] [datetime],
			[SALDOGEN] decimal(38,6),
			[TIPO] [char] (1)) 

		--TIPO I= Se en encuentra en inventario pero no en pedimento, P= en pedimento pero no en inventario

		insert into tempConciliaDespFaltantes(MA_NOPARTE, SALDOGEN, TIPO)
		SELECT     dbo.IMPEXCELFACTEXP.NOPARTE, dbo.IMPEXCELFACTEXP.CANTIDAD, 'I'
		FROM         dbo.IMPEXCELFACTEXP LEFT OUTER JOIN
		                      dbo.tempConciliaDesp ON dbo.IMPEXCELFACTEXP.NOPARTE = dbo.tempConciliaDesp.MA_NOPARTE
		WHERE     (dbo.tempConciliaDesp.MA_NOPARTE IS NULL) AND (dbo.IMPEXCELFACTEXP.CANTIDAD IS NOT NULL)


		insert into tempConciliaDespFaltantes(SALDOGEN, MA_NOPARTE, PI_CODIGO, PATENTE_FOLIO, PI_FEC_ENT, TIPO)
		SELECT     dbo.tempConciliaDesp.PID_SALDOGEN, dbo.tempConciliaDesp.MA_NOPARTE, dbo.tempConciliaDesp.PI_CODIGO, 
		                      dbo.tempConciliaDesp.PATENTE_FOLIO, dbo.tempConciliaDesp.PI_FEC_ENT, 'P'
		FROM         dbo.IMPEXCELFACTEXP RIGHT OUTER JOIN
		                      dbo.tempConciliaDesp ON dbo.IMPEXCELFACTEXP.NOPARTE = dbo.tempConciliaDesp.MA_NOPARTE
		WHERE     (dbo.IMPEXCELFACTEXP.NOPARTE IS NULL)


GO
