USE [EdenMDS-TST]
	
SELECT	*
FROM	::fn_listextendedproperty
(
NULL
, 'user'
, 'dbo'
, 'table'
, 'WFDStationAndWaterBodyCodes2711'
, NULL
, NULL
)



/*
EXEC sys.sp_addextendedproperty 
	@name  = N'LogicalName',
	@value = N'',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'tblApprovalMeasurement_apm';

EXEC sys.sp_updateextendedproperty
	@name  = N'Keywords',
	@value = N'Keywords to be used for searching?',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'tblApprovalMeasurement_apm';


--SELECT CAST(VALUE AS VARCHAR(8000)) AS [DESCRIPTION]


SELECT	*
FROM	::fn_listextendedproperty
		(default
		, default
		, default
		, default
		, default
		, default
		, default
		)

*/