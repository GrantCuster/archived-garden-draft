#!/bin/bash

# Add new and modified files to the staging area
echo "Adding new and modified files to the staging area..."
git add .

echo "Files have been added to the staging area."

# Commit the changes with the provided message
read -p "Enter your commit message: " commit_message
git commit -m "$commit_message"
echo "Committing changes..."

# Push the changes to the origin main branch
echo "Pushing changes to origin main..."
git push origin main

echo "Changes have been committed and pushed to origin main."

