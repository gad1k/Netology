FROM continuumio/miniconda3:latest

RUN apt-get update &&  \
    apt-get upgrade -y && \
    apt-get install -y python python-pip && \
    pip install mlflow boto3 pymysql

WORKDIR /app
ADD "1.sh" .

RUN chmod ugo+x "1.sh"

CMD ["bash", "1.sh"]