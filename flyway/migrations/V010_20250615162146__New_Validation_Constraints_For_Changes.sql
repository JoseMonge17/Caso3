DECLARE @sql NVARCHAR(MAX) = N'';

-- Cursor to find FK constraints on specific tables/columns you want to rename
DECLARE fk_cursor CURSOR FOR
SELECT 
    fk.name AS ConstraintName,
    t.name AS TableName,
    c.name AS ColumnName,
    rt.name AS ReferencedTableName,
    rc.name AS ReferencedColumnName
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables t ON fkc.parent_object_id = t.object_id
INNER JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
INNER JOIN sys.tables rt ON fkc.referenced_object_id = rt.object_id
INNER JOIN sys.columns rc ON fkc.referenced_object_id = rc.object_id AND fkc.referenced_column_id = rc.column_id
WHERE t.name IN (
    'vpv_validation_audit',
    'vpv_validation_process_log',
    'vpv_validation_process_steps_log',
    'vpv_validation_request',
	'vpv_identity_validations'
)
AND c.name IN (
    'processid',
    'requestid',
    'result',
    'userid',
    'validation_typeid',
	'apiid',
	'process_stepid'
);

OPEN fk_cursor;
DECLARE 
    @ConstraintName SYSNAME,
    @TableName SYSNAME,
    @ColumnName SYSNAME,
    @ReferencedTableName SYSNAME,
    @ReferencedColumnName SYSNAME,
    @NewConstraintName SYSNAME,
    @DropSQL NVARCHAR(MAX),
    @AddSQL NVARCHAR(MAX);

FETCH NEXT FROM fk_cursor INTO @ConstraintName, @TableName, @ColumnName, @ReferencedTableName, @ReferencedColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Compose the new explicit constraint name
    SET @NewConstraintName = 'FK_' + @TableName + '_' + @ColumnName;

    -- Drop existing constraint
    SET @DropSQL = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' + QUOTENAME(@ConstraintName) + ';';

    -- Add new constraint with explicit name
    SET @AddSQL = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' ADD CONSTRAINT ' + QUOTENAME(@NewConstraintName) 
        + ' FOREIGN KEY (' + QUOTENAME(@ColumnName) + ') REFERENCES ' + QUOTENAME(@ReferencedTableName) 
        + '(' + QUOTENAME(@ReferencedColumnName) + ');';

    -- Append to batch
    SET @sql += @DropSQL + CHAR(13) + @AddSQL + CHAR(13) + CHAR(13);

    FETCH NEXT FROM fk_cursor INTO @ConstraintName, @TableName, @ColumnName, @ReferencedTableName, @ReferencedColumnName;
END

CLOSE fk_cursor;
DEALLOCATE fk_cursor;
EXEC sp_executesql @sql;

-- Por si quieren verificar
SELECT 
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    c.name AS ColumnName,
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    rc.name AS ReferencedColumn
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc 
    ON fk.object_id = fkc.constraint_object_id
JOIN sys.columns AS c 
    ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
JOIN sys.columns AS rc
    ON fkc.referenced_object_id = rc.object_id AND fkc.referenced_column_id = rc.column_id
WHERE OBJECT_NAME(fk.parent_object_id) IN (
    'vpv_validation_process_log',
    'vpv_validation_request',
    'vpv_validation_process_steps_log',
    'vpv_validation_audit',
	'vpv_identity_validations'
)
ORDER BY TableName, ColumnName;
