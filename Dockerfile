FROM ruby:3.1.2

# Default directory
ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

# Install gems
WORKDIR $INSTALL_PATH
COPY . /opt/app
RUN gem install rails bundler
RUN bundle install

# Start server
CMD bundle exec puma