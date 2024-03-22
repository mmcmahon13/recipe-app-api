FROM python:3.9-alpine
LABEL maintainer='mmcmahon13'

# do not buffer output from within docker container, see logs immediately
ENV PYTHONUNBUFFERED 1

# Copy code from our local machine to specified directories in image
# expose port 8000 from the container so we can connect to dev server
COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# install pip requirements into virutalenv in /py , create a user
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

# best practice is not to use the root user to run your app, lest attackers get full access
USER django-user