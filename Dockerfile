FROM python:3.8-slim-buster
RUN groupadd -r eitan -g 1001 && \
    useradd -u 1001 -r -g eitan -s /sbin/nologin -c "Docker image user" eitan
EXPOSE 9996
RUN pip install requests flask
USER eitan
COPY echo_server.py echo_server.py
COPY index.html index.html
CMD python3 echo_server.py



