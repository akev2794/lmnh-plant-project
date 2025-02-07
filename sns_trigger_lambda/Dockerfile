FROM public.ecr.aws/lambda/python:latest

WORKDIR %{LAMBDA_TASK_ROOT}

COPY requirements.txt .

RUN pip install -r requirements.txt

RUN apt-get update -y \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update -y \
    && apt-get remove -y unixodbc-dev \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools18 \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
    && source ~/.bashrc \
    && apt-get install -y unixodbc-dev \
    && apt-get install -y g++ \
    && apt-get clean

COPY main.python

CMD [ "main.lambda_handler" ]

