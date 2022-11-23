#!/bin/bash
FILE=$1
OUTPUT=$2
#New ration
RATIO_W=13
RATIO_H=9

# jpegtran and imagemagic convert needed
HEIGHT=$(convert "$1" -print "%h\n" /dev/null)
WIDTH=$(convert "$1" -print "%w\n" /dev/null)

EXPECTED_WIDTH_1=$(( $HEIGHT * $RATIO_W / $RATIO_H ))
EXPECTED_HEIGHT_1=$(( $WIDTH * $RATIO_H / $RATIO_W ))
EXPECTED_WIDTH_2=$(( $HEIGHT * $RATIO_H / $RATIO_W ))
EXPECTED_HEIGHT_2=$(( $WIDTH * $RATIO_W / $RATIO_H ))
ADDED_WIDTH_AREA_1=$(( ($HEIGHT * $EXPECTED_WIDTH_1) - ($HEIGHT * $WIDTH) ))
ADDED_HEIGHT_AREA_1=$(( ($EXPECTED_HEIGHT_1 * $WIDTH) - ($HEIGHT * $WIDTH) ))
ADDED_WIDTH_AREA_2=$(( ($HEIGHT * $EXPECTED_WIDTH_2) - ($HEIGHT * $WIDTH) ))
ADDED_HEIGHT_AREA_2=$(( ($EXPECTED_HEIGHT_2 * $WIDTH) - ($HEIGHT * $WIDTH) ))


if [ $ADDED_HEIGHT_AREA_1 -lt 0 ] || [ $ADDED_WIDTH_AREA_1 -lt $ADDED_HEIGHT_AREA_1 ] && [ $ADDED_WIDTH_AREA_1 -gt -1 ]; then
WIN_HEIGHT_1=$HEIGHT
WIN_WIDTH_1=$EXPECTED_WIDTH_1
    else
WIN_HEIGHT_1=$EXPECTED_HEIGHT_1
WIN_WIDTH_1=$WIDTH
fi

if [ $ADDED_HEIGHT_AREA_2 -lt 0 ] || [ $ADDED_WIDTH_AREA_2 -lt $ADDED_HEIGHT_AREA_2 ] && [ $ADDED_WIDTH_AREA_2 -gt -1 ]; then
WIN_HEIGHT_2=$HEIGHT
WIN_WIDTH_2=$EXPECTED_WIDTH_2
    else
WIN_HEIGHT_2=$EXPECTED_HEIGHT_2
WIN_WIDTH_2=$WIDTH
fi


ADDED_AREA_1=$(( ($WIN_HEIGHT_1 * WIN_WIDTH_1) - ($HEIGHT * $WIDTH) ))
ADDED_AREA_2=$(( ($WIN_HEIGHT_2 * WIN_WIDTH_2) - ($HEIGHT * $WIDTH) ))

if [ $ADDED_AREA_1 -lt $ADDED_AREA_2 ] ; then
    WIN_HEIGHT=$WIN_HEIGHT_1
    WIN_WIDTH=$WIN_WIDTH_1
else
    WIN_HEIGHT=$WIN_HEIGHT_2
    WIN_WIDTH=$WIN_WIDTH_2
fi


if [ $WIN_HEIGHT -gt $WIN_WIDTH ]; then
    if [ $WIN_HEIGHT -eq $HEIGHT ] && [ $WIN_WIDTH -eq $WIN_WIDTH ]; then
        echo "$FILE - size H $WIDTH x $HEIGHT expected $EXPECTED_WIDTH_1 x $HEIGHT ($ADDED_WIDTH_AREA_1) or $WIDTH x $EXPECTED_HEIGHT_1 ($ADDED_HEIGHT_AREA_1). Win $WIN_WIDTH x $WIN_HEIGHT - only rotate"
        cat "$FILE" | jpegtran -rotate 90 > "$OUTPUT"
    else
        echo "$FILE - size H $WIDTH x $HEIGHT expected $EXPECTED_WIDTH_1 x $HEIGHT ($ADDED_WIDTH_AREA_1) or $WIDTH x $EXPECTED_HEIGHT_1 ($ADDED_HEIGHT_AREA_1). Win $WIN_WIDTH x $WIN_HEIGHT - extend and rotate"
        convert "$FILE" -gravity center -extent ${WIN_WIDTH}x$WIN_HEIGHT - | jpegtran -rotate 90 > "$OUTPUT"
    fi
else
    if [ $WIN_HEIGHT -eq $HEIGHT ] && [ $WIDTH -eq $WIN_WIDTH ]; then
        echo "$FILE - size H $WIDTH x $HEIGHT expected $EXPECTED_WIDTH_1 x $HEIGHT ($ADDED_WIDTH_AREA_1) or $WIDTH x $EXPECTED_HEIGHT_1 ($ADDED_HEIGHT_AREA_1). Win $WIN_WIDTH x $WIN_HEIGHT - copy"
        cp "$FILE" "$OUTPUT"
    else
        echo "$FILE - size H $WIDTH x $HEIGHT expected $EXPECTED_WIDTH_1 x $HEIGHT ($ADDED_WIDTH_AREA_1) or $WIDTH x $EXPECTED_HEIGHT_1 ($ADDED_HEIGHT_AREA_1). Win $WIN_WIDTH x $WIN_HEIGHT - extend"
        convert "$FILE" -gravity center -extent ${WIN_WIDTH}x$WIN_HEIGHT "$OUTPUT"
    fi
fi
