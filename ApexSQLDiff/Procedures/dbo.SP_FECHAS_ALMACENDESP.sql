SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























































CREATE PROCEDURE dbo.SP_FECHAS_ALMACENDESP   as



DECLARE @codigo INTEGER,@pi_codigo INTEGER,@fe_codigo INTEGER,@am_codigo INTEGER
DECLARE @fecha DATETIME

DECLARE curPedimentos CURSOR  FOR 
SELECT ADE_CODIGO,FETR_CODIGO FROM ALMACENDESP WHERE  FETR_TIPO='P' AND FETR_CODIGO > 0

OPEN curPedimentos
FETCH NEXT FROM curPedimentos INTO @codigo,@pi_codigo

while (@@FETCH_STATUS = 0) 
begin
   select @fecha=PI_FEC_ENT from pedimp where PI_CODIGO = @pi_codigo
   update ALMACENDESP set ADE_FECHA=@fecha where ADE_CODIGO=@codigo
   
   FETCH NEXT FROM curPedimentos INTO @codigo,@pi_codigo
end
close curPedimentos
deallocate curPedimentos


DECLARE curFacturas CURSOR  FOR 
SELECT ADE_CODIGO,FETR_CODIGO FROM ALMACENDESP WHERE FETR_TIPO <> 'P' AND FETR_CODIGO > 0

OPEN curFacturas
FETCH NEXT FROM curFacturas INTO @codigo,@fe_codigo

while (@@FETCH_STATUS = 0) 
begin
   select @fecha=FE_FECHA from FACTEXP where FE_CODIGO = @fe_codigo
   update ALMACENDESP set ADE_FECHA=@fecha where ADE_CODIGO=@codigo
   
   FETCH NEXT FROM curFacturas INTO @codigo,@fe_codigo
end
close curFacturas
deallocate curFacturas

DECLARE curAlmacenDesp CURSOR  FOR 
SELECT ADE_CODIGO,AM_CODIGO FROM ALMACENDESP WHERE AM_CODIGO > 0

OPEN curAlmacenDesp
FETCH NEXT FROM curAlmacenDesp INTO @codigo,@am_codigo

while (@@FETCH_STATUS = 0) 
begin
   select @fecha=AM_REFERFECHA from ALMACENDESPCAR where AM_CODIGO = @am_codigo
   update ALMACENDESP set ADE_FECHA=@fecha where ADE_CODIGO=@codigo
   
   FETCH NEXT FROM curAlmacenDesp INTO @codigo,@am_codigo
end
close curAlmacenDesp
deallocate curAlmacenDesp

--delete ALMACENDESP where ADE_FECHA IS NULL





GO
