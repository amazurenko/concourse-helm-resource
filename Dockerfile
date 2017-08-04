FROM alpine:3.6

RUN set -e \
 && pkgs=' \
         ca-certificates \
         curl \
         tar \
         jq \
         bash \
        ' \
 && apk add \
    --update \
    --upgrade \
    --no-cache \
    $pkgs \
 && rm -rf /var/cache/apk/*

ENV KUBERNETES_VERSION=1.7.2
RUN set -e \
 && curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && echo; kubectl version --client; echo

ENV HELM_VERSION=2.5.1
RUN set -e \
 && curl -l https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 |  tar -zx -C /tmp/ \
 && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
 && rm -rf /tmp/* \
 && echo; helm version --client; echo

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/*

CMD [ "/usr/local/bin/helm" ]
