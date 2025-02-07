# pylint: skip-file

"""Testing for pipeline.py"""

# Native imports
from unittest.mock import patch
from os import environ as ENV

# Third-party imports
import pytest
import pyodbc

# Local modules 
from pipeline import create_env_connection

@patch.dict(ENV, {
    'DB_HOST': 'localhost',
    'DB_PORT': '1433',
    'DB_NAME': 'test_db',
    'DB_USER': 'user',
    'DB_PASSWORD': 'password'
})
@patch('pyodbc.connect')
def test_create_env_connection_invalid(mock_connect):
    mock_connect.side_effect = pyodbc.Error("Error connecting to database:")
    with pytest.raises(pyodbc.Error, match="Error connecting to database:"):
        create_env_connection()

