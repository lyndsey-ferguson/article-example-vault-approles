FROM ruby:2.5

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config

WORKDIR /usr/src/app

ADD https://download.libsodium.org/libsodium/releases/LATEST.tar.gz ./
RUN tar -zxvf LATEST.tar.gz

WORKDIR /usr/src/app/libsodium-stable
RUN ./configure
RUN make && make check
RUN make install
RUN ldconfig

WORKDIR /usr/src/app
COPY Gemfile ./
RUN bundle install

COPY . .

ENTRYPOINT ["ruby", "update_custom_mobile_apps_secret_id.rb"]