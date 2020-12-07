#!/bin/bash
set -e

# # Check for required variables
# : "${PYPI_USERNAME:?Need to set PYPI_USERNAME!}"
# : "${PYPI_PASSWORD:?Need to set PYPI_PASSWORD!}"
# : "${ARTIFACTORY_USERNAME:?Need to set ARTIFACTORY_USERNAME!}"
# : "${ARTIFACTORY_PASSWORD:?Need to set ARTIFACTORY_PASSWORD!}"

# Create .pypirc file with PyPi and Artifactory repos and credentials set
cat > ~/.pypirc <<_EOF
[distutils]
index-servers =
    pypi

[pypi]
repository:https://pypi.python.org/pypi

_EOF