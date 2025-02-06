# Dashboard

This folder has all the necessary files for the dashboard.

### Requirements

- Streamlit must be installed.
- install all dependencies from `requirements.txt`.

### Libraries needed

- `Streamlit` - for the visualisations to be created
- `pyodbc` - which is needed for the connection for the database
- `pandas` - needed for handling SQL query results that can be processed and managed
- `plotly` - a graphing library that is needed for the high-quality visualisations

### dashboard.py

A python file for creating the streamlit dashboard.

### tests

A folder containing tests for dashboard.py.

### .env

You must have a .env file with the following:

- DB_HOST
- DB_PORT
- DB_NAME
- DB_USER
- DB_PASSWORD
