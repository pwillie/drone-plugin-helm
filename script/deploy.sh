#!/bin/bash -e

# Drone plugin for in cluster helm deployments
# Parameters/environment variables:
#
#  - PLUGIN_NAMESPACE kubernetes namespace for deployment
#  - PLUGIN_REPO_NAME helm chart repo name
#  - PLUGIN_REPO_URL  helm chart repo url
#  - PLUGIN_CHART     helm chart
#  - PLUGIN_VERSION   helm chart version
#  - PLUGIN_RELEASE   helm release name
#  - PLUGIN_CONFIGS   config files to be passed to helm chart
#  - PLUGIN_SETVARS   helm chart variable overrides

if [ -n "$PLUGIN_PARAMFILE" ]; then
  . $PLUGIN_PARAMFILE
fi

# ensure we have mandatory parameters
: ${PLUGIN_RELEASE:?}
: ${PLUGIN_NAMESPACE:?}
: ${PLUGIN_CHART:?}

upgradecmd="helm upgrade -i --wait ${PLUGIN_RELEASE} --namespace ${PLUGIN_NAMESPACE} ${PLUGIN_CHART}"

if [ -n "$PLUGIN_VERSION" ]; then
  upgradecmd="${upgradecmd} --version ${PLUGIN_VERSION}"
fi

for f in ${PLUGIN_CONFIGS//,/ }; do
  upgradecmd="${upgradecmd} -f ${f}"
done

if [ -n "$PLUGIN_SETVARS" ]; then
  upgradecmd="${upgradecmd} --set ${PLUGIN_SETVARS}"
fi

if [ -n "$PLUGIN_REPO_NAME" ] && [ -n "$PLUGIN_REPO_URL" ]; then
  echo helm repo add ${PLUGIN_REPO_NAME} ${PLUGIN_REPO_URL}
  echo helm repo update
fi

echo $upgradecmd
