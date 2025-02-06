source .env
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.eu-west-2.amazonaws.com
docker build -t c15-incitatus-etl-pipeline-ecr:latest --platform "linux/amd64" --provenance=false .
docker tag c15-incitatus-etl-pipeline-ecr:latest $ACCOUNT_NUMBER.dkr.ecr.eu-west-2.amazonaws.com/c15-incitatus-etl-pipeline-ecr:latest
docker push $ACCOUNT_NUMBER.dkr.ecr.eu-west-2.amazonaws.com/c15-incitatus-etl-pipeline-ecr:latest