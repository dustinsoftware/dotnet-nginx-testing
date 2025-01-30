#!/bin/bash

/opt/mssql-tools18/bin/sqlcmd -b -C -S sqlserver -U sa -P YourStrongPassw0rd -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'MyDatabase') BEGIN PRINT 'Database does not exist.' END ELSE BEGIN PRINT 'no migration needed' END" | grep -q "Database does not exist."

if [ $? -eq 0 ]; then
    /opt/mssql-tools18/bin/sqlcmd -b -C -S sqlserver -U sa -P YourStrongPassw0rd -d master -i /docker-entrypoint-initdb.d/000-initialschema.sql
else
    echo "no migration needed"
fi
