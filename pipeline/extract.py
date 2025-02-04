"""
This script is for extracting the LMNH raw data from the LMNH api.
It will request the data from the api, and return a pandas dataframe.
"""

# Native imports
import asyncio

# Third-party imports
import pandas as pd
from aiohttp import ClientSession


async def fetch(session: ClientSession, url: str):
    """Fetches data from one endpoint."""
    async with session.get(url) as response:
        return await response.json()


async def fetch_all():
    """Fetches data from all the endpoints."""
    async with ClientSession() as session:
        results = await asyncio.gather(*[fetch(session,
            f'https://data-eng-plants-api.herokuapp.com/plants/{i}') for i in range(1,51)],
            return_exceptions=True)
        return results


def create_dataframe() -> pd.DataFrame:
    """Main script function. Pulls the data from the API and loads it into a DataFrame."""
    data = asyncio.run(fetch_all())
    return pd.DataFrame(data)


if __name__ == "__main__":
    raw_extract_dataframe = create_dataframe()
