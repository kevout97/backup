#! /bin/bash

############################################################################
#                                                                          #
#                            Prosody-Jitsi                                 #
#                                                                          #
############################################################################
PROS_CONTAINER="prosody"

mkdir -p /var/containers/$PROS_CONTAINER/etc/prosody/{conf.d,certs}

cat<<-EOF > /var/containers/$PROS_CONTAINER/etc/prosody/conf.d/claroconnect.com.cfg.lua
plugin_paths = { "/prosody-plugins", "/prosody-plugins-custom" }

bosh_max_inactivity = 15;
cross_domain_bosh = true;
cross_domain_websocket = true;
consider_websocket_secure = true;
consider_bosh_secure = true;
http_default_host = "claroconnect.com"

-- | MAIN VIRTUAL HOST
-------------------------------------------------

VirtualHost "claroconnect.com"
        -- Auth type
        authentication = "anonymous"
        -- Auth data
        app_id=""
        app_secret=""
		-- Sync events data
		iam_url="https://local.claroconnect.com/iam/"
		iam_secret="Xsecret01X"
		-- Linked components
		muc_component="conference.claroconnect.com"
        waiting_muc_component = "waiting.claroconnect.com"
		speakerstats_component = "speakerstats.claroconnect.com"
        conference_duration_component = "conferenceduration.claroconnect.com"
        -- SSL data
        ssl = {
        	key = "/etc/prosody/certs/jitsi.claroconnect.com.key";
            certificate = "/etc/prosody/certs/jitsi.claroconnect.com.pem";
		}
        -- Enabled modules
        modules_enabled = {
            "bosh";
            "pubsub";
            "ping"; -- Enable mod_ping
	    	"muc_size";
	    	"muc_sync_event";
            --"speakerstats";
            --"turncredentials";
            --"conference_duration";
        }

        c2s_require_encryption = false

-- | JICOFO VIRTUAL HOST
-------------------------------------------------

VirtualHost "auth.claroconnect.com"
    ssl = {
    	key = "/etc/prosody/certs/jitsi.claroconnect.com.key";
        certificate = "/etc/prosody/certs/jitsi.claroconnect.com.pem";
    }
    authentication = "internal_plain"

-- | COMPONENT LINKING
-------------------------------------------------

-- CONFERENCE MUC 

Component "conference.claroconnect.com" "muc"
	admins = { "focus@auth.claroconnect.com" }
	modules_enabled = {
       		"muc_meeting_id";
       	 	"muc_domain_mapper";
        	-- "token_verification";
    	}
	muc_room_locking = false
	muc_room_default_public_jids = true


-- WAITING ROOM MUC 

Component "waiting.claroconnect.com" "muc"
    admins = { "focus@auth.claroconnect.com" }
    authentication = "anonymous"
    restrict_room_creation = false
    muc_room_locking = false
    muc_room_default_public_jids = true

-- FOCUS

Component "focus.claroconnect.com"
    component_secret = "xP6fgU#l"

-- INTERNAL (LOAD BALANCING) MUC

Component "internal.auth.claroconnect.com" "muc"
	admins = { "focus@auth.claroconnect.com", "jvb@auth.claroconnect.com" }
    storage = "memory"
    modules_enabled = {
      "ping";
    }
    muc_room_locking = false
    muc_room_default_public_jids = true

-- EXTRA COMPONENTS

Component "speakerstats.claroconnect.com" "speakerstats_component"
    muc_component = "conference.claroconnect.com"

Component "conferenceduration.claroconnect.com" "conference_duration_component"
    muc_component = "conference.claroconnect.com"
EOF

cat<<-EOF > /var/containers/$PROS_CONTAINER/etc/prosody/certs/jitsi.claroconnect.com.pem
-----BEGIN CERTIFICATE-----
MIIGvTCCBaWgAwIBAgIIQbCXxWZEvhQwDQYJKoZIhvcNAQELBQAwgbQxCzAJBgNV
BAYTAlVTMRAwDgYDVQQIEwdBcml6b25hMRMwEQYDVQQHEwpTY290dHNkYWxlMRow
GAYDVQQKExFHb0RhZGR5LmNvbSwgSW5jLjEtMCsGA1UECxMkaHR0cDovL2NlcnRz
LmdvZGFkZHkuY29tL3JlcG9zaXRvcnkvMTMwMQYDVQQDEypHbyBEYWRkeSBTZWN1
cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IC0gRzIwHhcNMTgxMDE2MTQyNDU1WhcN
MjAxMDE2MTQyNDU1WjBAMSEwHwYDVQQLExhEb21haW4gQ29udHJvbCBWYWxpZGF0
ZWQxGzAZBgNVBAMMEiouY2xhcm9jb25uZWN0LmNvbTCCASIwDQYJKoZIhvcNAQEB
BQADggEPADCCAQoCggEBALQq4nR0xKebXoCbczHPcO3jo+c0kmBUKW7Jj18Zo1iu
g6b2ZyOM4X/Cqv6hjS6sjpxA/LDPvCd+Tr8AE9NJCHsEsPpINYg1qop8kx1jXum5
E/GX5cpACF37ebeHEBRM78SWBCU17SulxOSuhLtEIB0porM+hoa086ltq1NTXjVZ
eeWpytOeCeqRX5IBRzlCHqCPHTbDbk7b5gE6i4NmUQzxwWoE77cjtlmplpFhdvdK
/pi2zZIMhrp/rBmp0vtRhzku63EXt8pQv6QAd2H2oRWLr6aEPwieoX+cvclfh5fo
QF9+cC4aEOscMkAeO32dxnYtlzNj1Hy9k+mZcA0cn78CAwEAAaOCA0QwggNAMAwG
A1UdEwEB/wQCMAAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMA4GA1Ud
DwEB/wQEAwIFoDA3BgNVHR8EMDAuMCygKqAohiZodHRwOi8vY3JsLmdvZGFkZHku
Y29tL2dkaWcyczEtODc4LmNybDBdBgNVHSAEVjBUMEgGC2CGSAGG/W0BBxcBMDkw
NwYIKwYBBQUHAgEWK2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuZ29kYWRkeS5jb20vcmVw
b3NpdG9yeS8wCAYGZ4EMAQIBMHYGCCsGAQUFBwEBBGowaDAkBggrBgEFBQcwAYYY
aHR0cDovL29jc3AuZ29kYWRkeS5jb20vMEAGCCsGAQUFBzAChjRodHRwOi8vY2Vy
dGlmaWNhdGVzLmdvZGFkZHkuY29tL3JlcG9zaXRvcnkvZ2RpZzIuY3J0MB8GA1Ud
IwQYMBaAFEDCvSeOzDSDMKIz1/tss/C0LIDOMC8GA1UdEQQoMCaCEiouY2xhcm9j
b25uZWN0LmNvbYIQY2xhcm9jb25uZWN0LmNvbTAdBgNVHQ4EFgQUJVJhfxXnpIed
Dsa+grPfNqVN8h8wggF+BgorBgEEAdZ5AgQCBIIBbgSCAWoBaAB2AKS5CZC0GFgU
h7sTosxncAo8NZgE+RvfuON3zQ7IDdwQAAABZn1D73AAAAQDAEcwRQIgDapxKUop
ySIO2uIt7pR1Xbln5vditedfhVwnckBrR0wCIQD9jBAwssFfsaM7BrYyQgoOC7Jp
wg15B33HDYvCU0CuKQB2AO5Lvbd1zmC64UJpH6vhnmajD35fsHLYgwDEe4l6qP3L
AAABZn1D9WoAAAQDAEcwRQIgBHTvljk4441WDVRImFABsnKu5Vgc/S/E0gTyeKhx
f6YCIQCcHAOQTAR7lUHytcM+UYtcwn5o1TJAQCEef0s8llIUzQB2AF6nc/nfVsDn
tTZIfdBJ4DJ6kZoMhKESEoQYdZaBcUVYAAABZn1D9kwAAAQDAEcwRQIhAKZ8GAbh
ln4F0MmhUXJYR3/MBfJgSyhxkSiBOtp2xsWdAiBgmbWDtNdnQrpBafHiy/m9R233
P6/CCfJ9WKpik1M/3TANBgkqhkiG9w0BAQsFAAOCAQEATYVlE1xWCszM2Na6pJw/
FpsA5ecRj37sHucZWu6u7jQtpbwLWUTbj6WBEvQcNfLwNbjEwFYGCR87XU11rjzq
wV9noFCmwURyKi6vStoiqIAXYAHjVJ2Bfqm/45kmzd876WJNkvGYvEDdmI6GzOpm
S39E70Nr65BlI9fveNwb7rDtEUHIASK+LnLCUHPIguPM03OaP3sJf974XsK+MkJD
9V9dIHdr5vLdmj5NDSQqRsldWeVA74UBYNwILCRVrmrsf7i2JCtSvvRTZXm2r8u3
rr7H1fr1Iu/3DDMRzZ1HJmkjTvtG2rwBtiM3QJEt0VsUpazY4YP/rnNfhjONe7AP
2g==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIE0DCCA7igAwIBAgIBBzANBgkqhkiG9w0BAQsFADCBgzELMAkGA1UEBhMCVVMx
EDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNjb3R0c2RhbGUxGjAYBgNVBAoT
EUdvRGFkZHkuY29tLCBJbmMuMTEwLwYDVQQDEyhHbyBEYWRkeSBSb290IENlcnRp
ZmljYXRlIEF1dGhvcml0eSAtIEcyMB4XDTExMDUwMzA3MDAwMFoXDTMxMDUwMzA3
MDAwMFowgbQxCzAJBgNVBAYTAlVTMRAwDgYDVQQIEwdBcml6b25hMRMwEQYDVQQH
EwpTY290dHNkYWxlMRowGAYDVQQKExFHb0RhZGR5LmNvbSwgSW5jLjEtMCsGA1UE
CxMkaHR0cDovL2NlcnRzLmdvZGFkZHkuY29tL3JlcG9zaXRvcnkvMTMwMQYDVQQD
EypHbyBEYWRkeSBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IC0gRzIwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC54MsQ1K92vdSTYuswZLiBCGzD
BNliF44v/z5lz4/OYuY8UhzaFkVLVat4a2ODYpDOD2lsmcgaFItMzEUz6ojcnqOv
K/6AYZ15V8TPLvQ/MDxdR/yaFrzDN5ZBUY4RS1T4KL7QjL7wMDge87Am+GZHY23e
cSZHjzhHU9FGHbTj3ADqRay9vHHZqm8A29vNMDp5T19MR/gd71vCxJ1gO7GyQ5HY
pDNO6rPWJ0+tJYqlxvTV0KaudAVkV4i1RFXULSo6Pvi4vekyCgKUZMQWOlDxSq7n
eTOvDCAHf+jfBDnCaQJsY1L6d8EbyHSHyLmTGFBUNUtpTrw700kuH9zB0lL7AgMB
AAGjggEaMIIBFjAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNV
HQ4EFgQUQMK9J47MNIMwojPX+2yz8LQsgM4wHwYDVR0jBBgwFoAUOpqFBxBnKLbv
9r0FQW4gwZTaD94wNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8v
b2NzcC5nb2RhZGR5LmNvbS8wNQYDVR0fBC4wLDAqoCigJoYkaHR0cDovL2NybC5n
b2RhZGR5LmNvbS9nZHJvb3QtZzIuY3JsMEYGA1UdIAQ/MD0wOwYEVR0gADAzMDEG
CCsGAQUFBwIBFiVodHRwczovL2NlcnRzLmdvZGFkZHkuY29tL3JlcG9zaXRvcnkv
MA0GCSqGSIb3DQEBCwUAA4IBAQAIfmyTEMg4uJapkEv/oV9PBO9sPpyIBslQj6Zz
91cxG7685C/b+LrTW+C05+Z5Yg4MotdqY3MxtfWoSKQ7CC2iXZDXtHwlTxFWMMS2
RJ17LJ3lXubvDGGqv+QqG+6EnriDfcFDzkSnE3ANkR/0yBOtg2DZ2HKocyQetawi
DsoXiWJYRBuriSUBAA/NxBti21G00w9RKpv0vHP8ds42pM3Z2Czqrpv1KrKQ0U11
GIo/ikGQI31bS/6kA1ibRrLDYGCD+H1QQc7CoZDDu+8CL9IVVO5EFdkKrqeKM+2x
LXY2JtwE65/3YR8V3Idv7kaWKK2hJn0KCacuBKONvPi8BDAB
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEfTCCA2WgAwIBAgIDG+cVMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVT
MSEwHwYDVQQKExhUaGUgR28gRGFkZHkgR3JvdXAsIEluYy4xMTAvBgNVBAsTKEdv
IERhZGR5IENsYXNzIDIgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTQwMTAx
MDcwMDAwWhcNMzEwNTMwMDcwMDAwWjCBgzELMAkGA1UEBhMCVVMxEDAOBgNVBAgT
B0FyaXpvbmExEzARBgNVBAcTClNjb3R0c2RhbGUxGjAYBgNVBAoTEUdvRGFkZHku
Y29tLCBJbmMuMTEwLwYDVQQDEyhHbyBEYWRkeSBSb290IENlcnRpZmljYXRlIEF1
dGhvcml0eSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv3Fi
CPH6WTT3G8kYo/eASVjpIoMTpsUgQwE7hPHmhUmfJ+r2hBtOoLTbcJjHMgGxBT4H
Tu70+k8vWTAi56sZVmvigAf88xZ1gDlRe+X5NbZ0TqmNghPktj+pA4P6or6KFWp/
3gvDthkUBcrqw6gElDtGfDIN8wBmIsiNaW02jBEYt9OyHGC0OPoCjM7T3UYH3go+
6118yHz7sCtTpJJiaVElBWEaRIGMLKlDliPfrDqBmg4pxRyp6V0etp6eMAo5zvGI
gPtLXcwy7IViQyU0AlYnAZG0O3AqP26x6JyIAX2f1PnbU21gnb8s51iruF9G/M7E
GwM8CetJMVxpRrPgRwIDAQABo4IBFzCCARMwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFDqahQcQZyi27/a9BUFuIMGU2g/eMB8GA1Ud
IwQYMBaAFNLEsNKR1EwRcbNhyz2h/t2oatTjMDQGCCsGAQUFBwEBBCgwJjAkBggr
BgEFBQcwAYYYaHR0cDovL29jc3AuZ29kYWRkeS5jb20vMDIGA1UdHwQrMCkwJ6Al
oCOGIWh0dHA6Ly9jcmwuZ29kYWRkeS5jb20vZ2Ryb290LmNybDBGBgNVHSAEPzA9
MDsGBFUdIAAwMzAxBggrBgEFBQcCARYlaHR0cHM6Ly9jZXJ0cy5nb2RhZGR5LmNv
bS9yZXBvc2l0b3J5LzANBgkqhkiG9w0BAQsFAAOCAQEAWQtTvZKGEacke+1bMc8d
H2xwxbhuvk679r6XUOEwf7ooXGKUwuN+M/f7QnaF25UcjCJYdQkMiGVnOQoWCcWg
OJekxSOTP7QYpgEGRJHjp2kntFolfzq3Ms3dhP8qOCkzpN1nsoX+oYggHFCJyNwq
9kIDN0zmiN/VryTyscPfzLXs4Jlet0lUIDyUGAzHHFIYSaRt4bNYC8nY7NmuHDKO
KHAN4v6mF56ED71XcLNa6R+ghlO773z/aQvgSMO3kwvIClTErF0UZzdsyqUvMQg3
qm5vjLyb4lddJIGvl5echK1srDdMZvNhkREg5L4wn3qkKQmw4TRfZHcYQFHfjDCm
rw==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEADCCAuigAwIBAgIBADANBgkqhkiG9w0BAQUFADBjMQswCQYDVQQGEwJVUzEh
MB8GA1UEChMYVGhlIEdvIERhZGR5IEdyb3VwLCBJbmMuMTEwLwYDVQQLEyhHbyBE
YWRkeSBDbGFzcyAyIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTA0MDYyOTE3
MDYyMFoXDTM0MDYyOTE3MDYyMFowYzELMAkGA1UEBhMCVVMxITAfBgNVBAoTGFRo
ZSBHbyBEYWRkeSBHcm91cCwgSW5jLjExMC8GA1UECxMoR28gRGFkZHkgQ2xhc3Mg
MiBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTCCASAwDQYJKoZIhvcNAQEBBQADggEN
ADCCAQgCggEBAN6d1+pXGEmhW+vXX0iG6r7d/+TvZxz0ZWizV3GgXne77ZtJ6XCA
PVYYYwhv2vLM0D9/AlQiVBDYsoHUwHU9S3/Hd8M+eKsaA7Ugay9qK7HFiH7Eux6w
wdhFJ2+qN1j3hybX2C32qRe3H3I2TqYXP2WYktsqbl2i/ojgC95/5Y0V4evLOtXi
EqITLdiOr18SPaAIBQi2XKVlOARFmR6jYGB0xUGlcmIbYsUfb18aQr4CUWWoriMY
avx4A6lNf4DD+qta/KFApMoZFv6yyO9ecw3ud72a9nmYvLEHZ6IVDd2gWMZEewo+
YihfukEHU1jPEX44dMX4/7VpkI+EdOqXG68CAQOjgcAwgb0wHQYDVR0OBBYEFNLE
sNKR1EwRcbNhyz2h/t2oatTjMIGNBgNVHSMEgYUwgYKAFNLEsNKR1EwRcbNhyz2h
/t2oatTjoWekZTBjMQswCQYDVQQGEwJVUzEhMB8GA1UEChMYVGhlIEdvIERhZGR5
IEdyb3VwLCBJbmMuMTEwLwYDVQQLEyhHbyBEYWRkeSBDbGFzcyAyIENlcnRpZmlj
YXRpb24gQXV0aG9yaXR5ggEAMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQAD
ggEBADJL87LKPpH8EsahB4yOd6AzBhRckB4Y9wimPQoZ+YeAEW5p5JYXMP80kWNy
OO7MHAGjHZQopDH2esRU1/blMVgDoszOYtuURXO1v0XJJLXVggKtI3lpjbi2Tc7P
TMozI+gciKqdi0FuFskg5YmezTvacPd+mSYgFFQlq25zheabIZ0KbIIOqPjCDPoQ
HmyW74cNxA9hi63ugyuV+I6ShHI56yDqg+2DzZduCLzrTia2cyvk0/ZM/iZx4mER
dEr/VxqHD3VILs9RaRegAhJhldXRQLIQTO7ErBBDpqWeCtWVYpoNz4iCxTIM5Cuf
ReYNnyicsbkqWletNw+vHX/bvZ8=
-----END CERTIFICATE-----
EOF

cat<<-EOF > /var/containers/$PROS_CONTAINER/etc/prosody/certs/jitsi.claroconnect.com.key
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAtCridHTEp5tegJtzMc9w7eOj5zSSYFQpbsmPXxmjWK6DpvZn
I4zhf8Kq/qGNLqyOnED8sM+8J35OvwAT00kIewSw+kg1iDWqinyTHWNe6bkT8Zfl
ykAIXft5t4cQFEzvxJYEJTXtK6XE5K6Eu0QgHSmisz6GhrTzqW2rU1NeNVl55anK
054J6pFfkgFHOUIeoI8dNsNuTtvmATqLg2ZRDPHBagTvtyO2WamWkWF290r+mLbN
kgyGun+sGanS+1GHOS7rcRe3ylC/pAB3YfahFYuvpoQ/CJ6hf5y9yV+Hl+hAX35w
LhoQ6xwyQB47fZ3Gdi2XM2PUfL2T6ZlwDRyfvwIDAQABAoIBAQCy4jmCA0YWXC9S
ZgXUGPE5YWIld482UZnpw/q0I9KJhIx2xAPXylNC9NeuhlyVUQMvpV6/dyKL2973
yW3lxIfFDP1jIzrziMVRRysSbM2aJgblQzoGu9kS51MMo++VGGafu4tWHtrjEW4S
2Cw1ewifq+09JwGO0i9zs839p7LMJ+UeEu/Yvt6eTJMRNuYOLq/B8zGpLtiJdsTF
W8kHQqGKRJAVzC6ET0L8PTSlasNgAZLbkYJ2Y2m+Jp1/0OoqAiZcS+sNJH3/tgZl
NrSyh9SJ3D5kLMPaKHbg6FgireyPzw3MneXnxdm5Ma7khF1EPWWXpOX3XozKxqf7
EsT78GVBAoGBAOgMj4nBLH4AGCLEcOo0al5r9/ouv5fpzeMwmY/Q30l5s6aQDb2z
g0C7H5KnYnvwEJgIVwrJhWt2G39ok2hRLOFbsEYX34V+QF0YpiUQSbefh4Fgw71R
IJfIpA3f6V5Woi+0Xsm59jtk8IeV8QHniLf2KqeaYEj+n0TSVtQ4v9IPAoGBAMbD
dMv3l/R3nvoiatt59DAHgh8qmkqMLeysMht7VukvBZGVvLtG/1D+XkNi6a11Qb0O
rU3n4Et8miNFgizWrWZtkqJixAeyUH0ggLhOFdlpG+cz9vjVZik28GfLKPFz9rih
MeEdP+ki02vxzlscgRVPXeWQe3+vTGI0UsMtR0dRAoGAb9Zt77ScnvWorEkFKrus
cGmVEI0rZioXQuIPgNLoat8vCJ3xIXa9UZteMi5eNuGS/dM3MEnD9fDse9GJCgPl
n4+zO3USE6Kvnq7clIxvGwLWKjLa5AmPrdfTyaQbM46JiHhkHtFzrViO3KoViBdx
O0h3cmPi+AtP87l0g7/+I10CgYBK90FABLxNOii90ulWqiKNUuei9aCH6WMQ1sl3
UAexn0iMZltujxKQ67+FzvKvt3/53GVE8uXH0tEX6Il2e+merkkV8gZZmMl+yBmE
af8XpusdQp4tr97+QHhfzWI93yz46eM0MqH+PmJbXjIkbxXIgcy6XsoVmHpIt89X
SeaOYQKBgDvpoRXFcGKMdHDRrRJ01GjRLzxNIYCOXQlocvpiH+jPpLH3NlIjdz2n
T5kL956pMluT9mGs5bvxwfYDHKQ+Rl+JV8RMt0y/w/pFY2PToiXXBVZ4lIjRuGV4
QVx+BVYNHy5EssYFGvjK7+rMGfQ9J6K/i1zxrrzMWldJxlIRuKeL
-----END RSA PRIVATE KEY-----

EOF

chown 101:0 -R /var/containers/$PROS_CONTAINER

docker run -td --name $PROS_CONTAINER \
    -p 5347:5347 \
    -p 5222:5222 \
    -p 5280:5280 \
    -v /var/containers/$PROS_CONTAINER/etc/prosody/conf.d/claroconnect.com.cfg.lua:/etc/prosody/conf.d/claroconnect.com.cfg.lua:z \
    -v /var/containers/$PROS_CONTAINER/etc/prosody/certs/jitsi.claroconnect.com.pem:/etc/prosody/certs/jitsi.claroconnect.com.pem:z \
    -v /var/containers/$PROS_CONTAINER/etc/prosody/certs/jitsi.claroconnect.com.key:/etc/prosody/certs/jitsi.claroconnect.com.key:z \
    -v /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
    -e "TZ=America/Mexico_City" \
    nexus-admin.videoconferenciaclaro.com/prosody