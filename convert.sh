#!/bin/bash
#---------------------
# Author: Klaus Hörmann-Engl
# Title: convert.sh
# Description: Convert XVID movies to H264 movies (AVC)
#---------------------

# TODO: Add "dry-run" option!!!!

# TODO: Add function to combine 2 files into a single movie using "ffmpeg"
# ffmpeg -f concat -i <(for f in ./*.m4v; do echo "file '$PWD/$f'"; done) -c copy movie_file_path.m4v

# TODO: Add configuration:
# - Single file given (input => output)
#- 


# General variables
VERSION=0.3
MOVIE_COUNTER=0
MAX_MOVIE_AMOUNT=5

# Movie paths
MOVIE_PATH_OLD="/mnt/NAS_video/Movies Convert/De/"
MOVIE_PATH_NEW="/mnt/NAS_video/Movies/De/"
MOVIE_OBSOLETE="/mnt/NAS_video/Moveies OBSOLETE/De/"

clear

# Welcome message
echo "Convert XVID, DIVX, ... to H264 (AVC)\n"

# Go through all movie dirs in the root path
for movie_dir_path in "$MOVIE_PATH_OLD"*; do

	# Go through all movie files in the movie path
	for movie_file_path in "$movie_dir_path"/*; do

		# Set movie_dir and movie_file
		movie_dir=`basename "$movie_dir_path"`
		movie_file=`basename "$movie_file_path"`
		new_movie_file_path=$MOVIE_PATH_NEW$movie_dir"/"$movie_file

		# Get CODEC of file
		codec=$(mediainfo "$movie_file_path" --Inform="Video;%Codec%")

		# Check if codec is "XVID"
		if [ "$codec" = "XVID" ]; then

			# COMMAND: Create new directory
			mkdir -p "$MOVIE_PATH_NEW$movie_dir"

			# Convert old file into new file
			echo "Codec: "$codec" => Convert"
			echo "Old movie_file: "$movie_file_path
			echo "New movie_file: "$new_movie_file_path
		
			# COMMAND: Convert to H264
			HandBrakeCLI -i "$movie_file_path" -o "$new_movie_file_path" --preset="Normal"

			# COMMAND: Rename new movie file to m4v
			mv "$new_movie_file_path" "$MOVIE_PATH_NEW$movie_dir""/""`basename "$new_movie_file_path" .avi`.m4v"

			echo ""
		fi

	done

	# COMMAND: Move old movie folder to obsolete folder
	mv "$movie_dir_path" "$MOVIE_OBSOLETE"

	# Raise counter
	MOVIE_COUNTER=$((MOVIE_COUNTER+1))
	
	# Break when movie counter exceeds max movie amount
	if [ $MOVIE_COUNTER -eq $MAX_MOVIE_AMOUNT ]; then
		break
	fi
	
done

