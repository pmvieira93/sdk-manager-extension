#/bin/bash -e

######################################################################################
# SDKE or SDK-EXTENSION
#
# Description:
#       Script to display all installed and current (default) packages management by SDK
#
# Reference:
#       https://sdkman.io/       
#
# Author:
#       Pedro Vieira @pmvieira93
#
# Version:
#       1.0 | 2022/11/05
#               - Creation of Script
#       1.1 | 2022/11/12
#               - Fix problem of current and default package version that is in use
#       1.2 | 2023/02/04
#               - Add helper info to change current package/version
#
######################################################################################

printf "##########################################################################\n\n"

# Check if SDK Package Manager is installed
if [[ -z "$SDKMAN_DIR" ]]; then
        echo "SDK Package Manager is not installed"
        exit 1
fi

if [[ -z "$SDKMAN_VERSION" ]]; then
    # Load SDK inside of this bash script
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    SDKMAN_VERSION=$(sdk version | tr '\n' ';' | sed -e 's/: /;/g' | cut -d ';' -f4 | tr -d '\n')
fi

# Diplay current Version
printf "SDK Package Manager is installed with version: $SDKMAN_VERSION\n\n"

# Define and Init Variables
SDK_LIBS_DIR=$SDKMAN_DIR/candidates
CURRENT_PKG=""
LAST_PKG=""
OUTPUT=""

# Check and Get Installed Libs
SDK_ALL_LIBS_VERSIONS=$(find $SDK_LIBS_DIR -maxdepth 2 -mindepth 2 -print | sort -h)

# Iterate each Lib that have been found
for LINE in $SDK_ALL_LIBS_VERSIONS; do

        L_PKG=$(echo "$LINE" | awk -F '/' '{ print $6 }')
        L_VERSION=$(echo "$LINE" | awk -F '/' '{ print $7 }')

        CURRENT_PKG=$L_PKG

        # Write the Package name of Lib
        if [[ "$CURRENT_PKG" != "$LAST_PKG" ]]; then
                OUTPUT=$(echo "$OUTPUT" | sed "s+####++g")
                OUTPUT="$OUTPUT$CURRENT_PKG\n"
        fi

        # Print Versions below of Package
        if [[ "$L_VERSION" != "current" ]]; then
                OUTPUT="$OUTPUT\t####$L_VERSION\n"
        fi

        # Mark the versions of package with Default
        if [[ "$L_VERSION" == "current" ]]; then
                CURRENT_VERSION=$(ls -l $LINE | awk -F '->' '{ print $2 }' | xargs)
                if [[ "$PATH" == *"$SDK_LIBS_DIR/$CURRENT_PKG/current"* ]]; then
                        OUTPUT=$(echo "$OUTPUT" | sed "s+####$CURRENT_VERSION+$CURRENT_VERSION\t✅ +g")
                fi
        elif [[ "$PATH" == *"$SDK_LIBS_DIR/$CURRENT_PKG/$L_VERSION"* ]]; then
                OUTPUT=$(echo "$OUTPUT" | sed "s+####$L_VERSION+$L_VERSION\t⌛ +g")
        fi

        LAST_PKG=$CURRENT_PKG
done

# Clean-Up watermark
OUTPUT=$(echo "$OUTPUT" | sed "s+####++g")

# Print Result
echo -e "\n$OUTPUT"

printf "
##########################################################################

HELPER:
  sdk use <package> <version>           - define current package to use
                                        (will be reset after close the bash)
  sdk default <package> <version>       - define default package/version

        ______________________________________________________

Ex.:
  sdk use java 22.3.1.r19-grl           # change current java version of bash session
  sdk default quarkus 2.12.3.Final      # change default quarkus version of system


More information about SDK command:
  sdk help
  https://sdkman.io/

"

exit 0