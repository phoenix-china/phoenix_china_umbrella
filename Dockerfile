FROM elixir:1.4.2

####### Node #######
RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 7.7.4

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

CMD [ "node" ]

RUN npm install -g yarn
####### Node #######

# Initialize
RUN mkdir /phoenix_china_umbrella
WORKDIR /phoenix_china_umbrella
ENV MIX_ENV=prod

# Things don't change that often. For instance, dependencies
# Install Elixir Deps
ADD mix.* ./
RUN mkdir -p ./apps/phoenix_china
RUN mkdir -p ./apps/phoenix_china_web
ADD ./apps/phoenix_china/mix.* ./apps/phoenix_china
ADD ./apps/phoenix_china_web/mix.* ./apps/phoenix_china_web
RUN MIX_ENV=prod mix local.rebar
RUN MIX_ENV=prod mix local.hex --force
RUN MIX_ENV=prod mix deps.get

# Install Node Deps
RUN mkdir -p ./apps/phoenix_china_web/assets
ADD ./apps/phoenix_china_web/assets/package.json ./apps/phoenix_china_web/assets
WORKDIR ./apps/phoenix_china_web/assets
RUN yarn install


WORKDIR /phoenix_china_umbrella
ADD . .
# Compile Node App
WORKDIR ./apps/phoenix_china_web/assets
RUN yarn run deploy

WORKDIR /phoenix_china_umbrella

# Create prod.secret.exs
RUN echo "use Mix.Config" > ./apps/phoenix_china_web/config/prod.secret.exs
RUN echo "use Mix.Config;\
  config :phoenix_china, PhoenixChina.Repo,\
  adapter: Ecto.Adapters.Postgres,\
  username: \"postgres\",\
  password: \"postgres\",\
  database: \"phoenix_china_prod\",\
  hostname: \"postgres\",\
  pool_size: 50" > ./apps/phoenix_china/config/prod.secret.exs
# Phoenix digest
RUN MIX_ENV=prod mix phx.digest
# Compile Elixir App
RUN MIX_ENV=prod mix compile
# RUN MIX_ENV=prod mix ecto.create && mix ecto.migrate
# RUN MIX_ENV=prod mix run apps/phoenix_china/priv/repo/seeds.exs
# Exposes port
EXPOSE 4000

# The command to run when this image starts up
# CMD MIX_ENV=prod mix phx.server