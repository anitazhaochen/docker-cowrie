FROM ubuntu as builder
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
RUN groupadd -r -g 1000 cowrie && \
    useradd -r -u 1000 -d /cowrie -m -g cowrie cowrie

# Set up Debian prereqs
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      python-pip \
      libssl-dev \
      libffi-dev \
      build-essential \
      python-dev \
      python \
      git \
      virtualenv \
      python-virtualenv \
      authbind
RUN touch /etc/authbind/byport/22 && chmod 777 /etc/authbind/byport/22 && chown cowrie:cowrie /etc/authbind/byport/22

    # Build a cowrie environment from github master HEAD.

RUN su cowrie
copy cowrie/ /cowrie/cowrie-git
RUN \
      cd /cowrie/cowrie-git && \
        virtualenv cowrie-env && \
        . cowrie-env/bin/activate && \
        pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip && \
        pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade cffi && \
        pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade setuptools && \
        pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  --upgrade -r /cowrie/cowrie-git/requirements.txt

FROM ubuntu
MAINTAINER Michel Oosterhof <michel@oosterhof.net>
RUN groupadd -r -g 1000 cowrie && \
    useradd -r -u 1000 -d /cowrie -m -g cowrie cowrie

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      libssl1.1 \
      libffi6 \
      python \
      authbind

RUN touch /etc/authbind/byport/22 && chmod 777 /etc/authbind/byport/22


COPY --from=builder /cowrie/cowrie-git /cowrie/cowrie-git
RUN chown -R cowrie:cowrie /cowrie

USER cowrie
WORKDIR /cowrie/cowrie-git
CMD [ "/cowrie/cowrie-git/bin/cowrie", "start", "-n" ]
EXPOSE 22 23
VOLUME [ "/cowrie/cowrie-git/etc" ]
