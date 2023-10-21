#!/bin/bash
set -euo pipefail
# see https://github.com/dehydrated-io/dehydrated/blob/master/docs/examples/hook.sh

# Cloudflare API documentation:
# - https://api.cloudflare.com/#zone-list-zones
# - https://api.cloudflare.com/#dns-records-for-a-zone-properties
: "${CLOUDFLARE_API:=https://api.cloudflare.com/client/v4}"

# exit the program with an error message
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# send a request to the Clouflare API (using curl)
cloudflare() {
  [[ -n "$CLOUDFLARE_TOKEN" ]] || die "The CLOUDFLARE_TOKEN variable is missing or empty"
  curl -sSL \
  --header "Authorization: Bearer $CLOUDFLARE_TOKEN" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  "$CLOUDFLARE_API/$*"
}

# create a ACME challenge DNS-01 record in the Cloudflare zone matching the domain name passed as first parameter
create_dns_challenge_record() {
  # remove leading '*.' from the domain if any
  local domain="${1#\*.}" token="${2}" zone_id zone_name
  local record_name="_acme-challenge.$domain"

  # find the zone matching the domain provided as first parameter
  read -r zone_id zone_name < <(
    cloudflare "zones" | jq -r -e --arg domain "$domain" '
    .result
    | map(
      .name as $name
      | select($domain | endswith($name))
      | [.id, $name]
    )
    | max_by(.[1])
    | join(" ")
    '
  )

  # die "No zone found for $domain in this Cloudflare account"
  echo "Zone id: $zone_id"
  echo "Zone name: $zone_name"
  echo "Record name: $record_name"
  echo "Token: $token"
}

deploy_challenge() {
  local DOMAIN="${1}" TOKEN_VALUE="${3}"
  # TOKEN_FILENAME="${2}"
  echo "Deploying challenge for $DOMAIN"
  create_dns_challenge_record "$DOMAIN" "$TOKEN_VALUE"
}

clean_challenge() {
  local DOMAIN="${1}"
  # TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
  echo "Cleaning challenge for $DOMAIN"
}

sync_cert() {
  :
  # local KEYFILE="${1}" CERTFILE="${2}" FULLCHAINFILE="${3}" CHAINFILE="${4}" REQUESTFILE="${5}"

  # This hook is called after the certificates have been created but before
  # they are symlinked. This allows you to sync the files to disk to prevent
  # creating a symlink to empty files on unexpected system crashes.
  #
  # This hook is not intended to be used for further processing of certificate
  # files, see deploy_cert for that.
  #
  # Parameters:
  # - KEYFILE
  #   The path of the file containing the private key.
  # - CERTFILE
  #   The path of the file containing the signed certificate.
  # - FULLCHAINFILE
  #   The path of the file containing the full certificate chain.
  # - CHAINFILE
  #   The path of the file containing the intermediate certificate(s).
  # - REQUESTFILE
  #   The path of the file containing the certificate signing request.

  # Simple example: sync the files before symlinking them
  # sync "${KEYFILE}" "${CERTFILE}" "${FULLCHAINFILE}" "${CHAINFILE}" "${REQUESTFILE}"
}

deploy_cert() {
  :
  # local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"

  # This hook is called once for each certificate that has been
  # produced. Here you might, for instance, copy your new certificates
  # to service-specific locations and reload the service.
  #
  # Parameters:
  # - DOMAIN
  #   The primary domain name, i.e. the certificate common
  #   name (CN).
  # - KEYFILE
  #   The path of the file containing the private key.
  # - CERTFILE
  #   The path of the file containing the signed certificate.
  # - FULLCHAINFILE
  #   The path of the file containing the full certificate chain.
  # - CHAINFILE
  #   The path of the file containing the intermediate certificate(s).
  # - TIMESTAMP
  #   Timestamp when the specified certificate was created.

  # Simple example: Copy file to nginx config
  # cp "${KEYFILE}" "${FULLCHAINFILE}" /etc/nginx/ssl/; chown -R nginx: /etc/nginx/ssl
  # systemctl reload nginx
}

deploy_ocsp() {
  :
  # local DOMAIN="${1}" OCSPFILE="${2}" TIMESTAMP="${3}"

  # This hook is called once for each updated ocsp stapling file that has
  # been produced. Here you might, for instance, copy your new ocsp stapling
  # files to service-specific locations and reload the service.
  #
  # Parameters:
  # - DOMAIN
  #   The primary domain name, i.e. the certificate common
  #   name (CN).
  # - OCSPFILE
  #   The path of the ocsp stapling file
  # - TIMESTAMP
  #   Timestamp when the specified ocsp stapling file was created.

  # Simple example: Copy file to nginx config
  # cp "${OCSPFILE}" /etc/nginx/ssl/; chown -R nginx: /etc/nginx/ssl
  # systemctl reload nginx
}

unchanged_cert() {
  local DOMAIN="${1}"
  # KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
  echo "Certificate is still valid for $DOMAIN"
  # This hook is called once for each certificate that is still
  # valid and therefore wasn't reissued.
  #
  # Parameters:
  # - DOMAIN
  #   The primary domain name, i.e. the certificate common
  #   name (CN).
  # - KEYFILE
  #   The path of the file containing the private key.
  # - CERTFILE
  #   The path of the file containing the signed certificate.
  # - FULLCHAINFILE
  #   The path of the file containing the full certificate chain.
  # - CHAINFILE
  #   The path of the file containing the intermediate certificate(s).
}

invalid_challenge() {
  :
  # local DOMAIN="${1}" RESPONSE="${2}"

  # This hook is called if the challenge response has failed, so domain
  # owners can be aware and act accordingly.
  #
  # Parameters:
  # - DOMAIN
  #   The primary domain name, i.e. the certificate common
  #   name (CN).
  # - RESPONSE
  #   The response that the verification server returned

  # Simple example: Send mail to root
  # printf "Subject: Validation of ${DOMAIN} failed!\n\nOh noez!" | sendmail root
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|sync_cert|deploy_cert|deploy_ocsp|unchanged_cert|invalid_challenge)$ ]]; then
  "$HANDLER" "$@"
fi
