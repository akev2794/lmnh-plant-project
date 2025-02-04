"""
This script is for extracting the LMNH raw data from the LMNH api.
It will request the data from the api, and return a pandas dataframe.
"""

import asyncio
from aiohttp import ClientSession
import pandas as pd


async def fetch(session: ClientSession, url):
    async with session.get(url) as response:
        return await response.json()


async def fetch_all():
    async with ClientSession() as session:
        results = await asyncio.gather(*[fetch(session, f'https://data-eng-plants-api.herokuapp.com/plants/{i}') for i in range(1,51)], return_exceptions=True)
        return results


def create_dataframe(data: list[dict]) -> pd.DataFrame:
    pass


if __name__ == "__main__":
    print(asyncio.run(fetch_all()))
    
