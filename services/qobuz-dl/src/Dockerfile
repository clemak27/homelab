FROM python:3.10.8

ARG QOBUZ_EMAIL
ARG QOBUZ_PASSWORD

ARG UID=1001
ARG GID=1001
RUN groupadd -g $GID qobuz && \
    useradd -l -m -u $UID -g qobuz qobuz

RUN mkdir -p /app
COPY ./pyproject.toml /app
COPY ./poetry.lock /app
RUN chown -R qobuz:qobuz /app
USER qobuz
WORKDIR /app

RUN pip install --no-cache-dir poetry==1.2.1

ENV QOBUZ_EMAIL "$QOBUZ_EMAIL"
ENV QOBUZ_PASSWORD "$QOBUZ_PASSWORD"
EXPOSE 8526

ENV PATH /home/qobuz/.local/bin/:$PATH
COPY ./server.py /app
RUN poetry install
CMD ["poetry", "run", "uvicorn", "server:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "8526"]
