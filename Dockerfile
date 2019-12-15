FROM ruby:2.5
RUN bundle config --global frozen 1
RUN apt-get update && \
    apt-get install -y ffmpeg imagemagick
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY src src
ENTRYPOINT ["ruby", "main.rb"]
