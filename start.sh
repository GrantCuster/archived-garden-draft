
#!/bin/bash

# Define the options and their corresponding commands
declare -A options
options=(
    ["dev"]="bash scripts/dev.sh"
    ["new post"]="bash scripts/new_post.sh"
    ["build"]="bash scripts/build.sh"
    ["edit"]="nvim ."
)

# Define the list of labels
labels=(
    "dev"
    "new post"
    "build"
    "edit"
    "exit"
)

# Function to display the menu and execute the selected command
run_fzf() {
    while true; do
        # Use fzf to present the options
        selected_label=$(printf "%s\n" "${labels[@]}" | fzf --prompt="Select an option: ")

        # Check if a valid option was selected
        if [ -n "$selected_label" ]; then
            if [ "$selected_label" = "exit" ]; then
                echo "Exiting..."
                break
            fi
            # Get the corresponding command for the selected label
            command=${options["$selected_label"]}
            if [ -n "$command" ]; then
                # Run the selected script and wait for it to complete
                eval "$command"
                # Wait for user to press Enter before rerunning fzf
                read -p "Press Enter to return to menu..."
            else
                echo "Invalid option selected."
            fi
        else
            echo "No valid option selected."
            break
        fi
    done
}

# Run the menu
run_fzf

