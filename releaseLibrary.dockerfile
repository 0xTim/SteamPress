FROM swift:5.0.2

WORKDIR /package

COPY . ./

RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev \
  && rm -r /var/lib/apt/lists/*
RUN swift package clean
CMD swift build -c release
