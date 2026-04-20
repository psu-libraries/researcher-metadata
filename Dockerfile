
FROM harbor.k8s.libraries.psu.edu/library/ruby-3.4.9-node-22:20260415 AS base
# Isilon has issues with uid 2000 for some reason
# change the app to run as 201
ARG UID=201
ARG GID=201

USER root
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  libyaml-dev \
  && rm -rf /var/lib/apt/lists*

RUN groupadd -g $GID app || true
RUN useradd -u $UID -g $GID -d /app app || true
WORKDIR /app
RUN mkdir -p /app/tmp /app/vendor/cache && chown -R app:app /app
RUN mkdir -p /tmp/app && chown app:app /tmp/app && chmod 755 /tmp/app

COPY --chown=app:app Gemfile Gemfile.lock /app/
COPY --chown=app:app vendor/cache /app/vendor/cache
USER app
RUN gem install bundler -v "$(grep -A 1 'BUNDLED WITH' Gemfile.lock | tail -n 1)"
RUN bundle config set path 'vendor/bundle'
RUN bundle install && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache

COPY --chown=app:app package.json yarn.lock /app/
RUN yarn install --frozen-lockfile && \
  rm -rf /app/.cache && \
  rm -rf /app/tmp

COPY --chown=app:app . /app
RUN rm -rf /app/vendor/cache/*.gem && \
  rm -rf /app/.bundle/cache/*.gem

CMD ["/app/bin/start"]

FROM base AS dev
SHELL ["/bin/bash", "-o", "pipefail", "-c"]


# Add Google Chrome signing key and repo (modern Debian/Ubuntu way)
USER root
RUN mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
  rsync \
  google-chrome-stable \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /app/node_modules/.cache/ \
  && rm -rf /app/tmp/
RUN chown -R app:app /app

USER app
RUN bundle config set path 'vendor/bundle' && bundle exec rails assets:precompile
FROM base AS production

RUN RAILS_ENV=production SECRET_KEY_BASE=secret \
  bundle exec rails assets:precompile && \
  rm -rf /app/node_modules/.cache/ && \
  rm -rf /app/tmp/

CMD ["/app/bin/start"]
