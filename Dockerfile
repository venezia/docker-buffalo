FROM golang:1.22.1
ADD cli /go/cli
WORKDIR /go/cli
RUN go build -o buffalo cmd/buffalo/main.go

FROM golang:1.22.1

EXPOSE 3000

RUN apt-get update \
    && apt-get install -y -q build-essential sqlite3 libsqlite3-dev postgresql libpq-dev vim

# Installing Node 12
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash 
RUN apt-get update && apt-get install nodejs

# Installing Postgres
#RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' \
#    && wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add - \
#    && apt-get update \
#    && apt-get install -y -q postgresql postgresql-contrib libpq-dev\
#    && rm -rf /var/lib/apt/lists/* \
#    && service postgresql start && \
#    # Setting up password for postgres
#    su -c "psql -c \"ALTER USER postgres  WITH PASSWORD 'postgres';\"" - postgres

# Installing yarn
RUN npm install -g --no-progress yarn \
    && yarn config set yarn-offline-mirror /npm-packages-offline-cache \
    && yarn config set yarn-offline-mirror-pruning true

# Install golangci
RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin v1.57.1

# Installing buffalo binary
COPY --from=0 /go/cli/buffalo /go/bin/buffalo

WORKDIR /
RUN go install github.com/gobuffalo/buffalo-pop/v3@latest

RUN mkdir /src
WORKDIR /src
