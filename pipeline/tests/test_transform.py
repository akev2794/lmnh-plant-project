# pylint: skip-file

"""Testing for transform.py"""

# Native imports
from datetime import datetime

# Third-party imports
import pytest
import pandas as pd
from pandas.api.types import is_dtype_equal


# Local modules
from transform import last_watered_safe_parse_datetime, process_plant_data

# last_watered_safe_parse_datetime

@pytest.mark.parametrize('date_string', [
            (''), (1), ([""]),
            ("Wed, 50 Feb 2025 13:54:32 GMT"),
            ("Wed, 05 Feb 3000 13:54:32 GMT")
            ])
def test_last_watered_safe_parse_datetime_invalid(date_string):
    assert last_watered_safe_parse_datetime(date_string) is pd.NA


def test_last_watered_safe_parse_datetime_valid():
    date_string = "Wed, 05 Feb 2025 13:54:32 GMT"
    assert last_watered_safe_parse_datetime(date_string) == datetime.strptime(date_string, "%a, %d %b %Y %H:%M:%S GMT")




# PROCESS_PLANT_DATA
def test_process_plant_data_missing_columns():
    df_missing_cols = pd.DataFrame([{
        "plant_id": "3",
        "soil_moisture": "1"
    }])
    assert process_plant_data(df_missing_cols) == KeyError


def test_process_plant_data_valid():
    pass


DF_INPUT_1 = pd.DataFrame([{
        "plant_id": "3",
        "soil_moisture": "1",
        "temperature": "12.000",
        "taken_at": "2025-02-05 16:57:59",
        "last_watered": "Wed, 05 Feb 2000 13:54:32 GMT"
    }])
DF_INPUT_2 = pd.DataFrame([{
        "plant_id": 1,
        "soil_moisture": "1.00",
        "temperature": "12.000",
        "taken_at": "2025-02-05 16:57:59",
        "last_watered": "Wed, 05 Feb 2000 13:54:32 GMT"
    }])

@pytest.mark.parametrize('DF_INPUT',  [(DF_INPUT_1), (DF_INPUT_2)])
def test_process_plant_datatypes(DF_INPUT):

    df = process_plant_data(DF_INPUT)

    assert is_dtype_equal(df["plant_id"].dtype, "int64")
    assert is_dtype_equal(df["soil_moisture"].dtype, "float64")
    assert is_dtype_equal(df["temperature"].dtype, "float64")
    assert is_dtype_equal(df["taken_at"].dtype, "datetime64[s]")
    assert is_dtype_equal(df["last_watered"].dtype, "datetime64[s]")
