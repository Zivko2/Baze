SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure dbo.CambiarOrden (@tabla varchar(30))  as


declare @numero int, @Columnname sysname, @Colid int,@Colid1 int
/* Generar colid negativas*/
/*declare Cur_Name cursor for
SELECT NAME FROM syscolumns WHERE id=(
Select id from sysobjects where name=@tabla)
open Cur_Name

fetch next from Cur_Name into @Columnname
set @Numero=-1

WHILE (@@FETCH_STATUS <> -1)
BEGIN

	UPDATE syscolumns SET colid=@Numero
	 WHERE name=@Columnname
              AND id = (SELECT id FROM sysobjects WHERE name=@tabla)

	UPDATE syscolumns SET colorder=@Numero
	 WHERE name=@Columnname
              AND id = (SELECT id FROM sysobjects WHERE name=@tabla)

	Set @Numero=@Numero-1

FETCH NEXT FROM Cur_Name INTO @Columnname
END

CLOSE cur_Name
DEALLOCATE cur_Name

-- agregar verdaderas colid
declare Cur_Name cursor for
SELECT colid, name FROM Original.dbo.syscolumns WHERE id=(
Select id from Original.dbo.sysobjects where name=@tabla)
open Cur_Name

fetch next from Cur_Name into @Colid, @Columnname
WHILE (@@FETCH_STATUS <> -1)
BEGIN

	UPDATE syscolumns SET colid=@Colid
	 WHERE name=@Columnname
              AND id = (SELECT id FROM sysobjects WHERE name=@tabla)

	UPDATE syscolumns SET colorder=@Numero
	 WHERE name=@Columnname
              AND id = (SELECT id FROM sysobjects WHERE name=@tabla)

FETCH NEXT FROM Cur_Name INTO @Colid, @Columnname
END
CLOSE cur_Name
DEALLOCATE cur_Name

-- si quedaron negativos cambiarlos
Set @Colid1=@Colid+1
declare Cur_Name cursor for
SELECT colid, name FROM syscolumns WHERE id=(
Select id from sysobjects where name=@tabla)

open Cur_Name

fetch next from Cur_Name into @Colid, @Columnname
WHILE (@@FETCH_STATUS <> -1)
BEGIN
      if @Colid<1 
       begin
         UPDATE syscolumns SET colid=@Colid1
	 WHERE name=@Columnname
              AND id = (SELECT id FROM sysobjects WHERE name=@tabla)

	UPDATE syscolumns SET colorder=@Numero
	 WHERE name=@Columnname
              AND id = (SELECT id FROM sysobjects WHERE name=@tabla)

         Set @Colid1=@Colid1+1
       end
FETCH NEXT FROM Cur_Name INTO @Colid, @Columnname
END
CLOSE cur_Name
DEALLOCATE cur_Name

*/

GO
