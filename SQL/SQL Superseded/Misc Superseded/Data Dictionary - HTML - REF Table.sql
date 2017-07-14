USE [EdenMDS-TST]

SET NOCOUNT ON

DECLARE @TableName		NVARCHAR(35)
DECLARE @ServerName		NVARCHAR(50)
DECLARE @DatabaseName	NVARCHAR(50)
DECLARE @TimeGenerated	DATETIME

SET	@ServerName			= CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(50))
SET	@DatabaseName		= CAST(DB_NAME() AS NVARCHAR(50))
SET	@TimeGenerated		= GETDATE()

-- *********************************************************
-- *** Obtain reference tables from foreign key constraints
IF  OBJECT_ID('TempDB..##tmpRefTables') IS NOT NULL
    DROP TABLE #tmpRefTables
ELSE
    DROP TABLE #tmpRefTables

SELECT 
A.name			[nmTable]
, B.name		[nmAttribute]
, G.name		[nmRefTable]

INTO #tmpRefTables
FROM sysobjects						A
JOIN syscolumns						B	ON	A.id = B.id
JOIN systypes						C	ON	B.xtype = C.xtype 
LEFT JOIN (	SELECT  SO.id, SC.colid, SC.name 
			FROM    syscolumns		SC
			JOIN	sysobjects		SO	ON	SO.id = SC.id
			JOIN	sysindexkeys	SI	ON	SO.id = SI.id 
										AND SC.colid = SI.colid
			WHERE SI.indid = 1)		D	ON	A.id = D.id 
										AND	B.colid = D.colid
LEFT JOIN sys.foreign_key_columns	E	ON	A.id = E.parent_object_id 
										AND	B.colid = E.parent_column_id    
INNER JOIN sys.objects				G	ON	E.referenced_object_id = G.object_id  
LEFT JOIN sys.extended_properties	H	ON	A.id = H.major_id 
										AND	B.colid = H.minor_id
--WHERE A.type = 'U'
--ORDER BY A.name
--SELECT * FROM #tmpRefTables
-- *********************************************************

DECLARE Tbls CURSOR
FOR

SELECT DISTINCT Table_name
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	Table_name NOT LIKE 'vw%'	
--AND		Table_name NOT LIKE '%bkup%'
ORDER BY Table_name

OPEN Tbls

PRINT '<html>'
PRINT '<body>'
PRINT '<head>'
PRINT '<title>Data Dictionary: ' + @DatabaseName + '</title>'
PRINT '<style>'

PRINT 'body	{background-color: #FFFFFF; font-family: Helvetica, sans-serif, Arial;}'
--PRINT 'h2		{color: #0000CC;}'
PRINT 'table	{border-collapse: collapse;}'
PRINT 'th	{text-align: left; padding: 6px; background: #BFEFFF;}'
PRINT 'td	{padding: 6px; background: #FDFCDC;}'
--PRINT 'table#t01 tr:nth-child(even)	{padding: 6px; background-color: #FDFCDC;}'
--PRINT 'table#t01 tr:nth-child(odd)	{padding: 6px; background-color: #FFFFFF;}'

PRINT '</style>'
PRINT '</head>'

--PRINT '<table border = "1"><tr><td><h2>Data Dictionary: <i>' + @DatabaseName + '</i></h2></td></tr></table>'
PRINT '<font size = "6">Data Dictionary: <i>' + @DatabaseName + '</i></font>'
PRINT '<br>'
PRINT '<br>'

PRINT '<table border = "1">'
PRINT '<tr><th><b>Database: </b></th><td>' + @DatabaseName + '</td></tr>'
PRINT '<tr><th><b>Server: </b></th><td>' + @ServerName + '</td></tr>'
PRINT '<tr><th><b>Generated on: </b></th><td>' + CAST(@TimeGenerated AS NVARCHAR(50)) + '</td></tr>'
PRINT '</table>'
PRINT '<br>'
PRINT '<br>'

FETCH NEXT FROM Tbls
INTO @TableName

WHILE @@FETCH_STATUS = 0
BEGIN


PRINT '</br>'
PRINT '</br>'
PRINT '<table border = "1" background-color: #FFFFFF>'
PRINT '<tr><th><b>Entity Name: </b></th><td>' + @TableName + '</td></tr>'
--Get the Description of the table
--Characters 1-250
PRINT '<tr><th><i><b>Entity Description: </b></th><td>'
SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),1,250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0

--Characters 251-500
SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),251, 250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0
PRINT '</i></td></tr>'
PRINT '</table>'
PRINT '<br>'

PRINT '<table id = "t01", border = "1">'
PRINT '<tr><b>'
--Set up the Column Headers for the Table
PRINT '<th><b>Column Name</b></th>'
PRINT '<th><b>Description</b></th>'
PRINT '<th><b>InPrimaryKey</b></th>'
PRINT '<th><b>IsForeignKey</b></th>'
PRINT '<th><b>DataType</b></th>'
PRINT '<th><b>Length</b></th>'
PRINT '<th><b>Numeric Precision</b></th>'
PRINT '<th><b>Numeric Scale</b></th>'
PRINT '<th><b>Nullable</b></th>'
PRINT '<th><b>Computed</b></th>'
PRINT '<th><b>Identity</b></th>'
PRINT '<th><b>Default Value</b></th>'
PRINT '<th><b>Reference Table</b></th>'

--Get the Table Data
SELECT 
	'</b></tr>',
	'<tr>',
	'<td>' + CAST(clmns.name AS VARCHAR(35)) + '</td>',
	'<td>' + SUBSTRING(ISNULL(CAST(exprop.value AS VARCHAR(255)),''),1,250),
			SUBSTRING(ISNULL(CAST(exprop.value AS VARCHAR(500)),''),251,250) + '</td>',
	'<td>' + CAST(ISNULL(idxcol.index_column_id, 0)AS VARCHAR(20)) + '</td>',
	'<td>' + CAST(ISNULL(
		(SELECT TOP 1 1
		FROM	sys.foreign_key_columns AS fkclmn
		WHERE	fkclmn.parent_column_id = clmns.column_id
		AND		fkclmn.parent_object_id = clmns.object_id
		), 0) AS VARCHAR(20)) + '</td>',
	'<td>' + CAST(udt.name AS CHAR(15)) + '</td>' ,
	'<td>' + CAST(CAST
				(CASE WHEN typ.name IN (N'nchar', N'nvarchar') AND clmns.max_length <> -1
				THEN clmns.max_length/2
				ELSE clmns.max_length 
				END 
				AS INT) AS VARCHAR(20)) + '</td>',
	'<td>' + CAST(CAST(clmns.precision AS INT) AS VARCHAR(20)) + '</td>',
	'<td>' + CAST(CAST(clmns.scale AS INT) AS VARCHAR(20)) + '</td>',
	'<td>' + CAST(clmns.is_nullable AS VARCHAR(20)) + '</td>' ,
	'<td>' + CAST(clmns.is_computed AS VARCHAR(20)) + '</td>' ,
	'<td>' + CAST(clmns.is_identity AS VARCHAR(20)) + '</td>' ,
	'<td>' + ISNULL(CAST(cnstr.definition AS VARCHAR(20)),'') + '</td>', 
	'<td>' + ISNULL(reftbl.nmRefTable + '</td>','')
FROM			sys.tables				tbl
INNER JOIN		sys.all_columns			clmns	ON	clmns.object_id = tbl.object_id
LEFT OUTER JOIN sys.indexes				idx		ON	idx.object_id = clmns.object_id
												AND	1 = idx.is_primary_key
LEFT OUTER JOIN sys.index_columns		idxcol	ON	idxcol.index_id = idx.index_id
												AND	idxcol.column_id = clmns.column_id
												AND	idxcol.object_id = clmns.object_id
												AND	0 = idxcol.is_included_column
LEFT OUTER JOIN sys.types				udt		ON	udt.user_type_id = clmns.user_type_id
LEFT OUTER JOIN sys.types				typ		ON	typ.user_type_id = clmns.system_type_id
												AND	typ.user_type_id = typ.system_type_id
LEFT JOIN		sys.default_constraints	cnstr	ON	cnstr.object_id=clmns.default_object_id
LEFT OUTER JOIN sys.extended_properties exprop	ON	exprop.major_id = clmns.object_id
												AND	exprop.minor_id = clmns.column_id
												AND	exprop.name = 'MS_Description'
LEFT JOIN #tmpRefTables					reftbl	ON	reftbl.nmTable = @TableName
												AND	reftbl.nmAttribute = clmns.name
WHERE	tbl.name	= @TableName 

--AND		exprop.class = 1 --Don't want to include comments on indexes

ORDER BY clmns.column_id ASC


PRINT '</tr>'
PRINT '</table>'
--PRINT '<br><hr>'

FETCH NEXT FROM Tbls
INTO @TableName
END


PRINT '</body>'
PRINT '</html>'

CLOSE Tbls
DEALLOCATE Tbls