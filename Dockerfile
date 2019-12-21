FROM ruby:2.5
RUN bundle config --global frozen 1
RUN apt-get update && \
    apt-get install -y ffmpeg imagemagick
WORKDIR /usr/src/app
COPY src src
RUN bundle install --gemfile=src/Gemfile
ENTRYPOINT ["ruby", "main.rb"]
