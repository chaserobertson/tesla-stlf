#!/bin/bash

# Extract data directory name from script argument
DIR=$1

# Specify name of aggregate output file
OUTFILE="au_sa_total_load_5_min.csv"

# Column indices to select from each file in directory
COLS="2,3,4"

# List files in given directory and store as array of filenames
FILES=($(ls $DIR))

# Store the first line of the first listed file
FULL_HEADER=$(head -n1 "$DIR/${FILES[1]}")

# Select specified column names from header
HEADER=$(echo $FULL_HEADER | cut -d, -f $COLS)

# Overwrite output file with subset of header
echo $HEADER > $OUTFILE

# For each file, append column subset of all non-header lines to output file
for f in ${FILES[@]}; do
  tail -n +2 "$DIR/$f" | cut -d, -f $COLS >> $OUTFILE
done

# Output number of lines in resulting file
wc -l $OUTFILE

