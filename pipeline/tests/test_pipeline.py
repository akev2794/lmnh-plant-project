# Pylint:skip-file
"""Testing for pipeline.py"""

# Native imports
from datetime import datetime
from unittest.mock import patch, MagicMock

# Third-party imports
import pandas as pd
import pytest

# Local modules 
from pipeline import load_to_recording






### Load to recording
@patch('pipeline.pd.DataFrame.to_sql')
@pytest.mark.parametrize('data', [('recordin'), (''), ('plant'), (1)])
def test_load_invalid_df(mock_to_sql, data):
    with pytest.raises(ValueError, match="Invalid table name."):
        load_to_recording('recording', pd.DataFrame(data), 'engine')


@patch('pipeline.pd.DataFrame.to_sql')
@pytest.mark.parametrize('table', [('recording'), ('incident')])
def test_load_valid_df(mock_to_sql, table):
    VALID_DATA_A = [{"plant_id": 3, "soil_moisture": 11, "temperature": 10, "taken_at":datetime.now()}]
    VALID_DF = pd.DataFrame(VALID_DATA_A)
    assert load_to_recording(table, VALID_DF, 'engine') == None

