FROM alpine:3.7

LABEL description="Drone plugin to aid in cluster Helm deployments"

ENV HELM_VERSION="v2.12.2"
ENV KUBE_VERSION="v1.13.2"
ENV YQ_VERSION="1.14.1"

ENV KUBERNETES_SERVICE_HOST=kubernetes.default
ENV KUBERNETES_SERVICE_PORT=443

RUN apk add --update bash ca-certificates curl git py-pip \
   && pip install awscli --upgrade \
   && curl -sSLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl \
   && chmod +x /usr/local/bin/kubectl \
   && curl -sS http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | \
   tar xvz --strip 1 -C /usr/local/bin linux-amd64/helm \
   && curl -sSLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 \
   && chmod +x /usr/local/bin/yq \
   && helm init --client-only

ADD script /usr/local/bin/

RUN chmod +x /usr/local/bin/*

ENTRYPOINT [ "/usr/local/bin/deploy.sh" ]

ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-url=$VCS_URL