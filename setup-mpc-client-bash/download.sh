#!/bin/bash
set -e

: ${API_URL=http://localhost:8081}
: ${TRANSCRIPTS=20}
: ${SETUP_DIR=$(pwd)/setup_db}

mkdir -p $SETUP_DIR
rm -f $SETUP_DIR/*
for TRANSCRIPT in $(seq 0 $[TRANSCRIPTS - 1]); do
  echo Downloading transcript $PREV_ADDRESS/$TRANSCRIPT...
  curl -s -S $API_URL/api/data/$PREV_ADDRESS/$TRANSCRIPT > $SETUP_DIR/transcript$TRANSCRIPT.dat
done