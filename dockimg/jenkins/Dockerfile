#FROM jenkins
FROM csanchez/jenkins-slave
ENV RUBY_VERSION 1.9.3

USER root

# change default bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install essentials packages
# RUN apt-get update && apt-get install DEBIAN_FRONTEND=noninteractive install -yq build-essential curl gnupg git vim

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      build-essential \
      curl \
      libssl-dev \
      gnupg \
      git \
      ruby-all-dev \
      ruby-dev \
      vim \
      sudo \
      bison \
      zlib1g-dev \
      libxml2-dev \
      libpq-dev \
      libmysqlclient-dev \
      git-core \
      postgresql-9.4 \
      nodejs \
      postgresql-client-9.4

# Download RVM as root
RUN  export HOME="/root" && curl -#LO https://rvm.io/mpapis.asc && gpg --import mpapis.asc 
RUN  export HOME="/root" && \curl -sSL https://get.rvm.io | bash -s stable

# Install RVM requirements
RUN /bin/bash -lc "rvm requirements"

# Add jenkins to rvm group
RUN usermod -a -G rvm jenkins

# Install Ruby
RUN /bin/bash -lc  "rvm install $RUBY_VERSION  && rvm use $RUBY_VERSION --default"

# Set no doc for gem
RUN echo "gem: --no-rdoc --no-ri" >> /root/.gemrc

# Install bundler
RUN /bin/bash -lc  "gem install bundler -no-doc --no-ri"
ADD ./utils/Gemfile /root/Gemfile

RUN  /bin/bash -lc  "bundle install --gemfile=/root/Gemfile"
RUN echo 'export rvm_prefix="$HOME"' > /root/.rvmrc && echo 'export rvm_path="$HOME/.rvm"' >> /root/.rvmrc
ADD ./utils/bashrc_rvm /root/.bashrc

# Add Jenkins Log folder
RUN mkdir /var/log/jenkins \
    && touch /var/log/jenkins/jenkins.log \
    && chown -R  jenkins:jenkins /var/log/jenkins

# slim down image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*
RUN source /root/.bashrc
RUN source /etc/profile.d/rvm.sh
# set right for jenkins at  home
RUN [ -d /var/jenkins_home ]  && chown -R jenkins:jenkins /var/jenkins_home || echo "not"
# postgres autostart and start
RUN update-rc.d postgresql enable
RUN /etc/init.d/postgresql start
# change pass postgress
RUN sudo -u postgres psql -c "ALTER USER postgres PASSWORD '';"
