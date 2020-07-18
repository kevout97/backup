#!/bin/bash

curl -s -X GET "https://zap.san.gadt.amxdigital.net/JSON/alert/action/deleteAllAlerts/?"
curl -X GET "https://zap.san.gadt.amxdigital.net/JSON/importurls/action/importurls/?filePath=/opt/owasp-zaproxy/files/endpoints.txt"
curl -X GET "https://zap.san.gadt.amxdigital.net/JSON/openapi/action/importFile/?file=/opt/owasp-zaproxy/files/t1pagos_openapi_alpha_v1.yaml&target="
curl -X GET "https://zap.san.gadt.amxdigital.net/JSON/core/view/messages/?baseurl=&start=&count=" -o salida.json
curl -X GET "https://zap.san.gadt.amxdigital.net/JSON/alert/view/alerts/?baseurl=&start=&count=&riskId=" -o alertas.json