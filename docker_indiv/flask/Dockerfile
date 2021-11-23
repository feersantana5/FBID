FROM python:3.6
RUN apt-get update -y
COPY files/requirements.txt .
COPY files/web /web
RUN python3 -m pip install -r requirements.txt
WORKDIR /web
CMD python predict_flask.py
EXPOSE 5000