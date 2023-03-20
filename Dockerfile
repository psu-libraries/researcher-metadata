FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.2-node-16:20230320 as base
ARG UID=2000
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

RUN useradd -l -u $UID app -d /app
RUN mkdir /app/tmp && mkdir -p /app/vendor/cache
RUN chown -R app /app

USER app

COPY Gemfile Gemfile.lock /app/
# in the event that bundler runs outside of docker, we get in sync with it's bundler version
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
RUN bundle config set path 'vendor/bundle'

FROM base as builder 
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY vendor/cache vendor/cache
RUN bundle install && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache

COPY package.json yarn.lock /app/
RUN yarn --frozen-lockfile && \
  rm -rf /app/.cache && \
  rm -rf /app/tmp

COPY --chown=app . /app

RUN rm -rf /app/vendor/cache && \
  rm -rf /app/.bundle/cache

FROM base as app

COPY --from=builder /app /app


FROM app as dev
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends\
  rsync \
  google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*

USER app

CMD ["sleep", "infinity"]

FROM app as production 

RUN RAILS_ENV=production SECRET_KEY_BASE=secret\
 bundle exec rails assets:precompile && \
 rm -rf /app/.cache/ && \
 rm -rf /app/node_modules/.cache/ && \
 rm -rf /app/tmp/

CMD ["/app/bin/start"]

