#!/bin/bash 


# This is one of several utility scripts used by Fake-Name's automated build setup
# to automatically create compiled versions of the CoC codebase
#
# this is the actual call to mxmlc that builds a complete swf

# pull out the version so we can use it for the filename.
export COC_VERSION=`gawk 'match($0, /^[\s\t]+ver = \"(.+)\";/, n) { print n[1] }' < classes/classes/CoC.as`

echo "Build version = ${COC_VERSION}"

# Clean up old build-artifacts (probably unnecessary with buildbot's build mechanisms)
rm -f CoC*.swf

# Force the submodules to be up to date.
git submodule update --init

# This is intended to be run from the root of the git repo as such:
# 'devTools/build.sh'
# the paths are all relative to the repo root.
/opt/flex/bin/mxmlc \
-use-network=false \
-default-background-color=0x000000 \
-static-link-runtime-shared-libraries=true \
-strict=false \
-source-path+=classes \
-library-path+=./lib/bin/MainView.swc \
-library-path+=./lib/bin/ScrollPane.swc \
-o ../binRepo/CoC-${COC_VERSION}.swf \
classes/classes/CoC.as

# Build the Android package

/opt/flex/bin/adt \
-package \
-target apk \
-storetype pkcs12 \
-keystore ./cert/CorruptionofChampionsAIR.p12 \
-storepass testpassword \
../binRepo/CoC-${COC_VERSION}.apk \
application.xml \
-C ../binRepo . \
-C icons/android .