# Pylint:skip-file
"""Testing for pipeline.py"""

# Native imports
from datetime import datetime
from unittest.mock import patch, MagicMock

# Third-party imports
import pandas as pd
import pytest

# Local modules 
from pipeline import load

"""
What to test:
load

"""

VALID_DATA = [{"plant_id": 3, "soil_moisture": 11, "temperature": 10, "taken_at":datetime.now()}]
VALID_DF = pd.DataFrame(VALID_DATA)


@patch('pipeline.pd.DataFrame.to_sql')
def test_load_invalid_name(mock_to_sql):
    # tests for valid name
    invalid_name = 'hello'
    with pytest.raises(ValueError):
        load(invalid_name, VALID_DF, 'engine')