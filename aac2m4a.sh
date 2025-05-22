#!/bin/bash

# Iterate over all .aac files in the current directory
for file in *.aac; do
  # Get the filename without the extension
  filename="${file%.*}"

  # Use ffmpeg to remux the aac file to m4a
if [ ! -f "${filename}.m4a" ]; then
  ffmpeg -i "$file" -c copy "${filename}.m4a"
fi

  # Optional: Uncomment the next line if you want to delete the original .aac file after conversion
  # rm "$file"
done

echo "Remuxing complete!"
