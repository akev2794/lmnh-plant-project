FROM python:latest

RUN apt-get update -y \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key adv --fetch-keys https://packages.microsoft.com/keys/microsoft.asc \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update -y \
    && apt-get remove -y unixodbc-dev \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools18 \
    && apt-get install -y unixodbc-dev \
    && apt-get install -y g++ \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/profile.d/mssql-tools.sh \
    && apt-get clean

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip3 install -r requirements.txt

COPY dashboard.py .

CMD [ "streamlit", "run", "dashboard.py"]