FROM python:3.9-alpine
LABEL maintainer='mmcmahon13'

# do not buffer output from within docker container, see logs immediately
ENV PYTHONUNBUFFERED 1

# Copy code from our local machine to specified directories in image
# expose port 8000 from the container so we can connect to dev server
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# sets default build arg DEV to false, we override this inside docker-compose for our dev image
ARG DEV=false
# install pip requirements into virutalenv in /py , create a user
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # add conditional dev package installation to shell script
    if [ $DEV = "true" ]; \
      then /py/bin/pip install -r /tmp/requirements.dev.txt ;  \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

# best practice is not to use the root user to run your app, lest attackers get full access
USER django-user