FROM ruby:3.2.2-slim

WORKDIR /app

COPY Gemfile ./
COPY Gemfile.lock ./

RUN apt update && apt install -y \
    build-essential \
    default-libmysqlclient-dev \
    git
RUN bundle install -j5

CMD bundle exec rackup config.ru -o 0.0.0.0
