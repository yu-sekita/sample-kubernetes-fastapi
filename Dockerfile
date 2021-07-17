
FROM python:3.8 AS build

ARG WORKDIR=/server

COPY app/Pipfile app/Pipfile.lock $WORKDIR/
WORKDIR $WORKDIR
RUN pip install pipenv && pipenv install --system


FROM python:3.8 AS prod

ARG WORKDIR=/server
ARG USER=docker
ARG GROUPNAME=docker

COPY --from=build /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=build /usr/local/bin /usr/local/bin

RUN groupadd -r $GROUPNAME \
    && useradd -r -s /bin/bash -g $GROUPNAME $USER

USER $USER
COPY --chown=$USER:$WORKDIR app $WORKDIR/
WORKDIR $WORKDIR
CMD ["uvicorn", "main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
