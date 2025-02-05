# Pipeline

This folder has all the necessary files for the pipeline. The scripts perform the ETL process for the plant data.

### Requirements

- SQL Server
- Microsoft ODBC 18 (see [docs](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver16))
- Install all dependencies from `requirements.txt`.

### extract.py

A python file for creating the extracting the plant data from the api and loading it into a pandas dataframe.

### transform.py

A python file for transforming the plant data to a clean state ready to be uploaded to the database.

### pipeline.py

A python file for the ETL process, using the extract and transform modules.

### tests

A folder containing tests for extract.py, transform.py and pipeline.py

### .env

You must have a .env file with the following:

- DB_HOST
- DB_PORT
- DB_NAME
- DB_USER
- DB_PASSWORD
