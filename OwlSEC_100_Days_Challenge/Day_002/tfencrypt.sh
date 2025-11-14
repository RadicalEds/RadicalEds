#!/bin/bash
#################################
VERSION="0.1"
NAME="Two Fish Wrapper"
AUTHOR="RadicalEd"
SUMMARY="Data Encryption Wrapper"
DESCRIPTION="Encrypts/Decrypts Files or Pipes With GPG Ciphers. Uses TwoFish by default."
LICENSE="Whatever You Want"
PURPOSE="Inspired by Cryptcat. Hoping to Eventually have full Compatibility between Netcat and Cryptcat with this wrapper, but were not there yet."
#################################
# USAGE

BANNER='
 mmmmmmmm mm      mm   mmmm      mmmmmmmm   mmmmmm     mmmm    mm    mm 
 """##""" ##      ##  ##""##     ##""""""   ""##""   m#""""#   ##    ## 
    ##    "#m ## m#" ##    ##    ##           ##     ##m       ##    ## 
    ##     ## ## ##  ##    ##    #######      ##      "####m   ######## 
    ##     ###""###  ##    ##    ##           ##          "##  ##    ## 
    ##     ###  ###   ##mm##     ##         mm##mm   #mmmmm#"  ##    ## 
    ""     """  """    """"      ""         """"""    """""    ""    "" '
BANNERCOLOR="$(tput setaf 4)"
COLOR="$(tput setaf 6)"
CLEAR="$(tput sgr0)"
TCOLS="$(tput cols)"
PROGRAM="$0"

usage() {
	echo "${BANNERCOLOR}${BANNER}${CLEAR}" >&2
	cat << EOF >&2
${COLOR}${NAME}${CLEAR} v${VERSION} - Written By ${COLOR}${AUTHOR}${CLEAR}

$(echo -n "	${DESCRIPTION}" | fmt -w "${TCOLS}")

${COLOR}PURPOSE${CLEAR}
$(echo -n "	${PURPOSE}" | fmt -w "${TCOLS}")

${COLOR}USAGE${CLEAR}: $PROGRAM [-h] [-d] [-l] [-i <file>] [-o <file>] [-c <cipher>] <PASS>

	-h          : show usage
	-d          : decrypt
	-l          : list available gpg ciphers
	-i <file>   : read from file instead of stdin
	-o <file>   : write to file instead of stdout
	-c <cipher> : gpg cipher algorithm to use (twofish by default)

	<PASS>      : can be a passphrase, or a file to read from

EOF
}

error() {
	code="$1"
	shift

	case "${code}" in
		(1) usage;;
	esac

	echo "Error ${code}: $*" >&2
	exit "${code}"
}

# End Of Usage
#################################
# Handle Arguments
while getopts "hdli:o:c:" opt; do
  case $opt in
    (i) file="$OPTARG";;
    (d) decrypt=true;;
    (o) ofile="$OPTARG";;
    (c) cipher="$OPTARG";;
	(l) listciphers="true";;
    (h) usage && exit;;
	(*) usage && exit;;
  esac
done
shift "$((OPTIND - 1))"

cipher="${cipher:-twofish}"
data_input="${file:-/dev/stdin}"
pass_input="${1:-/dev/stdin}"
data_output="${ofile:-/dev/stdout}"

# End Of Arguments
#################################
# Execution

	# Cipher Check
ciphers=(idea 3des cast5 blowfish aes aes192 aes256 twofish camellia128 camellia192 camellia256)
[[ ! " ${ciphers[@]} " =~ " ${cipher} " ]] && error 2 "Unknown Cipher: ${cipher}"

if [ "$listciphers" ];then
	printf '%s\n' "${ciphers[@]}"
	exit
fi

	# Determine Passphrase Input
if [ ! -f "$pass_input" ] || [ "$pass_input" == "/dev/stdin" ];then
	passfile="/tmp/asdf-${RANDOM}$(date +%s)${RANDOM}"
	if [ "$pass_input" == "/dev/stdin" ];then
		cat "$pass_input" > "$passfile"
	else
		echo -n "$pass_input" > "$passfile"
	fi
	removetmpfile='true'
else
	passfile="$pass_input"
fi

	# Encrypt/Decrypt

		# CryptCat seems to encrypt every 16 byte "block" individually which makes sense for a continuous stream of data (or filesystem encryption like luks)

		# Closest ive come to doing this in bash is this command "cat file | split -d -b 16 --filter="cat|gpg..." - > file'
		# but... gpg appends the file header to every block, turning ~2400 bytes into ~14,000 (~6x larger)

		# removing the gpg file headers could be the way to go, but it still takes a looong time to pass any data through....
		# Likely because we are reloading gpg every 16 bytes. (2400 bytes took about 30 seconds, ungodly...)

		# This Project would be much more efficient, if done in a Full Language instead of stringing together tools in Bash,
		# But here we are. atm What we have here is a simple pipe encrypter, incompatible with cryptcat but does encrypt pipes/files.

		# Example as File Transfer:
			# cat file | ./tfencrypt.sh passfile > /dev/tcp/123.123.123.123/4040
			# nc -lvp 4040 | ./tfencrypt.sh -d passfile > outputfile

		# Havent Worked Out A Full Reverse Shell with Bash Yet.
		# would need to decrypt stdout and encrypt stdin to the socket, on both sides of the connection.
		
		# To Be Continued....

rv=0
if [ "$decrypt" ];then
	cat "$data_input" | gpg --batch -d --allow-old-cipher-algos --passphrase-file="$passfile" 2>/dev/null > "$data_output"
	rv="$?"
else
	cat "$data_input" | gpg --batch -c --allow-old-cipher-algos --passphrase-file="$passfile" --cipher-algo "$cipher" > "$data_output"
	rv="$?"
fi

	# Cleanup And Exit
[ "$removetmpfile" == 'true' ] && shred -zu "$passfile"
[ "$rv" -ne 0 ] && error 3 "gpg returned an error: Code ${rv}"

# End Of Execution
#################################
