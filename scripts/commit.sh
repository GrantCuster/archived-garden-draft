#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Function to prompt for commit message
get_commit_message() {
    echo "Enter your commit message:"
    read -r commit_message
    echo "$commit_message"
}

# Add new and modified files to the staging area
echo "Adding new and modified files to the staging area..."
git add .

# Prompt for commit message
commit_message=$(get_commit_message)

# Commit the changes with the provided message
echo "Committing changes..."
git commit -m "$commit_message"

# Push the changes to the origin main branch
echo "Pushing changes to origin main..."
git push origin main

echo "Changes have been committed and pushed to origin main."

