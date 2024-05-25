#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Directory containing the files to deploy
output_dir="output"

echo "garden.grantcuster.com" > $output_dir/CNAME

# Branch to deploy to
deploy_branch="gh-pages"

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if the output directory exists
if [ ! -d "$output_dir" ]; then
    echo "Output directory '$output_dir' does not exist."
    exit 1
fi

# Create a temporary directory to stage the deployment
tmp_dir=$(mktemp -d)
trap "rm -rf $tmp_dir" EXIT

# Copy the contents of the output directory to the temporary directory
cp -r $output_dir/* $tmp_dir

# Check out the gh-pages branch, creating it if it doesn't exist
if git show-ref --verify --quiet refs/heads/$deploy_branch; then
    git checkout $deploy_branch
else
    git checkout --orphan $deploy_branch
fi

# Remove all existing files
git rm -rf .

# Copy the new files from the temporary directory to the repository
cp -r $tmp_dir/* .

# Add all files to the Git index
git add .

# Commit the changes
git commit -m "Deploy to $deploy_branch"

# Push the changes to the remote repository
git push origin $deploy_branch

# Switch back to the original branch
git checkout $current_branch

echo "Deployment to $deploy_branch branch completed successfully."

