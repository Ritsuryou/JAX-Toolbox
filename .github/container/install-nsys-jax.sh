#!/bin/bash
set -exo pipefail

REF="$1"
if [[ -z "${REF}" ]]; then
  echo "$0: <git ref of JAX-Toolbox>"
  exit 1
fi

# Install extra dependencies needed for `nsys recipe ...` commands. These are
# used by the nsys-jax wrapper script.
NSYS_DIR=$(dirname $(realpath $(command -v nsys)))
ln -s ${NSYS_DIR}/python/packages/nsys_recipe/requirements/common.txt /opt/pip-tools.d/requirements-nsys-recipe.in

# Install the nsys-jax package, which includes nsys-jax, nsys-jax-combine,
# install-protoc (called from pip-finalize.sh), and nsys-jax-patch-nsys as well as the
# nsys_jax Python library.
URL="git+https://github.com/NVIDIA/JAX-Toolbox.git@${REF}#subdirectory=.github/container/nsys_jax&egg=nsys-jax"
echo "-e '${URL}'" > /opt/pip-tools.d/requirements-nsys-jax.in

# protobuf will be installed at least as a dependency of nsys_jax in the base
# image, but the installed version is likely to be influenced by other packages.
echo "install-protoc /usr/local" > /opt/pip-tools-post-install.d/protoc
chmod 755 /opt/pip-tools-post-install.d/protoc

# Make sure flamegraph.pl is available
echo "install-flamegraph /usr/local" > /opt/pip-tools-post-install.d/flamegraph
chmod 755 /opt/pip-tools-post-install.d/flamegraph

# Make sure Nsight Systems Python patches are installed if needed
echo "nsys-jax-patch-nsys" > /opt/pip-tools-post-install.d/patch-nsys
chmod 755 /opt/pip-tools-post-install.d/patch-nsys
