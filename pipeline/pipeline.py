"""
This script is for the ETL process for the LMNH plant data.
The file swill pull data for the API, clean it
and upload it to the AWS relational database.
"""

# Native imports
from os import environ as ENV

# Third-party imports
import pandas as pd
from sqlalchemy import create_engine

# Local imports
from extract import create_dataframe
# from transform import ...


def load(df: pd.DataFrame):
    engine = create_engine('mssql+pyodbc://user:password@server/database')
    df.to_sql('Transaction', engine, if_exists='append', index=False)


if __name__ == "__main__":
    # Extract
    plants_df = create_dataframe()

    # Transform - EXAMPLE
    # plants_df = transform(plants_df)

    # Load
    load(plants_df)
