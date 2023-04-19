#!/bin/bash
## $PROG 1.0 - Pull price and demand data from AEMO [2023-04-19]
## Usage: $PROG [OPTION...] [COMMAND]...
## Options:
##   -s, --start            Set start date YYYYMM
##   -e, --end              Set end date (inclusive) YYYYMM
##   -r, --region           Set region to retrieve [NSW|QLD|VIC|SA|TAS]
##   -o, --outfile          Set file to write aggregated output
## Commands:
##   -h, --help             Display this help and exit
##   -v, --version          Display output version and exit
## Examples:
##   $PROG -s 201502 -e 201602 -r NSW -o AEMO_PD_NSW_201502_201602.csv
##   $PROG -s 202202 -e 202302 -r SA -o ../data/AEMO_PD_SA_202202_202302.csv
PROG=$(basename $0)

# Define help printout
help() {
  grep "^##" "$0" | sed -e "s/^...//" -e "s/\$PROG/$PROG/g"
}

# Parse options
while getopts 's:e:r:o:hv' opt; do
  case "$opt" in
    s) START="$OPTARG";;
    e) END="$OPTARG";;
    r) REGION="$OPTARG";;
    o) OUTFILE="$OPTARG";;
    h) help; exit 0;;
    v) help | head -1; exit 0;;
    :|?|h) help; exit 1;;
  esac
done
shift "$(($OPTIND -1))"

# Define base URL strings
URLHEAD="https://aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND"
URLTAIL="1.csv"

# Alert user to options in use
echo "Retrieving $REGION from $START to $END and writing to $OUTFILE"

# Retrieve and write first month, preserving header
curl -s -o $OUTFILE "${URLHEAD}_${START}_${REGION}${URLTAIL}"

# Filter valid months from naive integer sequence
months=`seq $((START+1)) $END | egrep '^[0-9]{4}(0[1-9]|1[0-2])$'`

# Retrieve each month from AEMO site
for month in $months; do
  url="${URLHEAD}_${month}_${REGION}${URLTAIL}"
  curl -s $url | tail -n +2 >> $OUTFILE
done
