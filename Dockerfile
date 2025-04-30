FROM python:latest
COPY ./RAG/requirements.txt ./requirements.txt
RUN pip install -r requirements.txt
COPY ./RAG/ .
CMD ["python", "app.py"]