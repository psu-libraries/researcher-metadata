FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.6-node-18:20250212 as base
# Isilon has issues with uid 2000 for some reason
# change the app to run as 201
ARG UID=201
ARG GID=201

USER root
WORKDIR /app
RUN groupadd -g $GID app
RUN useradd -l -u $UID app -g $GID -d /app
RUN mkdir /app/tmp && mkdir -p /app/vendor/cache
RUN chown -R app /app

USER app
COPY Gemfile Gemfile.lock /app/
# in the event that bundler runs outside of docker, we get in sync with it's bundler version
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
RUN bundle config set path 'vendor/bundle'
COPY vendor/cache vendor/cache
RUN bundle install && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache

COPY package.json yarn.lock /app/
RUN yarn --frozen-lockfile && \
  rm -rf /app/.cache && \
  rm -rf /app/tmp

COPY --chown=app . /app
# Only remove .gem files 
# Gems pulled directly from Github (not .gem files) should stay
RUN rm -rf /app/vendor/cache/*.gem && \
  rm -rf /app/.bundle/cache/*.gem

CMD ["/app/bin/start"]

FROM base AS dev
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends\
  rsync \
  google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*
RUN chown -R app:app /app

USER app
RUN bundle config set path 'vendor/bundle' && bundle exec rails assets:precompile

CMD ["/app/bin/start"]

# Final Target
FROM base AS production

RUN RAILS_ENV=production SECRET_KEY_BASE=secret\
  bundle exec rails assets:precompile && \
  rm -rf /app/.cache/ && \
  rm -rf /app/node_modules/.cache/ && \
  rm -rf /app/tmp/

CMD ["/app/bin/start"]
