USE [recyclers2]

SELECT  
	--DB_NAME(STLST.[database_id])			AS [Database]
	OBJECT_NAME(STLST.[object_id])		AS [TableName]
	, STLST.last_user_seek
	, STLST.last_user_scan
	, STLST.last_user_lookup
	, STLST.last_user_update

FROM		sys.dm_db_index_usage_stats	STLST
WHERE		STLST.database_id = DB_ID()
ORDER BY	TableName


SELECT
	OBJECT_NAME(STCNT.[object_id])	AS [ObjectName]
	--, I.name						AS [IndexName]
	, STCNT.User_Seeks				AS [NumSeeks]
	, STCNT.User_Scans				AS [NumScans]
	, STCNT.User_Lookups			AS [NumLkUps]
	, STCNT.User_Updates			AS [NumUpdates]
FROM		sys.dm_db_index_usage_stats AS STCNT
--INNER JOIN	sys.indexes					AS I		ON I.[object_id] = STCNT.[object_id] AND I.index_id = STCNT.index_id 
--WHERE		OBJECTPROPERTY(STCNT.[object_id],'IsUserTable') = 1
WHERE		STCNT.database_id = DB_ID()
ORDER BY	ObjectName





/*
SELECT  
	DB_NAME(STLST.[database_id])			AS [Database]
	, OBJECT_NAME(STLST.[object_id])	AS [TableName]
	, STLST.last_user_seek
	, STCNT.User_Seeks				AS [NumSeeks]
	, STLST.last_user_scan
	, STCNT.User_Scans				AS [NumScans]
	, STLST.last_user_lookup
	, STCNT.User_Lookups			AS [NumLkUps]
	, STLST.last_user_update
	, STCNT.User_Updates			AS [NumUpdates]
FROM		sys.dm_db_index_usage_stats	STLST
LEFT JOIN	sys.dm_db_index_usage_stats STCNT ON STCNT.[object_id] = STLST.[object_id]
WHERE		STLST.database_id = DB_ID()
ORDER BY	TableName

--*/