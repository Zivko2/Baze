SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER [INS_CTRANSPOR] ON dbo.CTRANSPOR 
FOR INSERT
AS
DECLARE @CTRANSPORTISTA INT
begin
  select @CTRANSPORTISTA = ct_codigo from inserted

 if @CTRANSPORTISTA is not null
  insert into relctranspormediotran(ct_codigo, mt_codigo)
values (@ctransportista, 8)
end

































GO
