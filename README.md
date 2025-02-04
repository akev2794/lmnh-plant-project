# Liverpool Museum of Natural History Botanical Gardens Group Project

## Description

This project is for the Liverpool Museum of Natural History. They currently monitor their plants via a simple API but would like a better way of monitoring the plant health in real-time. The stakeholders would like a real-time interactive dashboard to view: both the plants current health in real-time, as well as viewing the long term data of their pants and employees. The stakeholders want a cost-effective cloud-based system.

## Contents ##### UPDATE LINKS
- [System Architecture](#system-architecture)
- [Requirements](#requirements)
- [Repository Structure](#repository-structure)
    - [dashboard](#dashboard)
    - [database](#database)
    - [pipeline](#pipeline)
    - [report](#report)
    - [terraform](#terraform)


### System Architecture 
An image of the system architecture is available #########[here](system_architecture.png)###########. All cloud resources are AWS.

The trucks data is uploaded to an S3 bucket. Where it is then extracted, transformed and loaded into an AWS SQL Server RDS, this is triggered using an EventBridge schedule. An interactive streamlit dashboard is run as an ECS service using Fargate to visualise the data. A daily report is generated using a Lambda function and sent to the stakeholders using SES, also scheduled using EventBridge.

The plant data is sent out in real time to an api. It is then extracted, transformed and loaded into an AWS SQL Server RDS. The ETL script is run constantly on an AWS EC2. Everyday at midnight a summary of the days data is uploaded to a parquet file in an s3 bucket. ###

## Requirements

To use this repository you must have:
- An AWS account with the following resources shown in the systems architecture diagram
- Python
- Streamlit

## Repository Structure

Each folder contains a README explaining more in depth how the files work.

### Usage

Each file must be run in their respective directory.\
Similarly when making AWS resources using terraform you must be in the terraform folder.\
See each folder for requirements.txt and READMEs.

#### Enviroment Variables

Each folder must contain a .env file (or .tfvars for terraform), the folder breakdown below will provide the relevant details for each file.

The contents of each folder is broken down below, in order of appearance:

Repository structure:

.
├── LICENSE
├── README.md
├── dashboard
│   ├── README.md
│   ├── dashboard.py
│   ├── requirements.txt
│   └── tests
│       └── test_dashboard.py
├── database
│   ├── ERD.png
│   ├── README.md
│   └── requirements.txt
├── pipeline
│   ├── README.md
│   ├── extract.py
│   ├── pipeline.py
│   ├── requirements.txt
│   ├── tests
│   │   ├── test_extract.py
│   │   ├── test_pipeline.py
│   │   └── test_transform.py
│   └── transform.py
├── requirements.txt
├── terraform
│   ├── README.md
│   └── requirements.txt
└── test_code.py
