FROM ruby:3.4.6-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs yarn

COPY rails/Gemfile rails/Gemfile.lock ./
RUN bundle install

COPY rails/ ./

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]

