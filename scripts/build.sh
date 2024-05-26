#!/bin/bash

# Function to unslugify a string
unslugify() {
    echo "$1" | sed 's/-/ /g'
}

# Set the directories
src_dir="src"
input_dir="content/posts"
output_dir="output"
template_file="wrapper.html"
css_file="index.css"
index_file="index.html"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Clear the output directory
rm -rf "$output_dir"/*

# Copy over the index.css
cp "$src_dir/$css_file" "$output_dir/index.css"

# Read the necessary template and header contents
index_head_content=$(<"$src_dir/index_head.html")
index_header_content=$(<"$src_dir/index_header.html")
template_content=$(<"$src_dir/$template_file")

# Initialize the HTML content for the index file
link_content=""

# Loop through each markdown file in the input directory
for file in $(ls "$input_dir"/*.md | sort -r); do
    # Skip if no markdown files are found
    [ "$file" = "$input_dir/*.md" ] && echo "No markdown files found in $input_dir." && exit 1

    # Get the base filename without the extension
    base_filename=$(basename "$file" .md)
    # Extract the date and title part from the filename
    date_part=$(echo "$base_filename" | sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}).*/\1/')
    title_part=$(echo "$base_filename" | sed 's/^[0-9-]*//')
    formatted_date=$(echo "$date_part" | sed 's/-/ /g' | awk '{print $1 "-" $2 "-" $3}')
    unslugified_title=$(unslugify "$title_part")

    # Add a list item to the index content
    link_content+="<div><a href=\"$base_filename/\">$formatted_date - $unslugified_title</a></div>"
done

# Prepare and save the index file content
index_content="$index_header_content$link_content"
index_content_wrapped="${template_content/\{content\}/$index_content}"
index_content_with_head="${index_content_wrapped/\{head\}/$index_head_content}"
formatted_index=$(echo "$index_content_with_head" | prettier --parser html)
echo "$formatted_index" > "$output_dir/$index_file"
echo "Index file created: $index_file"

# Read post head and header contents
post_head_content=$(<"$src_dir/post_head.html")
post_header_content=$(<"$src_dir/post_header.html")

# Loop through each markdown file in the input directory to process posts
for file in "$input_dir"/*.md; do
    # Skip if no markdown files are found
    [ "$file" = "$input_dir/*.md" ] && echo "No markdown files found in $input_dir." && exit 1

    # Get the base filename without the extension
    base_filename=$(basename "$file" .md)
    # Extract the date from the filename
    date_part=$(echo "$base_filename" | sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}).*/\1/')
    formatted_date=$(echo "$date_part" | sed 's/-/ /g' | awk '{print $1 "-" $2 "-" $3 " " $4 ":" $5}')
    head_title=$(head -n 1 "$file" | sed 's/^# //')
    head_description=$(head -n 3 "$file" | tail -n 1)

    # TODO clean up
    line_2=$(head -n 4 "$file" | tail -n 1)
    line_3=$(head -n 5 "$file" | tail -n 1)

    # Convert the markdown file to HTML using pandoc
    generated_html_content=$(pandoc "$file" --from=markdown-smart)
    date_paragraph="<p>$formatted_date</p>"
    html_content="$post_header_content$date_paragraph$generated_html_content"


    # Prepare and save the final post content
    head_template="${post_head_content//\{title\}/$head_title}"
    head_template="${head_template//\{description\}/$head_description}"
    head_template="${head_template//\{image_link\}/\/https://garden.grantcuster.com/$base_filename/preview.png}"
    head_replaced="${template_content/\{head\}/$head_template}"
    final_content="${head_replaced/\{content\}/$html_content}"
    formatted_post=$(echo "$final_content" | prettier --parser html)

    mkdir -p "$output_dir/$base_filename"
    # Set the output filename with the .html extension
    output_file="$output_dir/$base_filename/index.html"

    image_location="$output_dir/$base_filename/preview.png"
    ./scripts/image_generator "$image_location" "Grant's garden" "$formatted_date" "$head_title" "$head_description" "$line_2" "$line_3" "..."

    echo "$formatted_post" > "$output_file"
    echo "Converted $file to $output_file"
done

echo "All files have been converted."
