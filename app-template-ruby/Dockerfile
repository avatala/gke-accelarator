# Dockerfile
# gets the docker parent image
FROM ruby:2.7.0

RUN apt-get update && apt-get install -y npm && npm install -g yarn

RUN mkdir -p /var/app
COPY /app /var/app
WORKDIR /var/app

RUN bundle install

CMD rails s -b 0.0.0.0