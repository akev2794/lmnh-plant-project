# pylint: skip-file

"""Testing for pipeline.py"""

# Native imports
from unittest.mock import patch

# Third-party imports
import pytest
import pyodbc

# Local modules 
from pipeline import create_env_connection


@patch('pyodbc.connect')
def test_create_env_connection_invalid( mock_connect):
    mock_connect.side_effect = pyodbc.Error("Error connecting to database:")
    with pytest.raises(pyodbc.Error, match="Error connecting to database:"):
        create_env_connection()

