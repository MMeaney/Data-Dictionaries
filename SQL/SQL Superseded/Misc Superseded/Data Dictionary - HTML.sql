USE [EdenMDS-TST]

SET NOCOUNT ON

DECLARE @TableName		NVARCHAR(35)
DECLARE @ServerName		NVARCHAR(50)
DECLARE @DatabaseName	NVARCHAR(50)
DECLARE @TimeGenerated	DATETIME

SET	@ServerName			= CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(50))
SET	@DatabaseName		= CAST(DB_NAME() AS NVARCHAR(50))
SET	@TimeGenerated		= GETDATE()

DECLARE Tbls CURSOR
FOR

SELECT DISTINCT Table_name
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	Table_name NOT LIKE '%bkup%'
ORDER BY Table_name

OPEN Tbls

PRINT '<html>'
PRINT '<body>'
PRINT '<head>'
PRINT '<style>'

PRINT 'body	{background-color: #FFFFFF;}'
PRINT 'h2		{color: #0000CC;}'
PRINT 'table	{border-collapse: collapse;}'
PRINT 'td.bluestyle	{padding: 6px; background: #BFEFFF;}'
PRINT 'td		{padding: 6px; background: #FDFCDC;}'

PRINT '</style>'
PRINT '</head>'

PRINT '<h2>Data Dictionary</h2>'

PRINT '<table border = "1">'
PRINT '<tr><td class = "bluestyle"><b>Database: </b></td><td>' + @DatabaseName + '</td></tr>'
PRINT '<tr><td class = "bluestyle"><b>Server: </b></td><td>' + @ServerName + '</td></tr>'
PRINT '<tr><td class = "bluestyle"><b>Generated on: </b></td><td>' + CAST(@TimeGenerated AS NVARCHAR(50)) + '</td></tr>'
PRINT '</table>'

FETCH NEXT FROM Tbls
INTO @TableName

WHILE @@FETCH_STATUS = 0
BEGIN


PRINT '</br>'
PRINT '</br>'
PRINT '<table border = "1">'
PRINT '<b>Entity Name: </b>' + @TableName + '</br>'


--Get the Description of the table
--Characters 1-250
PRINT '<i><b>Entity Description: </b>'
SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),1,250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0

--Characters 251-500
SELECT	SUBSTRING(ISNULL(CAST(Value AS VARCHAR(1000)),''),251, 250) 
FROM	sys.extended_properties A
WHERE	A.major_id = OBJECT_ID(@TableName)
AND		name = 'MS_Description' and minor_id = 0
PRINT '</i>'

PRINT '<tr><b>'
--Set up the Column Headers for the Table
PRINT '<td class = "bluestyle"><b>Column Name</b></td>'
PRINT '<td class = "bluestyle"><b>Description</b></td>'
PRINT '<td class = "bluestyle"><b>InPrimaryKey</b></td>'
PRINT '<td class = "bluestyle"><b>IsForeignKey</b></td>'
PRINT '<td class = "bluestyle"><b>DataType</b></td>'
PRINT '<td class = "bluestyle"><b>Length</b></td>'
PRINT '<td class = "bluestyle"><b>Numeric Precision</b></td>'
PRINT '<td class = "bluestyle"><b>Numeric Scale</b></td>'
PRINT '<td class = "bluestyle"><b>Nullable</b></td>'
PRINT '<td class = "bluestyle"><b>Computed</b></td>'
PRINT '<td class = "bluestyle"><b>Identity</b></td>'
PRINT '<td class = "bluestyle"><b>Default Value</b></td>'

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
	'<td>' + ISNULL(CAST(cnstr.definition AS VARCHAR(20)),'') + '</td>'
FROM sys.tables							tbl
INNER JOIN sys.all_columns				clmns	ON clmns.object_id = tbl.object_id
LEFT OUTER JOIN sys.indexes				idx		ON idx.object_id = clmns.object_id
												AND 1 = idx.is_primary_key
LEFT OUTER JOIN sys.index_columns		idxcol	ON idxcol.index_id = idx.index_id
												AND idxcol.column_id = clmns.column_id
												AND idxcol.object_id = clmns.object_id
												AND 0 = idxcol.is_included_column
LEFT OUTER JOIN sys.types				udt		ON udt.user_type_id = clmns.user_type_id
LEFT OUTER JOIN sys.types				typ		ON typ.user_type_id = clmns.system_type_id
												AND typ.user_type_id = typ.system_type_id
LEFT JOIN sys.default_constraints		cnstr	ON cnstr.object_id=clmns.default_object_id
LEFT OUTER JOIN sys.extended_properties exprop	ON exprop.major_id = clmns.object_id
												AND exprop.minor_id = clmns.column_id
												AND exprop.name = 'MS_Description'
WHERE	(tbl.name = @TableName 
--AND		exprop.class = 1) --Don't want to include comments on indexes
)
ORDER BY clmns.column_id ASC


PRINT '</tr>'
PRINT '</table>'

FETCH NEXT FROM Tbls
INTO @TableName
END


PRINT '</body>'
PRINT '</html>'

CLOSE Tbls
DEALLOCATE Tbls