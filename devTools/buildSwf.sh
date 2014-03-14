#!/bin/bash

# This is one of several utility scripts used by Fake-Name's automated build setup
# to automatically create compiled versions of the CoC codebase
#
# this is the actual call to mxmlc that builds a complete swf

set -e

OS=$(uname -s)
FLEX_ROOT=/opt/flex
ADT=${FLEX_ROOT}/bin/adt
if [[ ${OS} =~ ^CYGWIN ]]; then
    FLEX_ROOT=/c/APPS/flex_4_6
    ADT="java -jar $(cygpath -w ${FLEX_ROOT})/lib/adt.jar"
fi

# pull out the version so we can use it for the filename.
export COC_VERSION=`gawk 'match($0, /^[\s\t]+ver = \"(.+)\";/, n) { print n[1] }' < classes/classes/CoC.as`

echo "Build version = ${COC_VERSION}"

# Clean up old build-artifacts (probably unnecessary with buildbot's build mechanisms)
rm -f ../binRepo/CoC*.swf

# Force the submodules to be up to date.
git submodule update --init

# This is intended to be run from the root of the git repo as such:
# 'devTools/build.sh'
# the paths are all relative to the repo root.
${FLEX_ROOT}/bin/mxmlc \
-use-network=false \
-default-background-color=0x000000 \
-static-link-runtime-shared-libraries=true \
-strict=false \
-define+=CONFIG::release,false \
-define+=CONFIG::debug,true \
-source-path+=classes \
-library-path+=./lib/bin/MainView.swc \
-library-path+=./lib/bin/ScrollPane.swc \
-o ../binRepo/CoC-${COC_VERSION}.swf \
classes/classes/CoC.as

# Build the Android package
echo Patching xml file to build android package

export SWF_NAME=`ls ../binRepo/ | grep -i ^CoC.*\.swf$`

echo Current SWF file name = $SWF_NAME

/bin/sed -i -r "s/<content>CoC.*\.swf<\/content>/<content>${SWF_NAME}<\/content>/" ./devTools/application.xml

echo Done. Building android package.

$ADT \
-package \
-target apk \
-storetype pkcs12 \
-keystore ./devTools/cert/CorruptionofChampionsAIR.p12 \
-storepass testpassword \
../binRepo/CoC-${COC_VERSION}.apk \
./devTools/application.xml \
-C ../binRepo . \
-C ./devTools/icons/android .


## Fuck you Adobe. They no longer support air on linux. Assholes.
## If you uncomment the below, it *may* build a air iOS package.

# echo Android package built. Building iOS package.

# $ADT \
# -package \
# -target ipa-ad-hoc \
# -storetype pkcs12 \
# -keystore ./devTools/cert/CorruptionofChampionsAIR.p12 \
# -storepass testpassword \
# -provisioning-profile ./devTools/cert/Fake.mobileprovision \
# ../binRepo/CoC-${COC_VERSION}.ipa \
# ./devTools/application.xml \
# -C ../binRepo . \
# -C ./devTools/icons/ios .

