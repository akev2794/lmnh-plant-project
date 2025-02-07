# pylint: skip-file

import sys
import os
import pytest
from unittest.mock import AsyncMock, patch
import aiohttp


import extract 


async def fetch_data(session: aiohttp.ClientSession, url: str):
    async with session.get(url) as response:
        return await response.json()


@pytest.mark.asyncio
async def test_fetch_data_success():
    url = 'http://test.com'
    expected_response = {'key': 'value'}

    mock_response = AsyncMock()
    mock_response.__aenter__.return_value = mock_response
    mock_response.__aexit__.return_value = None
    mock_response.json = AsyncMock(return_value=expected_response)

    with patch('aiohttp.ClientSession.get', return_value=mock_response):
        async with aiohttp.ClientSession() as session:
            response = await fetch_data(session, url)
            assert response == expected_response


@pytest.mark.asyncio
async def test_fetch_all():
    mock_response = {
        "plant_id": 1,
        "name": "Venus flytrap",
        "botanist": {
            "email": "gertrude.jekyll@lnhm.co.uk",
            "name": "Gertrude Jekyll",
            "phone": "001-481-273-3691x127"
        },
        "last_watered": "Tue, 04 Feb 2025 13:54:32 GMT",
        "soil_moisture": 98.3590492057087,
        "temperature": 12.0294198997956,
        "origin_location": ["33.95015", "-118.03917", "South Whittier", "US", "America/Los_Angeles"]
    }

    with patch('aiohttp.ClientSession.get') as mock_get:
        mock_get.return_value.__aenter__.return_value.json = AsyncMock(return_value=mock_response)
        
        data = await extract.fetch_all()
        assert len(data) == 50
        assert data[0] == mock_response
