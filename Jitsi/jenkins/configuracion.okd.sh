#!/bin/bash
##################################################
#                                                #
#           Integracion Jenkins con OKD          #
#                                                #
##################################################

# En OKD
## Llevamos a cabo el despliegue de Jenkins con el template que ofrece OKD

# En Jenkins
## 

# En Okd
## Crear un proyecto dedicado para los despliegues de Jenkins
oc login -u system:admin
oc new-project builder-jenkins

## Crear una cuenta se servicio para jenkins
oc create serviceaccount jenkins-deploy
## Le otorgamos el acceso a todo (en ese proyecto)
oc adm policy add-cluster-role-to-user edit system:serviceaccount:builder-jenkins:jenkins-deploy
oc adm policy add-cluster-role-to-user edit system:serviceaccount:jitsijenkins:jenkins
## Obtenemos el token del sa que acabamos de crear
oc serviceaccounts get-token jenkins-deploy -n builder-jenkins

eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJidWlsZGVyLWplbmtpbnMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiamVua2lucy1kZXBsb3ktdG9rZW4tZm1qMmwiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiamVua2lucy1kZXBsb3kiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIxNzE2NmZhYi1iN2U1LTExZWEtOTE3YS0wMDUwNTYwMTBkMjMiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6YnVpbGRlci1qZW5raW5zOmplbmtpbnMtZGVwbG95In0.A-NlyhPTbPJr76lo3IxHM7HkhupUmwKU00KFEbvdnV2Wg9SXz0R8q2qW1_ZFmcXonCS1j-pGZxSnnLfrNg8Tc85wPKjyZhhO5JwiqavJfPKxxNPf_IjdTAi5cPrAMPciGaEmznSL7h_35LPUR5ZSBYPHWIWB_zr_T5vs1Gn6zuMmhBV-UpAterlbWkTWCQMFeW55QqfDOPlspvV3r1gLSbcThdF_hhwJPiCcG_G0Cf3BoOEtpkZ3stUlogewC9W7RZHYKJd6yhtZ9pg7H4ci6qVoHvPeQ7_P5OUcBFhE2Muq5efbblYvcjnSiJ5p_bb0od46iMEMaM_nLb0RCu8diA

# En Jenkins
## Instalamos el plugin de Kubernetes
## En la configuración, creamos una nueva nube
### Configuramos lo siguiente
    # Name: kubernetes
    # Kubernetes URL: https://172.26.90.145:8443 Apuntamos al API (alguno de los balanceadores)
    # Disable https certificate check: Checked
    # Kubernetes Namespace: builder-jenkins (El proyecto que creamos para Jenkins)
    # Jenkins URL: http://192.168.0.100:8080 (Url de Jenkins )
    # Jenkins tunnel: 192.168.0.100:50000 (Url de jenkins y el puerto del tunel)

    # Credentials
    #     Hit Add -> Jenkins
    #     Kind: Secret text
    #     Scope: Global
    #     ID: jenkins-sa
    #     Secret: (token que obtuvimos)
    # Hit Add and then Test Connection
    # You must see the message: Test Connection

    # Kubernetes Pod Template
    #     Name: jenkins-deploy (Nombre del pod)
    #     Namespace: builder-jenkins
    #     Labels: jenkins-okd
    #     Container Template
    #     Hit Add Container -> Container Template
    #     Name: jnlp
    #     Docker image: quay.io/openshift/origin-jenkins-agent-maven
    #     Always push image: Checked
    #     Working directory: /tmp
    #     Command to run: <EMPTY>
    #     Arguments to pass to the command: ${computer.jnlpmac} ${computer.name}
    #     Allocate pseudo-TTY: Unchecked

oc create secret generic dockerhub \
    --from-file=.dockerconfigjson=.docker/config.json \
    --type=kubernetes.io/dockerconfigjson