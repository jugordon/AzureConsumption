
--- Modificar CostUser por usuario de SQL a utilizar ---


-- Permisos de ejecucion para stored procedures y funciones 

GRANT EXECUTE ON [dbo].[udf_GetNumeric] TO CostUser;
GRANT EXECUTE ON OBJECT::cost.limpiaPeriodoGenericov2 TO CostUser;
GRANT EXECUTE ON OBJECT::dbo.USP_CheckDatabase TO CostUser;
GRANT EXECUTE ON OBJECT::dbo.USP_FinishCostManagementLogMC TO CostUser;
GRANT EXECUTE ON OBJECT::dbo.USP_GetCostManagementLogMC TO CostUser;
GRANT EXECUTE ON OBJECT::dbo.USP_InsertCostManagementLogMC TO CostUser;
GRANT EXECUTE ON OBJECT::dbo.USP_UpdateCostManagementLogMC TO CostUser;


--- Permisos de lectura y escritura para tablas
GRANT SELECT,INSERT,ALTER,DELETE,UPDATE,CONTROL ON SCHEMA::cost TO CostUser;