#!/bin/bash
set -e

# Created by Kevin & Mauricio | AMX GADT

# Get Options

# JENKINS_HOST
# JENKINS_USER
# JENKINS_PASSWORD
# JENKINS_USER_ID
# JENKINS_DOMAIN
# JENKINS_NEW_USERNAME
# JENKINS_NEW_PASSWORD
# JENKINS_NEW_SCOPE
# JENKINS_NEW_DESCRIPTION
# JENKINS_NEW_ID

## Menu
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "Script to manage credential Jenkins"
            echo " "
            echo "${0##*/} [options]"
            echo " "
            echo "Options:"
            echo "-h, --help                                                      Show brief help"
            echo "--user=USER, --user USER                                        User to connect to Jenkins"
            echo "--password=PASSWORD, --password PASSWORD                        Password to connect to Jenkins"
            echo "--host=PASSWORD, --host PASSWORD                                Host where is Jenkins (E.g. https://jenkins.example.com)"
            echo "--id=ID, --id ID                                                User id to modify"
            echo "--domain=DOMAIN, --domain DOMAIN                                Domain where are credentials (Default: _)"
            echo "--new-username=USERNAME, --new-username USERNAME                New username"
            echo "--new-password=PASSWORD, --new-password PASSWORD                New password"
            echo "--new-scope=SCOPE, --new-scope SCOPE                            New scope"
            echo "--new-description=DESCRIPTION, --new-description DESCRIPTION    New description, NOTE: Put it in quotes"
            echo "--new-id=ID, --new-id ID                                        New id"
            exit 0
        ;;
        --user*)
            if [ "$1" == "--user" ]; then
                shift
                JENKINS_USER=$1
                shift
            else
                JENKINS_USER=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --password*)
            if [ "$1" == "--password" ]; then
                shift
                JENKINS_PASSWORD=$1
                shift
            else
                JENKINS_PASSWORD=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --host*)
            if [ "$1" == "--host" ]; then
                shift
                JENKINS_HOST=$1
                shift
            else
                JENKINS_HOST=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --id*)
            if [ "$1" == "--id" ]; then
                shift
                JENKINS_USER_ID=$1
                shift
            else
                JENKINS_USER_ID=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --domain*)
            if [ "$1" == "--domain" ]; then
                shift
                JENKINS_DOMAIN=$1
                shift
            else
                JENKINS_DOMAIN=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --new-username*)
            if [ "$1" == "--new-username" ]; then
                shift
                JENKINS_NEW_USERNAME=$1
                shift
            else
                JENKINS_NEW_USERNAME=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --new-password*)
            if [ "$1" == "--new-password" ]; then
                shift
                JENKINS_NEW_PASSWORD=$1
                shift
            else
                JENKINS_NEW_PASSWORD=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --new-scope*)
            if [ "$1" == "--new-scope" ]; then
                shift
                JENKINS_NEW_SCOPE=$1
                shift
            else
                JENKINS_NEW_SCOPE=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --new-description*)
            if [ "$1" == "--new-description" ]; then
                shift
                JENKINS_NEW_DESCRIPTION=$1
                shift
            else
                JENKINS_NEW_DESCRIPTION=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        --new-id*)
            if [ "$1" == "--new-id" ]; then
                shift
                JENKINS_NEW_ID=$1
                shift
            else
                JENKINS_NEW_ID=$(echo $1 | awk '{sub(/=/," ")}1' | awk '{print $2}')
                shift
            fi
        ;;
        *)
            echo "\t\t[AMX] Option $1 is not a recognized flag!"
            exit 1
            ;;
    esac
done

if [ -z "${JENKINS_HOST}" ]; then
    echo "\t\t[AMX] Option --host not found"
    exit 2
elif [ "$(echo $JENKINS_HOST | awk '{sub(/:/," ")}1' | awk '{print $1}')" != "https" ] && [ "$(echo $JENKINS_HOST | awk '{sub(/:/," ")}1' | awk '{print $1}')" != "http" ]; then
    echo "\t\t[AMX] In option --host protocol not found"
    exit 2
fi

if [ -z "${JENKINS_USER}" ]; then
    echo "\t\t[AMX] Option --user not found"
    exit 2
fi

if [ -z "${JENKINS_PASSWORD}" ]; then
    echo "\t\t[AMX] Option --password not found"
    exit 2
fi

if [ -z "${JENKINS_USER_ID}" ]; then
    echo "\t\t[AMX] Option --id not found"
    exit 2
fi

if [ -z "${JENKINS_DOMAIN}" ]; then
    JENKINS_DOMAIN="_"
else
    JENKINS_DOMAIN=$(echo $JENKINS_DOMAIN | sed "s# #%20#g")
fi


## Remove old cookie if exists
if [ -f "jenkins_cookies.txt" ]; then
    rm -f jenkins_cookies.txt
fi

## Remove old config.xml if exists
if [ -f "config.xml" ]; then
    rm -f config.xml
fi

## Get crumb
JENKINS_CRUMB=$(curl -s -c jenkins_cookies.txt -u $JENKINS_USER:$JENKINS_PASSWORD "$JENKINS_HOST/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

echo ""
echo '--------------------------------------------------------------------'
echo -e "\t\t[AMX] Getting credentials"
echo '--------------------------------------------------------------------'

## Get config.xml
get_xml=$(curl -OX GET \
    --output /dev/null \
    --write-out "%{http_code}" \
    -u $JENKINS_USER:$JENKINS_PASSWORD \
    -b jenkins_cookies.txt \
    -H $JENKINS_CRUMB \
    "$JENKINS_HOST/credentials/store/system/domain/$JENKINS_DOMAIN/credential/$JENKINS_USER_ID/config.xml")

if [ $get_xml != 200 ]; then
    echo ""
    echo '--------------------------------------------------------------------'
    echo -e "\t\t[AMX] Failed obtaining credentials"
    echo '--------------------------------------------------------------------'
    exit 0
else
    echo ""
    echo '--------------------------------------------------------------------'
    echo -e "\t\t[AMX] Updating Credentials"
    echo '--------------------------------------------------------------------'
fi

## Update config.xml
if [ -n "${JENKINS_NEW_USERNAME}" ]; then
    sed -i "s%<username>.*%<username>$JENKINS_NEW_USERNAME</username>%g" config.xml
fi

if [ -n "${JENKINS_NEW_PASSWORD}" ]; then
    sed -i "s%<secret-redacted/>%\t\t\t$JENKINS_NEW_PASSWORD%g" config.xml
fi

if [ -n "${JENKINS_NEW_SCOPE}" ]; then
    sed -i "s%<scope>.*%<scope>$JENKINS_NEW_USERNAME</scope>%g" config.xml
fi

if [ -n "${JENKINS_NEW_DESCRIPTION}" ]; then
    sed -i "s%<description>.*%<description>$JENKINS_NEW_DESCRIPTION</description>%g" config.xml
fi

if [ -n "${JENKINS_NEW_ID}" ]; then
    sed -i "s%<id>.*%<id>$JENKINS_NEW_ID</id>%g" config.xml
fi

## Update credential
update=$(curl -iX POST \
    -u $JENKINS_USER:$JENKINS_PASSWORD \
    --output /dev/null \
    --write-out "%{http_code}" \
    -b jenkins_cookies.txt \
    -H $JENKINS_CRUMB \
    -H content-type:application/xml \
    -d @config.xml \
    "$JENKINS_HOST/credentials/store/system/domain/$JENKINS_DOMAIN/credential/$JENKINS_USER_ID/config.xml")

if [ $update != 200 ]; then
    echo ""
    echo '--------------------------------------------------------------------'
    echo -e "\t\t[AMX] Failed updating credentials"
    echo '--------------------------------------------------------------------'
    exit 0
else
    echo ""
    echo '--------------------------------------------------------------------'
    echo -e "\t\t[AMX] The changes were made succesful"
    echo '--------------------------------------------------------------------'
fi

## Clean directory
rm -f jenkins_cookies.txt
rm -f config.xml