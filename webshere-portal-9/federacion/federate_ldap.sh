#!/bin/sh
set -x
#
# This script assumes cn=users,${BASE} and cn=groups,${BASE}
#

EnableFederatedLDAPSecuritytemplate="IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIyMjIyMjCiMgSUJNIFdlYlNwaGVyZSBQb3J0YWwgY29uZmlndXJhdGlv
biBoZWxwZXIgZmlsZSBmb3Igc2NyaXB0IEVuYWJsZUZlZGVyYXRlZExEQVBTZWN1cml0eS4gCiMj
IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIyMjIwpmZWRlcmF0ZWQubGRhcC5iYXNlRE49JUJBU0VfRE4lCmZlZGVy
YXRlZC5sZGFwLmJpbmRETj11aWQ9d3BzYmluZCxjbj11c2VycywlQkFTRV9ETiUKZmVkZXJhdGVk
LmxkYXAuYmluZFBhc3N3b3JkPSVXUFNCSU5EUFdEJQpmZWRlcmF0ZWQubGRhcC5ldC5ncm91cC5v
YmplY3RDbGFzc2VzPWdyb3VwT2ZVbmlxdWVOYW1lcwpmZWRlcmF0ZWQubGRhcC5ldC5ncm91cC5v
YmplY3RDbGFzc2VzRm9yQ3JlYXRlPQpmZWRlcmF0ZWQubGRhcC5ldC5ncm91cC5zZWFyY2hCYXNl
cz1jbj1ncm91cHMsJUJBU0VfRE4lCmZlZGVyYXRlZC5sZGFwLmV0LnBlcnNvbmFjY291bnQub2Jq
ZWN0Q2xhc3Nlcz1pbmV0b3JncGVyc29uCmZlZGVyYXRlZC5sZGFwLmV0LnBlcnNvbmFjY291bnQu
b2JqZWN0Q2xhc3Nlc0ZvckNyZWF0ZT0KZmVkZXJhdGVkLmxkYXAuZXQucGVyc29uYWNjb3VudC5z
ZWFyY2hCYXNlcz1jbj11c2VycywlQkFTRV9ETiUKZmVkZXJhdGVkLmxkYXAuZ20uZHVtbXlNZW1i
ZXI9dWlkPWR1bW15CmZlZGVyYXRlZC5sZGFwLmdtLmdyb3VwTWVtYmVyTmFtZT11bmlxdWVNZW1i
ZXIKZmVkZXJhdGVkLmxkYXAuZ20ub2JqZWN0Q2xhc3M9Z3JvdXBPZlVuaXF1ZU5hbWVzCmZlZGVy
YXRlZC5sZGFwLmdtLnNjb3BlPWRpcmVjdApmZWRlcmF0ZWQubGRhcC5ob3N0PSVMREFQSE9TVE5B
TUUlCmZlZGVyYXRlZC5sZGFwLmlkPSVMREFQSE9TVE5BTUUlCmZlZGVyYXRlZC5sZGFwLmxkYXBT
ZXJ2ZXJUeXBlPUlEUzYKZmVkZXJhdGVkLmxkYXAucG9ydD0zODk="

DeleteDefaultRealmproperties="ZmVkZXJhdGVkLmRlbGV0ZS5iYXNlZW50cnk9bz1kZWZhdWx0V0lNRmlsZUJhc2VkUmVhbG0KZmVk
ZXJhdGVkLmRlbGV0ZS5pZD1JbnRlcm5hbEZpbGVSZXBvc2l0b3J5Cg=="

echo "${EnableFederatedLDAPSecuritytemplate}" | base64 -d > EnableFederatedLDAPSecurity.template
echo "${DeleteDefaultRealmproperties}" | base64 -d > DeleteDefaultRealm.properties

BASE="o=rootAdmin,dc=telmexinternacional,dc=net"

WPSBINDUSER="wpsbind"
WASUSER="wasadmin"
WPSUSER="wpsadmin"
WPSADMINS="wpsadmins"

LDAPHOSTNAME="amxqatds01.tmx-internacional.net"
WASADMINPWD="tcbfrwEdEzfwIrCyInudR"
WPSADMINPWD="cqy10vs2WV93i7dV82hZE"
WPSBINDPWD="VvvyiiSYm0iBijsFe6EHFi8zMdG"
DWASOLDPWD="wpsadmin"
TMPUSER="portalroot" # El usuario debera tener como passowrd el valor de la variable $DWASOLDPWD

sed -e "s/%BASE_DN%/$BASE/" \
    -e "s/%WPSBINDPWD%/$WPSBINDPWD/" \
    -e "s/%LDAPHOSTNAME%/$LDAPHOSTNAME/" \
    -e "s/wpsbind/${WPSBINDUSER}/" \
    EnableFederatedLDAPSecurity.template > EnableFederatedLDAPSecurity.properties

/opt/HCL/wp_profile/bin/startServer.sh WebSphere_Portal

# /opt/IBM/WebSphere/wp_profile/bin/backupConfig.sh -username wpadmin -password ${DWASOLDPWD}
/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh wp-change-portal-admin-user -DWasPassword=${DWASOLDPWD} -DnewAdminId=uid=${TMPUSER},o=defaultWIMFileBasedRealm -DnewAdminPw=${DWASOLDPWD} -DnewAdminGroupId=cn=wpsadmins,o=defaultWIMFileBasedRealm
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error change default user"
    exit $TASK_RC 
fi

/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh wp-change-was-admin-user -DnewAdminId=uid=${TMPUSER},o=defaultWIMFileBasedRealm -DnewAdminPw=${DWASOLDPWD}  -DWasPassword=${DWASOLDPWD}
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error change default user"
    exit $TASK_RC 
fi

/opt/HCL/wp_profile/bin/backupConfig.sh -username ${TMPUSER} -password ${DWASOLDPWD}
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error Backing up profile"
    exit $TASK_RC
fi
mv  WebSphereConfig_* `date "+%Y-%m-%d_%H.%M.%S"`_WebSphereConfig.zip

# /opt/IBM/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh  -DSaveParentProperties=false -DparentProperties="EnableFederatedLDAPSecurity.properties" -DWasPassword=${DWASOLDPWD} validate-federated-ldap
/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh -DSaveParentProperties=false -DparentProperties="EnableFederatedLDAPSecurity.properties" -DWasPassword=${DWASOLDPWD} validate-federated-ldap
TASK_RC=$?

if [ $TASK_RC -ne 0 ]; then
    echo "Error validating ldap"
    exit $TASK_RC 
fi
    

# /opt/IBM/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh -DSaveParentProperties=true -DparentProperties="EnableFederatedLDAPSecurity.properties" -DWasPassword=${DWASOLDPWD} wp-create-ldap
/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh -DSaveParentProperties=true -DparentProperties="EnableFederatedLDAPSecurity.properties" -DWasPassword=${DWASOLDPWD} wp-create-ldap
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error enabling ldap"
    exit $TASK_RC 
fi


# /opt/IBM/WebSphere/wp_profile/bin/startServer.sh WebSphere_Portal
/opt/HCL/wp_profile/bin/startServer.sh WebSphere_Portal

# /opt/IBM/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh wp-change-portal-admin-user -DWasPassword=${DWASOLDPWD} -DnewAdminId=uid=${WPSUSER},cn=users,${BASE} -DnewAdminPw=${WPSADMINPWD} -DnewAdminGroupId=cn=${WPSADMINS},cn=groups,${BASE}
/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh wp-change-portal-admin-user -DWasPassword=${DWASOLDPWD} -DnewAdminId=uid=${WPSUSER},cn=users,${BASE} -DnewAdminPw=${WPSADMINPWD} -DnewAdminGroupId=cn=${WPSADMINS},cn=groups,${BASE}
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error changing portal admin user"
    exit $TASK_RC 
fi
# /opt/IBM/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh wp-change-was-admin-user -DnewAdminId=uid=${WASUSER},cn=users,${BASE} -DnewAdminPw=${WASADMINPWD} -DWasPassword=${DWASOLDPWD}
/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh wp-change-was-admin-user -DnewAdminId=uid=${WASUSER},cn=users,${BASE} -DnewAdminPw=${WASADMINPWD}  -DWasPassword=${DWASOLDPWD}
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error changing app server user"
    exit $TASK_RC 
fi

/opt/HCL/wp_profile/bin/stopServer.sh WebSphere_Portal -username ${TMPUSER} -password ${DWASOLDPWD}
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error shutdown"
    exit $TASK_RC 
fi

# # /opt/IBM/WebSphere/wp_profile/ConfigEngine/ConfigEngine.sh wp-delete-repository -DSaveParentProperties=false -DparentProperties="DeleteDefaultRealm.properties" -DWasPassword=${WASADMINPWD}
/opt/HCL/wp_profile/ConfigEngine/ConfigEngine.sh wp-delete-repository -DSaveParentProperties=false -DparentProperties="DeleteDefaultRealm.properties"  -DWasPassword=${WASADMINPWD}
TASK_RC=$?
if [ $TASK_RC -ne 0 ]; then
    echo "Error removing default ldap"
    exit $TASK_RC 
fi

# # /opt/IBM/WebSphere/wp_profile/bin/startServer.sh WebSphere_Portal
/opt/HCL/wp_profile/bin/startServer.sh WebSphere_Portal