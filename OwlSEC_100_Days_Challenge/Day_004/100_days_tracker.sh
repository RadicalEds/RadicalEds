#!/bin/bash
#####################################
VERSION="0.1"
NAME="OwlSEC 100 Days Tracker"
AUTHOR="RadicalEd"
DESCRIPTION="Keeps Track of The OwlSEC 100 Days of Hacking Event"
LICENSE="Whatever You Want"
#####################################
# Requirements

	# To Sync Messages, This Program Requires the Token of a User with Access to the "Once a day Proof" Forum Channel
	# Obtainable through the Devtools (Devtools are Disabled by Default for the Desktop Client, but can still be enabled)
TOKEN=""
#TOKEN="$(openssl enc -d ....cipher_flags_here.... -in discord_user.token)"

	# We Are Using MongoDB as our Database Since We Are Working With JSON Objects
DATABASE="OwlSEC_100_Days_Competition"
DB="mongodb://localhost:27017/$DATABASE"

	# These Are the External Programs we are using
REQUIREMENTS=(mongosh curl tput jq)

# End of Requirements
#####################################
# Colors

c () {
	case "${1}" in
		(black)      tput setaf 0;;
		(red)        tput setaf 1;;
		(green)      tput setaf 2;;
		(yellow)     tput setaf 3;;
		(blue)       tput setaf 4;;
		(magenta)    tput setaf 5;;
		(cyan)       tput setaf 6;;
		(white)      tput setaf 7;;
		(bg_black)   tput setab 0;;
		(bg_red)     tput setab 1;;
		(bg_green)   tput setab 2;;
		(bg_yellow)  tput setab 3;;
		(bg_blue)    tput setab 4;;
		(bg_magenta) tput setab 5;;
		(bg_cyan)    tput setab 6;;
		(bg_white)   tput setab 7;;
		(n)          tput sgr0;;
	esac
}

# End of Colors
#####################################
# Banner

BANNER="$(cat << EOF | sed -e "s/@/$(c magenta)@$(c n)/g" -e "s/!/$(c blue)!$(c n)/g" -e "s/:/$(c magenta):$(c n)/g"
  @@@   @@@@@@@@    @@@@@@@@      @@@@@@@    @@@@@@   @@@ @@@   @@@@@@   
 @@@@  @@@@@@@@@@  @@@@@@@@@@     @@@@@@@@  @@@@@@@@  @@@ @@@  @@@@@@@   
@@@!!  @@!   @@@@  @@!   @@@@     @@!  @@@  @@!  @@@  @@! !@@  !@@       
  !@!  !@!  @!@!@  !@!  @!@!@     !@!  @!@  !@!  @!@  !@! @!!  !@!       
  @!@  @!@ @! !@!  @!@ @! !@!     @!@  !@!  @!@!@!@!   !@!@!   !!@@!!    
  !@!  !@!!!  !!!  !@!!!  !!!     !@!  !!!  !!!@!!!!    @!!!    !!@!!!   
  !!:  !!:!   !!!  !!:!   !!!     !!:  !!!  !!:  !!!    !!:         !:!  
  :!:  :!:    !:!  :!:    !:!     :!:  !:!  :!:  !:!    :!:        !:!   
  :::  ::::::: ::  ::::::: ::      :::: ::  ::   :::     ::    :::: ::   
   ::   : : :  :    : : :  :      :: :  :    :   : :     :     :: : :    
EOF
)"

# End of Banner
#####################################
# Printing Functions

PROGRAM=$0
TCOLS="$(tput cols)"

usage () {
echo "$BANNER" >&2
cat << EOF >&2

$(c red)$NAME$(c n) v$VERSION - Written By $(c red)$AUTHOR$(c n)

$(echo -n "	$DESCRIPTION" | fmt -w $TCOLS)

$(c red)USAGE$(c n): $PROGRAM [-h] [-d] [-s] [-R] [-r <num>]
	-h       : show usage
	-d       : enable debugging messages
	-s       : sync messages (newest first, stops when we start recognizing messages)
	-R       : reverse sync order (oldest first)
	-r <num> : recognition, stop syncinc when we recognize more than <num> messages
EOF
}

error () {
	code="$1";shift
	case "$code" in
		(1) usage;;
	esac
	echo "Error $code: $*" >&2
	exit "$code"
}

debug () {
	[ "$DEBUG" ] &&	echo "$(c yellow)DEBUG:$(c n) $*" >&2
}

statusline () {
	if [ "$DEBUG" ];then
		echo "$*" >&2
	else
		echo -e -n "\r$*" >&2
	fi
}

hr () {
	printf -v _hr "%*s" $(tput cols) && echo ${_hr// /-};
}


# End of Printing Functions
#####################################
# Arguments

while getopts "hdsRr:" o;do
	case "${o}" in
		(h) usage && exit;;
		(d) DEBUG="true";;
		(s) SYNC="true";;
		(R) REVERSE="true";;
		(r) RECOGNITION="$OPTARG";;
		(*) exit 1;;
	esac
done

shift $((OPTIND-1))

# End of Arguments
#####################################
# Functions

mongo () {
	# Shorthand to Interact With Database
	mongosh "$DB" --eval "${1}" --json=relaxed
}

getMessages () {
	offset="${1}"
	guild="990435451334688768"
	channel="1433870834178724023"
	order="$([ "$REVERSE" ] && echo asc || echo desc)"
	curl --silent "https://discord.com/api/v9/guilds/${guild}/messages/search?channel_id=${channel}&sort_by=timestamp&sort_order=${order}&offset=${offset}" \
		-H 'accept: */*' \
		-H 'accept-language: en-US,en;q=0.9,en;q=0.8' \
		-H "authorization: ${TOKEN}" \
		-H 'priority: u=1, i' \
		-H "referer: https://discord.com/channels/${guild}/${channel}" \
		-H 'sec-ch-ua: "Not:A-Brand";v="24", "Chromium";v="134"' \
		-H 'sec-ch-ua-mobile: ?0' \
		-H 'sec-ch-ua-platform: "Linux"' \
		-H 'sec-fetch-dest: empty' \
		-H 'sec-fetch-mode: cors' \
		-H 'sec-fetch-site: same-origin' \
		-H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) discord/0.0.113 Chrome/134.0.6998.205 Electron/35.3.0 Safari/537.36'
}

recognize () {
	# Check Database If Exists
	id="$1"
	result="$(mongo "db.messages.findOne({id:'${id}'})")"
	if [ ! "$result" == "null" ];then
		debug "We Recognize $id"
		echo "True" #  TRUE we recognize this
	else
		debug "We DO NOT Recognize $id"
		exit 1 # FALSE we dont recognize
	fi
}

recognizeChannel () {
	# Check Database If Channel Exists
	id="$1"
	result="$(mongo "db.channels.findOne({id:'${id}'})")"
	if [ ! "$result" == "null" ];then
		debug "Existing Channel ${id}"
		echo "True"
	else
		debug "New Channel ${id}"
		exit 1
	fi
}

save () {
	# Upload Raw Message To Database
	json="$1"
	debug "Uploading To Database"
	result="$(mongo "db.messages.insertOne(${json})")"

	# Parse Message Details
	channel_id="$(jq -r .channel_id <<< "${json}")"
	message_id="$(jq -r .id <<< "${json}")"
	timestamp="$(jq -r .timestamp <<< "${json}")"
	author_id="$(jq -r .author.id <<< "${json}")"
	epoch="$(date -d "$timestamp" "+%s")"

	# Create New Channel Entries if They dont Exist
	if [ ! "$(recognizeChannel "$channel_id")" ];then
		channel="{
			\"id\": \"$channel_id\",
			\"messages\": [],
			\"latest\": null
		}"
		result="$(mongo "db.channels.insertOne(${channel})")"
	fi

	# add message to its channels message list
	result="$(mongo "db.channels.updateOne({ id:'${channel_id}' }, { \$push: { messages: {id:'$message_id', author:'$author_id', epoch:'$epoch'} } }) ")"
}

organize_latest () {
	# For Each Channel, Find Latest Message and Set it as latest
	echo "Organizing...."
	count=0
	channel_ids="$(mongo "db.channels.find({},{ _id:0, id:1 }).toArray()" | jq -r '.[].id')"
	total=$(wc -l <<< "$channel_ids")
	for channel_id in $channel_ids;do
		count=$((count+1))
		statusline "$count / $total"
		channel="$(mongo "db.channels.findOne({id:'$channel_id'})")"
		messages="$(jq -r '.messages[] | "\(.epoch)	\(.id)"' <<< "$channel")"
		latest="$(echo "$messages" | sort | tail -n1)"
		latest_id="$(cut -f 1 <<< "$latest")"
		latest_epoch="$(cut -f 2 <<< "$latest")"
		result="$(mongo "db.channels.updateOne({id:'$channel_id'}, {\$set: {latest:{ id:'$latest_id', epoch:'$latest_epoch' }}})")"
	done
	echo
}

printResults () {
	debug "Gathering Results..."
	# Total Threads (Channels)
	totalChannels="$(mongo "db.channels.find().count()")"
	totalMessages="$(mongo "db.messages.find().count()")"
	totalLate=0
	totalDanger=0

	current_time=$(date "+%s")
	deadline_36=$((current_time-129600))
	deadline_22=$((current_time-79200))

	# Check Each Threads Latest Message
	chans="$(mongo "db.channels.find({},{ _id:0, id:1, latest:1 }).toArray()" | jq -r '.[] | "\(.id)|\(.latest.epoch)"')"
	for chan in $chans;do
		id="$(cut -d '|' -f 1 <<< "$chan")"
		latest="$(cut -d '|' -f 2 <<< "$chan")"
		[ "$latest" == "null" ] && echo asdf
		if [ "$latest" -lt "$deadline_36" ];then
			totalLate=$((totalLate+1))
		elif [ "$latest" -lt "$deadline_22" ];then
			totalDanger=$((totalDanger+1))
		fi
	done

	debug "Printing Results..."


	#echo "Total Messages: $totalMessages"
	echo "Total Known Threads: $totalChannels"
	echo "Total In Danger (>22 hours of inactivity): $totalDanger"
	echo "Total past 36 hours of inactivity: $totalLate"
	echo
	echo "There are ~$((totalChannels-totalLate)) active players remaining."
}

syncMessages () {
	# Ensure We Have A Local Copy of Every Message
	echo "Syncing Messages..." >&2
	offset=0
	recognition=0
	until [ "$we_stop" ];do

		# Pull More Messages
		messages="$(getMessages "${offset}")"

		# Use Total Results From First Messages Pull to Avoid The Number Changing from New Posts During Sync
		totalresults="${totalresults:-$(echo "$messages" | jq -r .total_results)}"

		# Get Ids and Count Messages In this Pull
		messageIds="$(echo "$messages" | jq -r .messages[][].id)"
		messageCount="$(echo "$messageIds" | wc -l)"

		# Parse Messages
		debug "Parsing $messageCount Messages"
		while read id;do
			offset="$((offset+1))"
			statusline "Syncing $offset / $totalresults messages with $recognition recognized..."
			# If We Recognize the Id, Dont Parse It
			if [ "$(recognize "$id")" ];then
				recognition=$((recognition+1))
			else
				message="$(echo "$messages" | jq ".messages[][] | select(.id == \"$id\")")"
				save "${message}"
			fi
		done <<< "$messageIds"
		debug "Current Offset: $offset, Current Recognition: $recognition"
		
		if [ $recognition -ge ${RECOGNITION:-20} ] || [ $offset -ge $totalresults ];then
			debug "Stopping Sync..."
			we_stop="true"
			break
		fi

		# Do Not Get Rate Limited by Asking too Fast
		delay="$((RANDOM%4+1)).$((RANDOM%8+1))"
		debug "waiting $delay seconds..."
		sleep $delay
	done
	echo

	# Organize Channels
	hr
	organize_latest
}




# End of Functions
#####################################
# Execution

echo "$BANNER" >&2
[ "$SYNC" ] && hr && syncMessages
hr
printResults

# End of Execution
#####################################
