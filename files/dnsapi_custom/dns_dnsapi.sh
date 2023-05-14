#!/usr/bin/env sh

if [ -z "$DNSAPI_SERVERS" ];
then
    _err 'The $DNAPI_SERVERS variable is empty'
    return 1
fi

if [ -z "$DNSAPI_AUTH_TOKEN" ];
then
    _err 'The $DNSAPI_AUTH_TOKEN variable is empty'
    return 1
fi

########  Public functions #####################

#Usage: dns_myapi_add   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_dnsapi_add() {
  fulldomain=$1
  txtvalue=$2
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"

  DNSAPI_AUTH_TOKEN="${DNSAPI_AUTH_TOKEN:-$(_readaccountconf_mutable DNSAPI_AUTH_TOKEN)}"
  DNSAPI_SERVERS="${DNSAPI_SERVERS:-$(_readaccountconf_mutable DNSAPI_SERVERS)}"

  _saveaccountconf_mutable DNSAPI_AUTH_TOKEN "$DNSAPI_AUTH_TOKEN"
  _saveaccountconf_mutable DNSAPI_SERVERS "$DNSAPI_SERVERS"

  export _H1="X-Auth_Token: $DNSAPI_AUTH_TOKEN"
  export _H2="Content-Type: application/json"

  IFS=',' read -ra DNSAPI_SERVERS <<< "$DNSAPI_SERVERS"

  for server in "${DNSAPI_SERVERS[@]}";
  do
    url="$server/acme"
    _debug url "$url"

    response="$(_post "{\"domain\":\"$domain\",\"token\":\"$txtvalue\"}" "$url" "" "POST")"
    _debug response "$response"

    if [ "$?" != "0" ]; then
      _err "error $response"
      return 1
    fi

  done

  return 0
}

#Usage: fulldomain txtvalue
#Remove the txt record after validation.
dns_dnsapi_rm() {
  fulldomain=$1
  txtvalue=$2
  _info "Using dnsapi"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
  _info "No need to remove the TXT for dnsapi, skipping..."
  return 0
}

####################  Private functions below ##################################
