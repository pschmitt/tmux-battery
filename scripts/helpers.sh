get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value="$(tmux show-option -gqv "$option")"
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

is_osx() {
	[ $(uname) == "Darwin" ]
}

is_chrome() {
	chrome="/sys/class/chromeos/cros_ec"
	if [ -d "$chrome" ]; then
		return 0
	else
		return 1
	fi
}

is_wsl() {
	version=$(</proc/version)
	if [[ "$version" == *"Microsoft"* || "$version" == *"microsoft"* ]]; then
		return 0
	else
		return 1
	fi
}

is_termux() {
  [[ $(uname -o) == "Android" ]] && command -v termux-info >/dev/null 2>&1
}

command_exists() {
	local command="$1"
	type "$command" >/dev/null 2>&1
}

get_system_battery() {
	local b
	for b in /sys/class/power_supply/BAT* /sys/class/power_supply/bat* /sys/class/power_supply/battery*; do
		if [[ -d "$b" && -r "$b/capacity" ]]; then
			echo "$b"
			return 0
		fi
	done
	for b in /sys/class/power_supply/*; do
		if [[ -d "$b" && -r "$b/capacity" && -r "$b/type" ]]; then
			local b_type b_scope
			b_type="$(<"$b/type")"
			b_scope="$(cat "$b/scope" 2>/dev/null)"
			if [[ "$b_type" == "Battery" && "$b_scope" != "Device" ]]; then
				echo "$b"
				return 0
			fi
		fi
	done
	return 1
}

has_battery() {
	if get_system_battery >/dev/null 2>&1; then
		return 0
	fi

	if is_osx
	then
		pmset -g batt 2>/dev/null | grep -qE '[0-9]+%'
		return
	fi

	if command_exists acpi
	then
		acpi -b 2>/dev/null | grep -v "rate information unavailable" | grep -qE '[0-9]+%'
		return
	fi

	if command_exists upower
	then
		upower -e 2>/dev/null | grep -qE '/battery_[^/]+$'
		return
	fi

	if is_termux || command_exists termux-battery-status
	then
		termux-battery-status >/dev/null 2>&1
		return
	fi

	if command_exists apm
	then
		apm -a >/dev/null 2>&1
		return
	fi

	return 1
}

battery_status() {
	local bat
	if bat="$(get_system_battery 2>/dev/null)" && [[ -n "$bat" && -r "$bat/status" ]]; then
		awk '{print tolower($0);}' "$bat/status"
		return
	fi
	if is_termux; then
    termux-battery-status | jq -er '.status | ascii_downcase'
	elif is_wsl; then
		local battery
		battery=$(find /sys/class/power_supply/*/status | tail -n1)
		awk '{print tolower($0);}' "$battery"
	elif command_exists "pmset"; then
		pmset -g batt | awk -F '; *' 'NR==2 { print $2 }'
	elif command_exists "acpi"; then
		acpi -b | grep -v "rate information unavailable" | awk '{gsub(/,/, ""); print tolower($3); exit}'
	elif command_exists "upower"; then
		local battery
		battery=$(upower -e | grep -E 'battery|DisplayDevice'| tail -n1)
		upower -i $battery | awk '/state/ {print $2}'
	elif command_exists "termux-battery-status"; then
		termux-battery-status | jq -r '.status' | awk '{printf("%s%", tolower($1))}'
	elif command_exists "apm"; then
		local battery
		battery=$(apm -a)
		if [ $battery -eq 0 ]; then
			echo "discharging"
		elif [ $battery -eq 1 ]; then
			echo "charging"
		fi
	fi
}
