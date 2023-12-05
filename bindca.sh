#!/bin/sh

# bindca.sh
# by throwaway96
# Licensed under GNU AGPL version 3 or later.
# https://github.com/throwaway96/webos1-bindca

# based on https://gist.github.com/Informatic/d7bcdd59eac16ffbffd3a5b5c24b4195

BIND_BASE=/var/lib/webosbrew/bindca

if [ ! -e "${BIND_BASE}" ]; then
	mkdir -p -- "${BIND_BASE}"
elif [ ! -d "${BIND_BASE}" ]; then
	echo "[-] BIND_BASE ('${BIND_BASE}') must be a directory"
	exit 1
fi

user_dev="$(findmnt -n -o 'MAJ:MIN' -T "${BIND_BASE}")"

bind_dir() {
	set -e
	target="${1}"
	bind_id="$(echo "${target}" | sed -e 's;/;__;g')"
	bind_src="${BIND_BASE}/${bind_id}"

	if [ -n "${user_dev}" ] && findmnt -n -o 'MAJ:MIN' -- "${target}" | fgrep -x -e "${user_dev}"; then
		echo "[-] Bind mount already exists over '${target}'"
	elif [ -f "${target}" ]; then
		if [ ! -e "${bind_src}" ]; then
			echo "[ ] Copying file '${target}'"
			cp -dp -- "${target}" "${bind_src}"
		elif [ ! -f "${bind_src}" ]; then
			echo "[-] '${bind_src}' is not a file as expected"
			return 1
		fi

		mount --bind "${bind_src}" "${target}"
		echo "[+] Bind mounted file '${bind_src}' over '${target}'"
	elif [ -d "${target}" ]; then
		if [ ! -e "${bind_src}" ]; then
			echo "[ ] Copying directory '${target}'"
			cp -dpR -- "${target}" "${bind_src}"
		elif [ ! -d "${bind_src}" ]; then
			echo "[-] '${bind_src}' is not a directory as expected"
			return 1
		fi
		
		mount --bind "${bind_src}" "${target}"
		echo "[+] Bind mounted directory '${bind_src}' over '${target}'"
	else
		echo "[-] '${target}' is neither a file nor directory"
		return 1
	fi
}

bind_dir /etc/ssl/certs
bind_dir /usr/share/ca-certificates
bind_dir /etc/ca-certificates.conf

if [ ! -f '/usr/share/ca-certificates/mozilla/ISRG_Root_X1.crt' ]; then
	# from https://letsencrypt.org/certs/isrgrootx1.pem
	cat <<'__EOF__' >'/usr/share/ca-certificates/mozilla/ISRG_Root_X1.crt'
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
__EOF__
	ln -sf -- '/usr/share/ca-certificates/mozilla/ISRG_Root_X1.crt' '/etc/ssl/certs/ISRG_Root_X1.pem'
fi

if [ ! -f '/usr/share/ca-certificates/mozilla/ISRG_Root_X2.crt' ]; then
	# from https://letsencrypt.org/certs/isrg-root-x2.pem
	cat <<'__EOF__' >'/usr/share/ca-certificates/mozilla/ISRG_Root_X2.crt'
-----BEGIN CERTIFICATE-----
MIICGzCCAaGgAwIBAgIQQdKd0XLq7qeAwSxs6S+HUjAKBggqhkjOPQQDAzBPMQsw
CQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJuZXQgU2VjdXJpdHkgUmVzZWFyY2gg
R3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBYMjAeFw0yMDA5MDQwMDAwMDBaFw00
MDA5MTcxNjAwMDBaME8xCzAJBgNVBAYTAlVTMSkwJwYDVQQKEyBJbnRlcm5ldCBT
ZWN1cml0eSBSZXNlYXJjaCBHcm91cDEVMBMGA1UEAxMMSVNSRyBSb290IFgyMHYw
EAYHKoZIzj0CAQYFK4EEACIDYgAEzZvVn4CDCuwJSvMWSj5cz3es3mcFDR0HttwW
+1qLFNvicWDEukWVEYmO6gbf9yoWHKS5xcUy4APgHoIYOIvXRdgKam7mAHf7AlF9
ItgKbppbd9/w+kHsOdx1ymgHDB/qo0IwQDAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T
AQH/BAUwAwEB/zAdBgNVHQ4EFgQUfEKWrt5LSDv6kviejM9ti6lyN5UwCgYIKoZI
zj0EAwMDaAAwZQIwe3lORlCEwkSHRhtFcP9Ymd70/aTSVaYgLXTWNLxBo1BfASdW
tL4ndQavEi51mI38AjEAi/V3bNTIZargCyzuFJ0nN6T5U6VR5CmD1/iQMVtCnwr1
/q4AaOeMSQ+2b1tbFfLn
-----END CERTIFICATE-----
__EOF__
	ln -sf -- '/usr/share/ca-certificates/mozilla/ISRG_Root_X2.crt' '/etc/ssl/certs/ISRG_Root_X2.pem'
fi

if fgrep -q -i -e 'DST_Root_CA_X3' -- '/etc/ca-certificates.conf'; then
	echo "[+] Removing DST_Root_CA_X3"
	# sed -i tries to create a temporary file in /etc
	tempfile="$(mktemp)"
	sed -e '/DST_Root_CA_X3/d' '/etc/ca-certificates.conf' >"${tempfile}" && cat -- "${tempfile}" >'/etc/ca-certificates.conf'
fi

if ! fgrep -q -e 'ISRG_Root_X1' -- '/etc/ca-certificates.conf'; then
	echo "[+] Adding ISRG_Root_X1"
	echo 'mozilla/ISRG_Root_X1.crt' >>'/etc/ca-certificates.conf'
fi

if ! fgrep -q -e 'ISRG_Root_X2' -- '/etc/ca-certificates.conf'; then
	echo "[+] Adding ISRG_Root_X2"
	echo 'mozilla/ISRG_Root_X2.crt' >>'/etc/ca-certificates.conf'
fi

if [[ "$(ls -td '/etc/ssl/certs/'* '/etc/ca-certificates.conf' | head -1)" != '/etc/ssl/certs/ca-certificates.crt' ]]; then
	update-ca-certificates
	./c_rehash
	cp -- '/etc/ssl/certs/ca-certificates.crt' '/etc/ssl/certs/trusted_cas.crt'
fi

# vim: noet:ts=8:sw=8
