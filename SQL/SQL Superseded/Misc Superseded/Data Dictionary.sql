USE [EdenMDS-TST]

SELECT 
A.name			[Table]
, B.name		[Attribute]
, C.name		[DataType]
, B.isnullable	[Allow Nulls?]
, CASE WHEN
	D.name IS NULL 
		THEN 0 
		ELSE 1
	END			[PKey?]
, CASE WHEN 
	E.parent_object_id IS NULL 
		THEN 0 
		ELSE 1
	END			[FKey?]
, CASE WHEN 
	E.parent_object_id IS NULL
		THEN '-' 
		ELSE G.name 
	END			[Ref Table]
, CASE WHEN 
	h.value IS NULL
		THEN '-'
		ELSE h.value 
	END			[Description]
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
LEFT JOIN sys.objects				G	ON	E.referenced_object_id = G.object_id  
LEFT JOIN sys.extended_properties	H	ON	A.id = H.major_id 
										AND	B.colid = H.minor_id
WHERE A.type = 'U'
ORDER BY A.name