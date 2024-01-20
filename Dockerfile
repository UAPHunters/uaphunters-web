FROM ruby:3.3-slim-bullseye as jekyll

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && apt upgrade -y

# Install Caddy
RUN apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
RUN apt update
RUN apt install caddy -y


# Copy files
RUN mkdir -p /site || true

RUN gem update --system && gem install jekyll && gem cleanup

COPY * /site/

WORKDIR /site

RUN bundle install
RUN bundle exec jekyll build

EXPOSE 4000


# build from the image we just built with different metadata
FROM jekyll as jekyll-serve

WORKDIR /site/_site
CMD ["caddy", "file-server", "--listen", ":4000"]