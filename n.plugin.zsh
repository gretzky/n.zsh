switch_n() {
	# make sure jq is installed
	if [ ! "$(command -v jq)" ]; then
		printf "jq is not installed\ndid u even read the README 🤔"
		exit 1
	fi

	if [ ! "$(command -v n)" ]; then
		printf "n isn't installed\ny tho"
		exit 1
	fi

	if [ -f 'package.json' ]; then
		node_field=$(cat package.json | jq -r '.engines.node')
		field_version=${node_field//[^0-9]/}
		gt=">"
		current_node=$(node -v)
		format_version=${current_node:1:2}
		current_version=${format_version//[^0-9]/}
		# check for an engines field
		if $(cat package.json | jq -e 'has("engines")'); then
			# make sure engines has a node field
			if $(cat package.json | jq '.engines | has("node")'); then
				# check if we're already using the same node version
				if [ "$current_version" != "$field_version" ]; then
					if [[ "$node_field" == *$gt* ]]; then
						# if node field reads greater than, use node stable
						echo "switching to node stable..."
						n stable >/dev/null 2>&1
					else
						# otherwise, use the latest release of the specified version
						echo "switching to node $field_version..."
						n "$field_version" >/dev/null 2>&1
						# the only error that can be thrown at this point is needing sudo
						# so we prompt a permissions change
						if [ $? -eq 1 ]; then
							printf "looks like n doesnt have user permissions\nyou can fix this with:\nsudo chown -R $(whoami) /usr/local/n"
						fi
					fi
				fi
			fi
		else
			echo "\nengines field not specified in package.json"
			echo "switching to node stable..."
			n stable >/dev/null 2>&1
		fi
	fi
}

chpwd_functions=(${chpwd_functions[@]} "switch_n")
