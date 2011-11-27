#!/bin/bash

TSMUXER=tsMuxeR

USAGE="Usage: $0 source-m2ts-dir dest-ts-dir"

set -e

if [ "$#" != "2" ]; then
	echo "$USAGE"
	exit 1
fi

cd "$1"
SOURCE=`pwd`

for fn in *.MTS; do
	# need a temp file because tsmuxer expects a name ending in .meta :-(
	METAFILE=$(tempfile -s.meta)
	trap "rm -- '$METAFILE'" EXIT
	cat >"$METAFILE" <<CONTENT
MUXOPT --no-pcr-on-video-pid --new-audio-pes --vbr  --vbv-len=500
V_MPEG4/ISO/AVC, "$SOURCE/$fn", fps=29.970, insertSEI, contSPS, track=4113
A_AC3, "$SOURCE/$fn", track=4352
CONTENT

	$TSMUXER "$METAFILE" "$2/${fn/.MTS}.ts"
	rm -- "$METAFILE"
	trap - EXIT
done
