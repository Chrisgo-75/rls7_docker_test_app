FROM ruby:3.2.3
LABEL maintainer="Chris Arndt <christopher.arndt@wisc.edu>"

# The base image is based on Debian, and we use apt to install packages.  Apt
# will use the DEBIAN_FRONTEND environment variable to allow limited control
# in its behavior.  In this case, we don't want it to ask interactive questions
# as that will make the docker build command appear to be hung.
ENV DEBIAN_FRONTEND noninteractive

# Download latest package information and install packages.
# -y option says to answer yes to any prompts.
# -qq option enables quiet mode to reduce printed output.
# Note: it is always recommended to combine the apt-get update and
#       apt-get install commands into a single RUN instruction.
# apt-transport-https = allow apt to work with https-based sources
# RUN apt-get update -yqq
# rm -rf /var/lib/apt/lists/* == removes nodejs package lists.
RUN apt-get update -y && apt-get --force-yes install -y --no-install-recommends  \
    build-essential \
    vim \
    curl \
    less \
    libmariadb-dev \
    git && \
    rm -rf /var/lib/apt/lists/*
# redis-tools && \    THE 2nd to last line needs appersands.


# Change some environment variables from the defaults set in the official Docker image for Ruby
#RUN echo $PATH

# Install Nodejs
COPY scripts/install_nodejs.sh ./
RUN ./install_nodejs.sh && rm ./install_nodejs.sh
RUN echo "NODE Version:" && node --version

# Create and define the node_modules's cache directory.
RUN mkdir /usr/src/cache
WORKDIR /usr/src/cache

# Install the application's dependencies into the node_modules's cache directory.
COPY package.json ./
COPY package-lock.json ./
RUN npm install
RUN echo "NPM Version:" && npm --version

# Install Yarn globally
RUN npm install --global yarn

# Make this the current working directory for the image. So we can execute Rails \
# cmds against image.
RUN mkdir -p /usr/src/app

# Gemfile Caching Trick
# Note: When using COPY with more than one source file, the destination must
#       be a directory and end with a /
# 1. This creates a separate, independent layer. Docker's cache for this layer
#    will only be busted if either of these two files (Gemfile & Gemfile.lcok) change.
COPY Gemfile* /usr/src/app/

# CD or change into the working directory.
WORKDIR /usr/src/app

# Set timezone. Which conflicted with trying to connect to campus Oracle database.
# The Oracle error is: ORA-01805: possible error in date/time operation
ENV TZ=America/Chicago
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#RUN timedatectl set-timezone America/Chicago

RUN echo "gem: --no-document" >> ~/.gemrc && \
  bundle install

# ADD/COPY app files from local directory into container so they are baked into the image.
# The source path on our local machine is always relative to where the Dockerfile is located.
ADD . /usr/src/app

# Add a script to be executed every time the container starts.
# Entrypoint files are used to set up or configure a container at runtime.
# Below file needs to be executable: $ sudo chmod +x docker_entrypoint_staging.sh
ENTRYPOINT ["./entrypoints/docker_entrypoint_dev.sh"]

# Start the Rails server by default (bake it into the image).
#CMD ["rails", "s", "-b", "0.0.0.0"]
# Below has been moved to entrypoint file.
#CMD ["bundle", "exec", "passenger", "start"]