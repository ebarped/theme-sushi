_load_sushi

function fish_prompt
	set -l symbol "λ "
	set -l code $status
	set cwd (prompt_pwd)

	printf (yellow)"("(dim)$cwd(yellow)") "(off)

	if test -n "$SSH_CLIENT"
		set -l host (hostname -s)
		set -l who (whoami)
		echo -n -s (red)"("(cyan)"$who"(red)":"(cyan)"$host"(red)") "(off)
	end

	if git::is_repo
		set -l gituser (git config user.name 2>/dev/null)
		set -l branch (git::branch_name 2>/dev/null)
		set -l ref (git show-ref --head --abbrev | awk '{print substr($0,0,7)}' | sed -n 1p)


		echo -n -s (red)"("(off)
		printf (blue)"$gituser"(off)
		printf "@"
		
		if git::is_dirty
			printf (white)"*"(off)
		end

		if command git symbolic-ref HEAD > /dev/null 2>&1
			if git::is_staged
				printf (cyan)"$branch"(off)
			else
				printf (yellow)"$branch"(off)
			end
		else
			printf (dim)"$ref"(off)
		end

		if git::is_stashed
			echo -n -s " | 🚩"
		end

		for remote in (git remote)
			set -l behind_count (echo (command git rev-list $branch..$remote/$branch 2>/dev/null | wc -l | tr -d " "))
			set -l ahead_count (echo (command git rev-list $remote/$branch..$branch 2>/dev/null | wc -l | tr -d " "))

			if test $ahead_count -ne 0; or test $behind_count -ne 0; and test (git remote | wc -l) -gt 1
				echo -n -s " "(orange)$remote(off)
			end

			if test $ahead_count -ne 0
				echo -n -s (white)" | +"$ahead_count(off)
			end

			if test $behind_count -ne 0
				echo -n -s (white)" | -"$behind_count(off)
			end
		end

		echo -n -s (red)") "(off)
	end

	set -l k8s_context (k8s::current_context 2>/dev/null); and begin
		set -l k8s_namespace (k8s::current_namespace 2>/dev/null)
		if test "$k8s_context" = "null"
			# context is empty, i have no kubeconfig set
		else
			if test "$k8s_namespace" = "null"
				# kubeconfig set, but no namespace set
				printf (yellow)"("(blue)"☸ "(cyan)(k8s::current_context)(yellow)") "(off)
			else
				# kubeconfig and namespace set
				printf (yellow)"("(blue)"☸ "(cyan)(k8s::current_context)(orange)"@"(cyan)$k8s_namespace(yellow)") "(off)
			end
		end
	end

	echo
	if test "$code" = 0
		echo -n -s (red)"$symbol"(off)
	else
		echo -n -s (dim)"$symbol"(off)
	end
end
