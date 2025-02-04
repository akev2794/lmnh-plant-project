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
# from transform ...



if __name__ == "__main__":
    conn = create_engine
