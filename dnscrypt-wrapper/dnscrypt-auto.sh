#!/bin/sh

# Thanks to
# https://github.com/jedisct1
# https://github.com/cofyc/dnscrypt-wrapper
# https://github.com/DNSCrypt/dnscrypt-server-docker

#
#
# ./dnscrypt-wrapper/dnscrypt-autokey-mini.sh --init dns.seby.io 127.0.0.1 /opt/dnscrypt
#  ./dnscrypt-wrapper/dnscrypt-autokey-mini.sh --start
#
set -e
set -u

# Add colour to terminals that support it
colour_support=true
tput sgr0 >/dev/null 2>&1 || colour_support=false
tput setaf 2 >/dev/null 2>&1 || colour_support=false

if $colour_support; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    CLEAR=$(tput sgr0)
    tput sgr0
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    CLEAR=""
fi

# Check if command is installed
check_requirment() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "'$1' not found!"
        exit 1
    fi
}

check_requirment dnscrypt-wrapper
check_requirment sed
check_requirment awk

needsudo=
if [ "$(uname)" = "Darwin" ]; then
    # echo "I'm on a mac and need sudo permissions :'("
    if [ ! "$(dscl . read /Users/_dnscrypt-wrapper)" ]; then
        echo "creating _dnscrypt-wrapper user"
        userid="$(($(dscl . -list /Users UniqueID | sort -nr -k 2 | head -1 | awk '{print $2}')+10))"
        sudo dscl . -create /Users/_dnscrypt-wrapper
        sudo dscl . -create /Users/_dnscrypt-wrapper UserShell /usr/bin/false
        sudo dscl . -create /Users/_dnscrypt-wrapper NFSHomeDirectory /var/empty
        sudo dscl . -create /Users/_dnscrypt-wrapper PrimaryGroupID $userid
        sudo dscl . -create /Users/_dnscrypt-wrapper UniqueID $userid
    fi
    # USER=nobody
    # USER=_dnscrypt-wrapper
    needsudo=sudo
fi

# test that the server is working:
# drill -DQ NS . @127.0.0.1

get_realpath() {
    if command -v realpath > /dev/null 2>&1; then
        realpath "$1"
    else
        readlink -f "$1"
    fi
}

# Print help
usage() {
    printf 'DNSCrypt Easy Key Management\n'
    printf '\n'
    printf 'Usage: ./dnscrypt-key.sh -c [config file] [options]\n'
    printf '  -h, --help, help                                                   This help message\n'
    # printf '  -k, --keys, keys <file-path>                                      File-path to store keys and save config file (default: /opt/dnscrypt)\n'
    printf '  -t, --init, init <provider-name> <external-address> [key-path]                        Create provider key pair\n'
    printf '  -st, --start, start [resolver-address:port] [listen-address:port]  Start dnscrypt-wrapper daemon\n'
    printf '  -s, --status, status                                               Show keys/cert expiration and other status info\n'
    printf '  -r, --renew, renew                                                 Renew key and certificate\n'
    # printf '  -a   --auto              auto              Automatically run appropriate action/command\n'
    # printf '  -spk --show-public-key   show-public-key   Show the provider public key\n'
    # printf '  -n   --new [file name]   new [file name]   Create short lived key and certificate (default: current timestamp)\n'
    # printf '  -r   --renew             renew             Renew key and certificate\n'
    # printf '  -d   --delete-expired    delete-expired    Delete expired certs and keys\n'
    # printf '  -p   --proxy             proxy             Start local dnscrypt proxy\n'
    # printf '  -w   --wrapper [port]    wrapper [port]    Start dnscrypt wrapper on a specific port (default: 443)\n'
    # printf '  -ws  --wrappers          wrappers          Start dnscrypt wrappers on all ports set in the config file\n'
    printf '  -u, --update, update                                              Update this script\n'
    printf '\n'
}

# Search and Load config file
load_conf() {
    # Make sure config is only loaded once
    if [ -z ${conf_loaded+x} ] || [ "$conf_loaded" -ne 1 ]; then
        conf_loaded=1

        # check for CONFIG vaiable. Set a sane default if not set
        if [ ! -z ${CONFIG+x} ]; then
            read_conf "$CONFIG"
        else
            search_paths="$(dirname "$0") /opt/dnscrypt /usr/local/etc /etc"
            for path in $search_paths; do
                # Check that the config file exists
                if [ -f "$path/dnscrypt-autokey.conf" ]; then
                    found=1
                    read_conf "$path/dnscrypt-autokey.conf"
                    return
                fi
            done

            if [ -z ${found+x} ] || [ $found -ne 1 ]; then
                echo "No config file found! loading defaults" >&2
                read_conf
                # exit 1
            fi
        fi
    fi
}

# Read and set config variables
read_conf() {
    # Check that the config file exists
    if [ ! -z ${1+x} ] && [ -f "$1"/dnscrypt-autokey.conf ]; then
        # Load the config file as a shell script
        # shellcheck disable=SC1090
        . "$1"/dnscrypt-autokey.conf # Only load config files you trust!
        KEY_DIR=${KEY_DIR:-"$(get_realpath "$1")"}
    fi

    KEY_DIR=${KEY_DIR:-"/opt/dnscrypt"}
    USER=${USER:-"_dnscrypt-wrapper"}
    # Load variables from the config file with sane default values
    # CONFIG=${CONFIG:-"$KEY_DIR/dnscrypt-autokey.conf"}
    VALIDITY_PERIOD=${VALIDITY_PERIOD:-1} # in days
    TIME=$((60 * 24 * VALIDITY_PERIOD)) # temp vaiable (don't save to file)
    CHACHA20=${CHACHA20:-1}

    PROVIDER_NAME=${PROVIDER_NAME:-} # 2.dnscrypt-cert.example.com
    EXTERNAL=${EXTERNAL:-} # external address (address clients use to connect to the server)
    # MODE=${MODE:-""} # unbound, wrapper

    CUSTOM_FLAGS=${CUSTOM_FLAGS:-} # --dnssec, --nofilter, --nolog
    LISTEN=${LISTEN:-"0.0.0.0:443"} # address and port the daemon should bind to
    RESOLVER=${RESOLVER:-"9.9.9.9:53"} # the resolver address and port to forward requests to (e.g. to an unbound or bind instance)
    # UNBOUND_CONTROL=${UNBOUND_CONTROL:-"unbound-control"}

    # Read the dnscrypt provider name from unbound's config.
    # if [ ! -z ${MODE+x} ] && [ "$MODE" = "unbound" ];  then
    #     PROVIDER_NAME=${PROVIDER_NAME:-"$($UNBOUND_CONTROL get_option dnscrypt-provider)"}
    # fi

    script_file_path="$(get_realpath "$0")"

    # else
    #     echo "Config file '$1/dnscrypt-autokey.conf' doesn't exist" >&2
    #     exit 1
    # fi
}

save_conf() {
    # create KEYS_DIR if it dosn't exist
    if [ ! -d "$KEY_DIR" ]; then
        mkdir -p "$KEY_DIR"
    fi

    cat > "$KEY_DIR/dnscrypt-autokey.conf" << EOF
USER=$USER
VALIDITY_PERIOD=$VALIDITY_PERIOD
CHACHA20=$CHACHA20
PROVIDER_NAME=$PROVIDER_NAME
EXTERNAL=$EXTERNAL
CUSTOM_FLAGS=$CUSTOM_FLAGS
RESOLVER=$RESOLVER
LISTEN=$LISTEN
EOF
    echo 'Saved settings'
}

# returns 1 (true) if no key or cert (in the short term key directory) has been modified in the last 12h.
is_about_to_expire() {
    if [ "$(find "$KEY_DIR" -type f -cmin -720 \( -iname "*.key" -and \
        ! -iname "public.key" -and ! -iname "secret.key" \) \
        \( -iname "*.key" -or -iname "*.cert" \) -print \
        | wc -l | sed 's/[^0-9]//g')" -le 0 ]; then
        echo 1
    else
        echo 0
    fi
}

# Print a list of valid keys
valid_keys() {
    find "$KEY_DIR" -type f -cmin -"$TIME" \( -iname "*.key" -and \
        ! -iname "public.key" -and ! -iname "secret.key" \) | sort
}

# Print a list of valid certificates
valid_certs() {
    find "$KEY_DIR" -type f -cmin -"$TIME" \( -iname "*.cert" -and \
        ! -iname "public.key" -and ! -iname "secret.key" \) | sort
}

# Show public key fingerprint, certificate expire periods and currently loaded certificates in unbound
status() {
    time_in_hours=$((TIME / 60 ))

    echo "Script file path: $script_file_path"
    echo "Loaded config file: $KEY_DIR/dnscrypt-autokey.conf"

    printf "%s" "$BLUE"
    show_public_key

    printf "%sVALID (modified less than ${time_in_hours}h ago):\\n" "$GREEN"
    valid_keys
    valid_certs

    printf "%sABOUT TO EXPIRE (modified more than $((time_in_hours-12))h and less than $((time_in_hours))h ago):\\n" "$YELLOW"
    find "$KEY_DIR" -type f -cmin +"$((TIME-12*60))" ! -cmin +"$TIME" \
        \( \( -iname "*.key" -or -iname "*.cert" \) -and \
        ! -iname "public.key" -and ! -iname "secret.key" \)

    printf "%sEXPIRED (modified more than ${time_in_hours}h ago):\\n" "$RED"
    find "$KEY_DIR" -type f -cmin +"$TIME" \
        \( \( -iname "*.key" -or -iname "*.cert" \) -and \
        ! -iname "public.key" -and ! -iname "secret.key" \)
    printf "%s" "$CLEAR"

    printf "Do we need to create new certs?: "
    is_about_to_expire

    # if  [ ! -z ${MODE+x} ] && [ "$MODE" = "unbound" ]; then
    #     printf "\\nUnbound loaded Keys and Certs:\\n"
    #     # Show current loaded certificate and key files in unbound
    #     $UNBOUND_CONTROL get_option dnscrypt-secret-key
    #     $UNBOUND_CONTROL get_option dnscrypt-provider-cert
    # fi

    echo "Running dnscrypt-wrapper/dnscrypt-proxy instances:"
    pgrep -l "(dnscrypt-wrapper|dnscrypt-proxy)" || true
}

# Removes expired certificates / keys from the disk
delete_expired() {
    find "$KEY_DIR" -type f -cmin +"$TIME" \
        \( \( -iname "*.key" -or -iname "*.cert" \) -and \
        ! -iname "public.key" -and ! -iname "secret.key" \) \
        -exec rm -vf {} \;
}

# Set-up folders and Generate the provider key pair (long term)
init() {
    if [ ! -z ${1+x} ]; then
        PROVIDER_NAME=2.dnscrypt-cert.$1
    else
        echo "Provider name is missing: e.g example.com (2.dnscrypt-cert. is automatically appended)"
        exit 1
    fi

    if [ ! -z ${2+x} ]; then
        EXTERNAL=$2
    else
        echo "External IP address is missing, the address clients will connect to e.g. 192.168.1.1"
        exit 1
    fi

    if [ ! -z ${3+x} ]; then
        KEY_DIR=$3
    fi

    save_conf

    # Generate the provider key pair (long term)
    dnscrypt-wrapper --gen-provider-keypair \
        --provider-publickey-file="$KEY_DIR"/public.key \
        --provider-secretkey-file="$KEY_DIR"/secret.key \
        --provider-name="$PROVIDER_NAME" \
        --ext-address="$EXTERNAL"

    renew
}

# Show provider public key fingerprint
show_public_key() {
    dnscrypt-wrapper --show-provider-publickey \
        --provider-publickey-file "$KEY_DIR"/public.key
}

# Generate a time-limited secret key (short term)
# accepts a file name as a parameter
new() {
    filename="$1"

    dnscrypt-wrapper --gen-crypt-keypair \
        --crypt-secretkey-file="$KEY_DIR"/"$filename".key
    dnscrypt-wrapper --gen-cert-file \
        --crypt-secretkey-file="$KEY_DIR"/"$filename".key \
        --provider-cert-file="$KEY_DIR/$filename".cert \
        --provider-publickey-file="$KEY_DIR"/public.key \
        --provider-secretkey-file="$KEY_DIR"/secret.key \
        --cert-file-expire-days="$VALIDITY_PERIOD"
    if [ "$CHACHA20" -eq 1 ]; then
        dnscrypt-wrapper --gen-cert-file \
            --xchacha20 \
            --crypt-secretkey-file="$KEY_DIR"/"$filename".key \
            --provider-cert-file="$KEY_DIR"/"$filename"-xchacha20.cert \
            --provider-publickey-file="$KEY_DIR"/public.key \
            --provider-secretkey-file="$KEY_DIR"/secret.key \
            --cert-file-expire-days="$VALIDITY_PERIOD"
    fi

    # set permissions for unbound
    # if [ ! -z ${MODE+x} ] && [ "$MODE" = "unbound" ]; then
    #     chown unbound:unbound "$KEY_DIR/$filename".*
    # fi
}

# Renew certificate. Use current timestamp as the CURRENT_KEY_ID
renew() {
    if [ "$(is_about_to_expire)" -eq 1 ]; then
        CURRENT_KEY_ID="$(date '+%s')"
        new "$CURRENT_KEY_ID"
    else
        echo "Still have valid keys. No certs/keys where generated"
    fi


    # CURRENT_KEY_ID="$(date '+%s')"

    # new "$CURRENT_KEY_ID-tmp"
    # new "$CURRENT_KEY_ID"

    # Be almost atomic
    # mv -fv "$KEY_DIR/$CURRENT_KEY_ID-tmp.key" \
    #     "$KEY_DIR/$CURRENT_KEY_ID.key"
    # mv -fv "$KEY_DIR/$CURRENT_KEY_ID-tmp.cert" \
    #     "$KEY_DIR/$CURRENT_KEY_ID.cert"
    # if [ "$CHACHA20" -eq 1 ]; then
    #     mv -fv "$KEY_DIR/$CURRENT_KEY_ID-tmp-xchacha20.cert" \
    #         "$KEY_DIR/$CURRENT_KEY_ID-xchacha20.cert"
    # fi

    # if [ ! -z ${MODE+x} ] && [ "$MODE" = "unbound" ];  then
    #     tell_unbound # about the new key and cert
    # fi

    # if [ ! -z ${MODE+x} ] && [ "$MODE" = "wrapper" ]; then
    #     restart_wrappers
    # fi
}

# Run the init, new, renew, remove-expired commands when needed
auto() {
    # Generate the provider key pair when not already present and create first short-term keypair
    if [ ! -f "$KEY_DIR/public.key" ] && [ ! -f "$KEY_DIR/secret.key" ]; then
        init
        new 0
        # new 1
    fi

    # Remove expired keys and certificates
    delete_expired

    # Renew when the latest cert is about to expire (12h left)
    # if [ "$(is_about_to_expire)" -eq 1 ]; then
        renew
    # fi
}

# # Tell unbound about the new key and cert
# # a reload will empty the cache (maybe use dump_cache>file and load_cache<file ?)
# tell_unbound() {
#     printf "Reloading unbound... "
#     # $UNBOUND_CONTROL dump_cache > /usr/local/etc/unbound/unbound_cache.dmp
#     $UNBOUND_CONTROL reload
#     # $UNBOUND_CONTROL load_cache < /usr/local/etc/unbound/unbound_cache.dmp
# }

# Start dnscrypt-proxy for local testing on localhost
start_wrapper() {
    # Shell check false-positive
    # shellcheck disable=SC2039
    pid="$(pgrep dnscrypt-wrapper||echo "-1")"
    if [ "$pid" -gt -1 ]; then
        echo "Process already running. pid:$pid"
        exit 1
    fi

    if [ ! -z ${1+x} ]; then
        RESOLVER=$1
    fi
    if [ ! -z ${2+x} ]; then
        LISTEN=$2
    fi

    save_conf

    if [ ! -f "$KEY_DIR/public.key" ] && [ ! -f "$KEY_DIR/secret.key" ]; then
        echo "Missing provider keys. Please run '$0 init' first"
        exit 1
    fi
    delete_expired
    renew
    # if [ "$(is_about_to_expire)" -eq 1 ]; then
    #     renew
    # fi

    # We do want word splitting for the list of files
    # shellcheck disable=SC2046
    exec "$needsudo" dnscrypt-wrapper \
        --daemonize \
        --user="$USER" \
        --listen-address="$LISTEN" \
        --resolver-address="$RESOLVER" \
        --provider-name="$PROVIDER_NAME" \
        --provider-cert-file=$(valid_certs) \
        --crypt-secretkey-file=$(valid_keys) \
        "$CUSTOM_FLAGS"

    # echo "Listening at: $LISTEN"
    # show_public_key
}

stop_wrapper() {
    "$needsudo" pkill dnscrypt-wrapper
    echo 'send kill signal'
}

# restart_wrappers() {
#     if [ ! -z ${1+x} ]; then
#         PORTS="$1"
#     else
#         echo "missing ports"
#         exit 1
#     fi
#     pkill dnscrypt-wrapper || true # ignore failure when wrapper is not running

#     # wait for ports to clear (FreeBSD this can range to 10 minutes)
#     sleep 0.4

#     original_IFS=$IFS
#     IFS=', ' # split on commas and spaces
#     for port in $PORTS; do
#         IFS=$original_IFS
#         echo "Listening on: $port"
#         start_wrapper "$port"
#     done
#     IFS=$original_IFS
# }

# Start dnscrypt-proxy for local testing on localhost
# start_proxy() {
#     # dnscrypt-proxy v1 is required
#     dnscrypt-proxy --local-address=127.0.0.1:5300 \
#         --resolver-address=127.0.0.1:443 \
#         --provider-name="$PROVIDER_NAME" \
#         --provider-key="$(show_public_key | awk '{print $4}')"
# }

update() {
    script_file_path="$(get_realpath "$0")"
    echo 'not implemented'
    # wget https://gist.githubusercontent.com/publicarray/a246106b5a6821b69b86e8d05ee41896/raw/dnscrypt-autokey.sh -O "$script_file_path"
    # chmod +x "$script_file_path"
}

if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

# Read arguments from the commandline
while [ $# -gt 0 ] && [ "$1" != "" ]; do
    case $1 in
        -h | --help | help | -\? | \?)
            usage
            exit
            ;;
        -c | --cron | cron | -a | --auto | auto)
            load_conf
            auto
            exit
            ;;
        -i | --init | init)
            load_conf
            shift
            init "$@"
            exit
            ;;
        -spk | --show-public-key | show-public-key | -f | --fingerprint | fingerprint | finger)
            load_conf
            show_public_key
            exit
            ;;
        -n | --new | new)
            load_conf
            shift
            arg="${1:-$(date '+%s')}" # use the current UNIX time for a cert_id
            new "$arg"
            exit
            ;;
        -r | --renew | renew)
            load_conf
            renew
            ;;
        -s | --status | status | --check | check)
            load_conf
            status
            ;;
        # -p | --proxy | proxy)
        #     load_conf
        #     start_proxy
        #     exit
        #     ;;
        --start | start)
            load_conf
            shift
            start_wrapper "$@"
            exit
            ;;
        --stop | stop)
            load_conf
            stop_wrapper
            exit
        ;;
        # -ws | --wrappers | wrappers)
        #     load_conf
        #     shift
        #     restart_wrappers "$1" #format: -ws "8080, 443, 5353"
        #     exit
        #     ;;
        -d | --delete-expired | delete-expired)
            load_conf
            delete_expired
            ;;
        -u | --update | update)
            update
            exit
            ;;
        *)
            echo "ERROR: unknown parameter \"$1\""
            usage
            exit 1
            ;;
    esac
    shift # get next parameter
done
