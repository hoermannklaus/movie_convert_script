#!/bin/bash
#---------------------
# Author: Klaus Hörmann-Engl
# Title: convert.sh
# Description: Convert XVID movies to H264 movies (AVC)
#---------------------

# Exit script when command fails
set -o errexit

# TODO: Add function to combine 2 files into a single movie using "ffmpeg"
# ffmpeg -f concat -i <(for f in ./*.m4v; do echo "file '$PWD/$f'"; done) -c copy movie_file_path.m4v

# TODO: Add configuration:
# - Single file given (input => output)


# General variables
DRY="n"
VERSION=0.4
MOVIE_COUNTER=1
MOVIE_PART_COUNTER=0
MAX_MOVIE_AMOUNT=1

# Convertion settings
HANDBRAKE_PRESET="Normal"


# Movie paths
MOVIE_PATH_OLD="/mnt/NAS_video/Movies Convert/Test/"
MOVIE_PATH_NEW="/mnt/NAS_video/Movies/De/"
MOVIE_OBSOLETE="/mnt/NAS_video/Movies OBSOLETE/De/"


# Execute function, respects dry run option
execute(){
	echo " COMMAND: ${@}"
	if [ "$DRY" = "y" ]; then
		return 0;
	fi
	eval "$@"
}


clear

# Welcome message
echo "Convert XVID, DIVX, ... to H264 (AVC)\n"

# Go through all movie dirs in the root path
for movie_dir_path in "$MOVIE_PATH_OLD"*; do

	MOVIE_PART_COUNTER=0
	movie_dir=`basename "$movie_dir_path"`
	new_movie_dir_path=$MOVIE_PATH_NEW$movie_dir

	echo "\n\n\n---------------- MOVIE $MOVIE_COUNTER: $movie_dir ----------------"

	# Go through all movie files in the movie path
	for movie_file_path in "$movie_dir_path"/*; do

		# Raise movie part counter
		MOVIE_PART_COUNTER=$((MOVIE_PART_COUNTER+1))

		# Set movie_dir and movie_file
		
		movie_file=`basename "$movie_file_path"`
		new_movie_file_path=$MOVIE_PATH_NEW$movie_dir"/"$movie_file

		# Get CODEC of file
		codec=$(mediainfo "$movie_file_path" --Inform="Video;%Codec%")

		# Check if codec is "XVID"
		if [ "$codec" = "XVID" ]; then
			
			echo "\nFILE $MOVIE_PART_COUNTER:"

			echo "  Create new movie directory"
			execute "mkdir -p \"$MOVIE_PATH_NEW$movie_dir\""

			echo "  Used codec of old movie file: "$codec" => Convert to AVC"
			echo "  Old movie file: "$movie_file_path
			echo "  New movie file: "$new_movie_file_path
		
			echo "  Convert XVID to AVC using Handbrake CLI"
			execute "HandBrakeCLI -i \"$movie_file_path\" -o \"$new_movie_file_path\" --preset=\"$HANDBRAKE_PRESET\""

			echo "  Rename new movie extension from avi to m4v"
			execute "mv \"$new_movie_file_path\" \"$MOVIE_PATH_NEW$movie_dir\"\"/\"\"`basename \"$new_movie_file_path\" .avi`.m4v\""

		fi

	done

	echo "\nMOVIE:"
	#echo " Move old movie folder to obsolete folder"
	#execute "mv \"$movie_dir_path\" \"$MOVIE_OBSOLETE\""

	# When the movie part counter > 1
	if [ "$MOVIE_PART_COUNTER" -gt 1 ]; then
		# TODO: This is not working "$f" is not working
		echo "Use ffmpeg to make 1 file out of 2 files"
		execute "ffmpeg -f concat -i <(for f in \"$new_movie_dir_path/\"*.m4v; do echo \"file '\"$f\"'\"; done) -c copy \"$new_movie_dir_path/$movie_dir.m4v\""
	fi

	# TODO: Delete the original 2 files "CD1 and CD2"
	
	# Break when movie counter exceeds max movie amount
	if [ $MOVIE_COUNTER -eq $MAX_MOVIE_AMOUNT ]; then
		break
	fi

	# Raise counter
	MOVIE_COUNTER=$((MOVIE_COUNTER+1))
	
done

echo "\n\n\n"

