SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[ImportarControlResinas]   as
							 


declare @NoIncluir table(NI_Codigo int identity (1,1) not null,
						 IR_Codigo int not null,
						 IR_Descripcion varchar(300),
                         primary key clustered (NI_Codigo))

declare @RegistrosIncorrectos table(NoParteOrigen varchar(50),
							 NoParteAuxOrigen varchar(50),
							 NoParteDestino varchar(50),
							 NoParteAuxDestino varchar(50),
							 FechaInicial datetime,
							 FechaFinal datetime)

--Repetidos
insert into @RegistrosIncorrectos

select	IR_NoPartePlantaOrigen, IR_DivisionPlantaOrigen, IR_NoPartePlantaDestino, IR_DivisionPlantaDestino, 
		IR_FechaInicial, IR_FechaFinal
from	ImportacionResinas
group by IR_NoPartePlantaOrigen, IR_DivisionPlantaOrigen, IR_NoPartePlantaDestino, IR_DivisionPlantaDestino, 
		IR_FechaInicial, IR_FechaFinal
having count(*) > 1

if (select count(*) from @RegistrosIncorrectos) > 0 
	begin
		insert into @NoIncluir (IR_Codigo, IR_Descripcion)
		select IR_Codigo, 'EL registro: Origen: '+IR_NoPartePlantaOrigen+'	Planta: '+isnull(IR_DivisionPlantaOrigen,'')+'	Destino: '+IR_NoPartePlantaDestino+'	Planta: '+isnull(IR_DivisionPlantaDestino,'')+
						  '	Fecha Inicial: '+convert(varchar(11),IR_FechaInicial,101)+'	Fecha Final: '+convert(varchar(11),IR_FechaFinal,101)+' (Está Repetido)'
		from ImportacionResinas 
			inner join @RegistrosIncorrectos RI on ImportacionResinas.IR_NoPartePlantaOrigen = RI.NoParteOrigen
												 and isnull(ImportacionResinas.IR_DivisionPlantaOrigen,'') = isnull(RI.NoParteAuxOrigen,'')
												 and ImportacionResinas.IR_NoPartePlantaDestino = RI.NoParteDestino
												 and isnull(ImportacionResinas.IR_divisionPlantaDestino,'') =  isnull(RI.NoParteAuxDestino,'')
												 and ImportacionResinas.IR_FechaInicial = RI.FechaInicial
												 and ImportacionResinas.IR_FechaFinal = RI.FechaFinal
		order by ImportacionResinas.IR_NoPartePlantaOrigen, ImportacionResinas.IR_NoPartePlantaDestino
	end
										 

--Fechas finales iguales
delete from @RegistrosIncorrectos
insert into @RegistrosIncorrectos (NoParteOrigen, NoParteAuxOrigen, NoParteDestino, NoParteAuxDestino,FechaFinal)
select IR_NoPartePlantaOrigen, IR_DivisionPlantaOrigen, IR_NoPartePlantaDestino, IR_DivisionPlantaDestino, 
	   IR_FechaFinal 
from importacionResinas
group by IR_NoPartePlantaOrigen, IR_DivisionPlantaOrigen, IR_NoPartePlantaDestino, IR_DivisionPlantaDestino, 
	   IR_FechaFinal 
having count(*) > 1

if (select count(*) from @RegistrosIncorrectos) > 0 
	begin
		insert into @NoIncluir (IR_Codigo, IR_Descripcion)
		Select  IR_Codigo, 'EL registro: Origen: '+IR_NoPartePlantaOrigen+'	Planta: '+isnull(IR_DivisionPlantaOrigen,'')+'	Destino: '+IR_NoPartePlantaDestino+'	Planta: '+isnull(IR_DivisionPlantaDestino,'')+
 						   '	Fecha Inicial: '+convert(varchar(11),IR_FechaInicial,101)+'	Fecha Final: '+Convert(varchar(11),IR_FechaFinal,101)+' (Tiene fecha final igual "Fechas Translapadas")'
		  from ImportacionResinas
			inner join @RegistrosIncorrectos RI on ImportacionResinas.IR_NoPartePlantaOrigen = RI.NoParteOrigen
												 and isnull(ImportacionResinas.IR_DivisionPlantaOrigen,'') = isnull(RI.NoParteAuxOrigen,'')
												 and ImportacionResinas.IR_NoPartePlantaDestino = RI.NoParteDestino
												 and isnull(ImportacionResinas.IR_divisionPlantaDestino,'') =  isnull(RI.NoParteAuxDestino,'')
												 and ImportacionResinas.IR_FechaFinal = RI.FechaFinal
		where IR_Codigo not in (select IR_Codigo from @NoIncluir)
		order by ImportacionResinas.IR_NoPartePlantaOrigen, ImportacionResinas.IR_NoPartePlantaDestino
	end

--Estructuras Cicladas
delete from @RegistrosIncorrectos
insert into @RegistrosIncorrectos (NoParteOrigen, NoParteAuxOrigen, NoParteDestino, NoParteAuxDestino)
select IR_NoPartePlantaOrigen, IR_DivisionPlantaOrigen, IR_NoPartePlantaDestino, IR_DivisionPlantaDestino
from importacionResinas
where IR_NoPartePlantaOrigen +'-'+ IR_DivisionPlantaOrigen = IR_NoPartePlantaDestino+'-'+ IR_DivisionPlantaDestino
if (select count(*) from @RegistrosIncorrectos) > 0 
	begin
		insert into @NoIncluir (IR_Codigo, IR_Descripcion)
		Select  IR_Codigo, 'EL registro: Origen: '+IR_NoPartePlantaOrigen+'	Planta: '+isnull(IR_DivisionPlantaOrigen,'')+'	Destino: '+IR_NoPartePlantaDestino+'	Planta: '+isnull(IR_DivisionPlantaDestino,'')+
 						   '	Fecha Inicial: '+convert(varchar(11),IR_FechaInicial,101)+'	Fecha Final: '+Convert(varchar(11),IR_FechaFinal,101)+' (Es una estructura ciclada)'
		from importacionResinas
		where IR_NoPartePlantaOrigen +'-'+ IR_DivisionPlantaOrigen = IR_NoPartePlantaDestino+'-'+ IR_DivisionPlantaDestino
	end


--No. Parte origen que no existe
delete from @RegistrosIncorrectos
insert into @RegistrosIncorrectos (NoParteOrigen, NoParteAuxOrigen, NoParteDestino, NoParteAuxDestino)
select IR_NoPartePlantaOrigen, IR_DivisionPlantaOrigen, IR_NoPartePlantaDestino, IR_DivisionPlantaDestino
from ImportacionResinas IR
	left outer join maestro on maestro.ma_noparte = IR.IR_NoPartePlantaOrigen
							and maestro.ma_noparteaux = IR.IR_DivisionPlantaOrigen
where maestro.ma_codigo is null
if (select count(*) from @RegistrosIncorrectos) > 0 
	begin
		insert into @NoIncluir (IR_Codigo, IR_Descripcion)
		Select  IR_Codigo, 'EL registro: Origen: '+IR_NoPartePlantaOrigen+'	Planta: '+isnull(IR_DivisionPlantaOrigen,'')+' (No existe en catálogo Maestro)'
		from ImportacionResinas IR
			left outer join maestro on maestro.ma_noparte = IR.IR_NoPartePlantaOrigen
									and maestro.ma_noparteaux = IR.IR_DivisionPlantaOrigen
		where maestro.ma_codigo is null
	end

--No. Parte Destino que no existen	
print 'destino'	
delete from @RegistrosIncorrectos
insert into @RegistrosIncorrectos (NoParteOrigen, NoParteAuxOrigen, NoParteDestino, NoParteAuxDestino)
select IR_NoPartePlantaOrigen, IR_DivisionPlantaOrigen, IR_NoPartePlantaDestino, IR_DivisionPlantaDestino
from ImportacionResinas IR
	left outer join maestro on maestro.ma_noparte = IR.IR_NoPartePlantaDestino
							and maestro.ma_noparteaux = IR.IR_DivisionPlantaDestino
where maestro.ma_codigo is null
if (select count(*) from @RegistrosIncorrectos) > 0 
	begin
		print 'destino 2'
		insert into @NoIncluir (IR_Codigo, IR_Descripcion)
		Select  IR_Codigo, 'EL registro: Destino: '+IR_NoPartePlantaDestino+'	Planta: '+isnull(IR_DivisionPlantaDestino,'')+' (No existe en catálogo Maestro)'
		from ImportacionResinas IR
			left outer join maestro on maestro.ma_noparte = IR.IR_NoPartePlantaDestino
									and maestro.ma_noparteaux = IR.IR_DivisionPlantaDestino
		where maestro.ma_codigo is null
	end


insert into ControlResinas (MA_CodigoOrigen, MA_CodigoDestino, CRS_FechaInicial, CRS_Fechafinal, TI_CodigoOrigen, TI_CodigoDestino, MA_Tip_EnsDestino)
select	origen.ma_codigo, destino.ma_codigo, ImportacionResinas.IR_FechaInicial, ImportacionResinas.IR_FechaFinal,
		(select ti_codigo from tipo where ti_nombre = 'SUBENSAMBLE'), destino.ti_codigo, destino.MA_Tip_Ens
from Importacionresinas
	inner join maestro origen on ImportacionResinas.IR_NoPartePlantaOrigen = origen.MA_NoParte 
					  and isnull(ImportacionResinas.IR_DivisionPlantaOrigen,'') = origen.MA_NoParteAux
	inner join maestro destino on ImportacionResinas.IR_NoPartePlantaDestino = destino.MA_NoParte 
					  and isnull(ImportacionResinas.IR_DivisionPlantaDestino,'') = destino.MA_NoParteAux
	left outer join ControlResinas on origen.ma_codigo = ControlResinas.MA_CodigoOrigen 
								  and destino.ma_codigo = ControlResinas.MA_CodigoDestino
								  and ImportacionResinas.IR_FechaInicial = ControlResinas.CRS_FechaInicial
where ControlResinas.CRS_Codigo is null
  and ImportacionResinas.IR_Codigo not in (select IR_Codigo from @NoIncluir)

delete from MensajesImportacionResinas
insert into MensajesImportacionResinas(IR_Codigo, MR_Mensaje)
select IR_Codigo, IR_Descripcion from @NoIncluir

GO
