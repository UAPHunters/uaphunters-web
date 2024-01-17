FROM ruby:3.3-slim-bullseye as jekyll

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /site || true

RUN gem update --system && gem install jekyll && gem cleanup

COPY * /site/


EXPOSE 4000

WORKDIR /site

RUN bundle install



# build from the image we just built with different metadata
FROM jekyll as jekyll-serve


CMD [ "bundle", "exec", "jekyll", "serve", "--force_polling", "-H", "0.0.0.0", "-P", "4000" ]