FROM registry.access.redhat.com/ubi8/python-39:1-48 as build

USER 0

RUN yum install -y postgresql-devel gcc && yum -y clean all

USER 1001

RUN pip install virtualenv && virtualenv venv
ENV PATH="/opt/app-root/src/venv/bin:$PATH"
WORKDIR /opt/app-root/src/venv

COPY app.py setup.py requirements.txt .
COPY src ./src
RUN pip install -r requirements.txt .

FROM registry.access.redhat.com/ubi8/ubi-minimal as base

USER 0

RUN microdnf install -y python39 libpq

USER 1001

COPY --chown=1001:0 --from=build /opt/app-root/src/venv /opt/venv/

WORKDIR /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

CMD python /opt/venv/app.py

FROM base as test

ADD tests/test_* tests/floorplan_* tests/requirements.txt ./tests/

RUN python -m pip install -r tests/requirements.txt
#RUN python -m pip install --no-cache-dir -r tests/requirements.txt
