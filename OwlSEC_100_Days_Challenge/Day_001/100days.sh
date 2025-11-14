#!/bin/bash
###################################
NAME="100 Days Template Generator"
AUTHOR="RadicalEd"
SUMMARY="Creates a Template Post for the 100 Days Challenge"
DESCRIPTION="Outputs A Discord Template Post in the Required Format of the OwlSEC Challenge: 100 Days of Hacking"
LICENSE="Whatever You Want"
PROG="$0"
###################################
# USAGE

usage () {
	TCOLS="$(tput cols)";
	COLOR="$(tput setaf 1)";
	RESET="$(tput sgr0)";
	cat << EOF >&2
${COLOR}${NAME}${RESET} - Written by ${COLOR}${AUTHOR}${RESET}
$(echo -n "	${SUMMARY}" | fmt -w ${TCOLS})

${COLOR}DESCRIPTION${RESET}
$(echo -n "	${DESCRIPTION}" | fmt -w ${TCOLS})

${COLOR}USAGE:${RESET}
$(echo -n "	${PROG} [-h] [-w WORKED_ON] [-c COMPLETED] [-p PROGRESS] [-e EVIDENCE] [-n NEXT_STEPS] [-C] [-f <file>] <DAY>" | fmt -w $TCOLS)

	-h        : Show Usage
	-w <text> : What You Worked On
	-c <text> : What You Completed
	-p <text> : Progress Since Yesterday
	-e <text> : Evidence (In Text)
	-n <text> : Next Steps, What You Plan To Do Tommorow
	-C        : Copy to Clipboard instead of Stdout
	-f <file> : Source From a File Instead. (e.g. WORKED_ON="Text")

EOF
}
error () { # Example: error 1 "Example"
	code="${1}"; shift
	case "${code}" in
		(1) usage && echo "Error $code: $*" >&2;;
		(*) echo "Error $code: $*" >&2;;
	esac
	exit "${code}"
}
# END OF USAGE
###################################
# HANDLE ARGUMENTS

while getopts "hw:c:p:e:n:Cf:" o;do
	case "${o}" in
		(h) usage && exit;;
		(w) WORKED_ON="${OPTARG}";;
		(c) COMPLETED="${OPTARG}";;
		(p) PROGRESS="${OPTARG}";;
		(e) EVIDENCE="${OPTARG}";;
		(n) NEXT_STEPS="${OPTARG}";;
		(C) TO_CLIPBOARD="true";;
		(f) SOURCE_FILE="${OPTARG}";;
	esac
done

shift $((OPTIND-1))

[ ! "$1" ] && error 1 "Need Positional Argument: <DAY>"
DAY="$(printf "%03d" "${1}")"

# END OF HANDLE ARGUMENTS
###################################
# EXECUTION

[ "${SOURCE_FILE}" ] && {
	[ -e "${SOURCE_FILE}" ] && {
		source "${SOURCE_FILE}"
	} || {
		error 2 "File Not Found: $SOURCE_FILE"
	}
}

DATE=$(date "+%Y-%m-%d")

output="$(cat <<-EOF
	**Day** $DAY / **Date** ($DATE)
	**What I Worked On**: ${WORKED_ON}
	**What I Completed**: ${COMPLETED:-What I Worked On}
	**Progress Vs Yesterday**: ${PROGRESS:-Another Day For 100 Days}
	**Evidence**: ${EVIDENCE:-See Attached Files}
	**Next Steps**: ${NEXT_STEPS:-I am Unsure, The World is My Oyster}
	EOF
)"

if [ "$TO_CLIPBOARD" ];then
	which xclip >/dev/null && echo -n "$output" | xclip -sel c -in
	which wl-copy >/dev/null && echo -n "$output" | wl-copy
else
	echo -n "$output"
fi

# END OF EXECUTION, Have a Nice Day
###################################
# 100 lines for 100 Days =)
