SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [DEL_REGLAORIGEN] on dbo.REGLAORIGEN 
for delete
as
  if exists(select *
            from   ArancelReglaOrigen
            where  [ARR_Codigo] in (select [ARR_Codigo]
                                    from   deleted))
  begin
     raiserror('La regla de origen no puede ser borrada por tener relación con fracciones arancelarias.', 16, 1)
     rollback transaction
  end
GO
