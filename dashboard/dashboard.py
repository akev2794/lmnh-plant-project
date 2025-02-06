"""
This script is for the creation of a streamlit dashboard.
It queries an AWS relational database to obtain the relevant LMNH plant data,
then creates a dashboard based on the wireframe provided in the folder. 
"""
from os import environ as ENV
import pyodbc
import pandas as pd
import streamlit as st
import plotly.express as px
from dotenv import load_dotenv
from datetime import datetime, timedelta

load_dotenv()

def get_db_connection():
    conn = pyodbc.connect(f"""
        DRIVER={{ODBC Driver 18 for SQL Server}};
        SERVER={ENV["DB_HOST"]},{ENV["DB_PORT"]};
        DATABASE={ENV["DB_NAME"]};
        UID={ENV["DB_USER"]};
        PWD={ENV["DB_PASSWORD"]};
        TrustServerCertificate=yes;
    """)
    return conn

def get_plant_details(plant_id):
    """Fetches the plant details (name, region, botanist) for a given plant_id."""
    connection = get_db_connection()
    query = """
    SELECT
        p.plant_name,
        p.plant_scientific_name,
        r.region_name,
        c.country_name,
        b.first_name AS botanist_first_name,
        b.last_name AS botanist_last_name
    FROM
        beta.plant p
        JOIN beta.region r ON p.region_id = r.region_id
        JOIN beta.country c ON r.country_id = c.country_id
        LEFT JOIN beta.botanist b ON p.botanist_id = b.botanist_id
    WHERE
        p.plant_id = ?
    """
    df = pd.read_sql(query, connection, params=(plant_id,))
    connection.close()
    return df

def get_plant_data(plant_id, time_range):
    """Fetches temperature and soil moisture for a given plant and time range."""
    connection = get_db_connection()

    query_recent = """
    SELECT MAX(taken_at) AS most_recent_time
    FROM beta.recording
    WHERE plant_id = ?
    """
    recent_df = pd.read_sql(query_recent, connection, params=(plant_id,))
    most_recent_time = recent_df['most_recent_time'].iloc[0]
    if most_recent_time is None:
        connection.close()
        return pd.DataFrame()

    if time_range == "Last Hour":
        start_time = most_recent_time - timedelta(hours=1)
    elif time_range == "Last 24 Hours":
        start_time = most_recent_time - timedelta(days=1)
    elif time_range == "Last Week":
        start_time = most_recent_time - timedelta(weeks=1)
    elif time_range == "Last 30 Days":
        start_time = most_recent_time - timedelta(days=30)

    query = """
    SELECT
        r.taken_at,
        r.temperature,
        r.soil_moisture
    FROM
        beta.recording r
    WHERE
        r.plant_id = ?
    AND r.taken_at >= ?
    ORDER BY r.taken_at DESC
    """
    df = pd.read_sql(query, connection, params=(plant_id, start_time))
    connection.close()

    df['taken_at'] = pd.to_datetime(df['taken_at'])

    df = df.set_index('taken_at').rolling('3T').mean().reset_index()
    return df

def get_emergencies_within_period(plant_id, time_range):
    """Fetches the number of emergencies for a given plant within a specified time range."""
    connection = get_db_connection()

    query_recent = """
    SELECT MAX(incident_at) AS most_recent_incident_time
    FROM beta.incident
    WHERE plant_id = ?
    """
    recent_df = pd.read_sql(query_recent, connection, params=(plant_id,))
    most_recent_incident_time = recent_df['most_recent_incident_time'].iloc[0]
    if most_recent_incident_time is None:
        connection.close()
        return 0

    if time_range == "Last Hour":
        start_time = most_recent_incident_time - timedelta(hours=1)
    elif time_range == "Last 24 Hours":
        start_time = most_recent_incident_time - timedelta(days=1)
    elif time_range == "Last Week":
        start_time = most_recent_incident_time - timedelta(weeks=1)
    elif time_range == "Last 30 Days":
        start_time = most_recent_incident_time - timedelta(days=30)

    query = """
    SELECT COUNT(*) as emergency_count
    FROM beta.incident
    WHERE plant_id = ?
    AND incident_at >= ?  -- Filter by start time
    """
    cursor = connection.cursor()
    cursor.execute(query, (plant_id, start_time))
    result = cursor.fetchone()
    connection.close()
    return result[0]

def display_plant_data():
    plant_id = st.selectbox("Select Plant ID", list(range(1, 51)))

    time_range = st.selectbox(
        "Select Time Period",
        ["Last Hour", "Last 24 Hours", "Last Week", "Last 30 Days"]
    )

    plant_details = get_plant_details(plant_id)
    if not plant_details.empty:
        plant_name = plant_details.iloc[0]['plant_name']
        plant_scientific_name = plant_details.iloc[0]['plant_scientific_name']
        region_name = plant_details.iloc[0]['region_name']
        country_name = plant_details.iloc[0]['country_name']
        botanist_first_name = plant_details.iloc[0]['botanist_first_name']
        botanist_last_name = plant_details.iloc[0]['botanist_last_name']
        st.write(f"**Plant Name**: {plant_name} ({plant_scientific_name})")
        st.write(f"**Region**: {region_name}, **Country**: {country_name}")
        st.write(f"**Botanist**: {botanist_first_name} {botanist_last_name}")
    
    plant_data = get_plant_data(plant_id, time_range)

    emergency_count = get_emergencies_within_period(plant_id, time_range)
    st.write(f"Emergencies in the {time_range.lower()} for plant id {plant_id}: {emergency_count}")

    st.subheader(f"Temperature over Time ({time_range})")
    if not plant_data.empty:
        temp_fig = px.line(plant_data, x='taken_at', y='temperature', title="Temperature Over Time")
        temp_fig.update_xaxes(type='date')
        st.plotly_chart(temp_fig)
    else:
        st.write("No data available for the selected time period.")

    st.subheader(f"Soil Moisture over Time ({time_range})")
    if not plant_data.empty:
        moisture_fig = px.line(plant_data, x='taken_at', y='soil_moisture', title="Soil Moisture Over Time")
        moisture_fig.update_xaxes(type='date')
        st.plotly_chart(moisture_fig)
    else:
        st.write("No data available for the selected time period.")

st.set_page_config(page_title="Plant Data Dashboard", layout="wide")
st.title("Real-Time Plant Data Dashboard")

display_plant_data()