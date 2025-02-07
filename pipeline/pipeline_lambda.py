"""Lambda for ETL pipeline."""

from dotenv import load_dotenv
from pipeline import create_env_connection, run_pipeline

def handler(event, context) -> None: # pylint: disable=unused-argument
    """Handler for ETL pipeline lambda."""
    load_dotenv()
    with create_env_connection() as conn:
        run_pipeline(conn)
