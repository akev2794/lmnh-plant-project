# pylint: skip-file

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
@patch('pyodbc.Connection')
def test_load_to_recording_invalid_df(mock_conn):
    data = [1]
    mock_conn = MagicMock()
    mock_conn.return_value = mock_conn 
    with pytest.raises(ValueError):
        load_to_recording(data, mock_conn)


@patch('pyodbc.Connection')
def test_load_to_recording_valid_df(mock_conn):
    mock_conn = MagicMock()
    valid_data= [(1, 2, 3 ,4, 5)]
    assert load_to_recording(valid_data, conn) == None

