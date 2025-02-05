# Pylint:skip-file
"""Testing for pipeline.py"""

# Native imports
from datetime import datetime
from unittest.mock import patch, MagicMock

# Third-party imports
import pandas as pd
import pytest

# Local modules 
from pipeline import load_to_recording, load_to_incident


VALID_DATA = [{"plant_id": 3, "soil_moisture": 11, "temperature": 10, "taken_at":datetime.now()}]
VALID_DF = pd.DataFrame(VALID_DATA)

### Load to recording - table name
@patch('pipeline.pd.DataFrame.to_sql')
@pytest.mark.parametrize('table', [('recordin'), (''), ('plant'), (1)])
def test_load_invalid_name(mock_to_sql, table):
    with pytest.raises(ValueError, match="Invalid table name."):
        load_to_recording(table, VALID_DF, 'engine')


@patch('pipeline.pd.DataFrame.to_sql')
@pytest.mark.parametrize('table', [('recording'), ('incident')])
def test_load_valid_name(mock_to_sql, table):
        assert load_to_recording(table, VALID_DF, 'engine') == None



# Load to incident - dataframe
@patch('pipeline.pd.DataFrame.to_sql')
@pytest.mark.parametrize('df', [('recording'), ('incident')])
def test_invalid_df(mock_to_sql, table):
    with pytest.raises(ValueError, match="Invalid table name."):
        load_to_incident('recording', VALID_DF, 'engine')


@patch('pipeline.pd.DataFrame.to_sql')
@pytest.mark.parametrize('df', [('recording'), ('incident')])
def test_load_valid_name(mock_to_sql, table):
        assert load_to_recording(table, VALID_DF, 'engine') == None


