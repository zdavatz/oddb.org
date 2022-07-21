FROM ruby:3.0

RUN apt-get update && apt-get install -y libpq-dev imagemagick libmagickwand-dev ubuntu-dev-tools

COPY . /workdir
WORKDIR /workdir
RUN bundle install
