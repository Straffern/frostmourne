########################################
# 1. Build nodejs frontend
########################################
ARG ENV=dev

FROM node:14.15.4-alpine as base_node
# prepare build directory
ONBUILD RUN mkdir -p/app/assets
ONBUILD WORKDIR /app
# install npm dependencies
ONBUILD COPY assets/package.json assets/package-lock.json ./assets/
ONBUILD COPY deps/phoenix deps/phoenix
ONBUILD COPY deps/phoenix_html deps/phoenix_html
ONBUILD RUN cd assets && npm install


FROM base_node AS node_prod
# set build ENV
ONBUILD ENV NODE_ENV=production
# build assets
ONBUILD COPY assets ./assets/
ONBUILD RUN cd assets && npm run deploy


FROM base_node AS node_dev
# set build ENV
ONBUILD ENV NODE_ENV=development
# build assets
ONBUILD COPY assets ./assets/
ONBUILD RUN cd assets && node node_modules/webpack/bin/webpack.js --mode development


FROM node_${ENV} AS build-node

########################################
# 2. Build elixir backend
########################################
FROM elixir:latest-alpine AS base-elixir
ONBUILD ARG ENV
# install build dependencies
ONBUILD RUN apk add --update git

# prepare build dir
ONBUILD RUN mkdir /app
ONBUILD WORKDIR /app

# install hex + rebar
ONBUILD RUN mix local.hex --force && \
            mix local.rebar --force

# set build ENV
ONBUILD ENV MIX_ENV=${ENV}

# install dependencies
ONBUILD COPY mix.exs mix.lock ./
ONBUILD RUN mix deps.get

# compile dependencies
ONBUILD COPY config ./config/
ONBUILD RUN mix deps.compile

# copy only elixir files to keep the cache
ONBUILD COPY lib ./lib/
ONBUILD COPY priv ./priv/
ONBUILD COPY rel ./rel/

# copy assets from node build
ONBUILD COPY --from=build-node /app/priv/static ./priv/static

FROM base-elixir AS digest_release-elixir
RUN mix phx.digest
# build release
RUN mix release --no-tar --verbose


FROM base-elixir AS elixir-dev



########################################
# 3. Build release image
########################################
FROM alpine:latest
RUN apk add --update bash openssl

RUN mkdir /app && chown -R nobody: /app
WORKDIR /app
USER nobody

COPY --from=digest_release-elixir /app/_build/prod/rel/myapp ./

ARG VERSION
ENV VERSION=$VERSION
ENV REPLACE_OS_VARS=true
EXPOSE 4000

ENTRYPOINT ["/app/bin/myapp"]
CMD ["foreground"]