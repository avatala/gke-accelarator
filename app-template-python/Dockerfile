FROM python:3-alpine
WORKDIR /app
COPY /app/requirements.txt .
RUN pip install -r requirements.txt
COPY /app ./
EXPOSE 3000
ENTRYPOINT ["python3", "app.py"]