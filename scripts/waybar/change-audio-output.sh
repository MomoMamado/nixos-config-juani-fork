#!/usr/bin/env bash

# Toggle the onboard card between optical (Edifier speakers) and the analog
# jack (headphones). Both live on the same card and can't run at once, so this
# switches card profiles rather than default sinks.

CARD="alsa_card.pci-0000_08_00.6"
SPEAKERS="output:iec958-stereo+input:analog-stereo"
HEADPHONES="output:analog-stereo+input:analog-stereo"

export LC_ALL=C

current=$(pactl list cards | awk -v card="$CARD" '
    $1 == "Name:" { in_card = ($2 == card) }
    in_card && /Active Profile:/ { print $3; exit }')

if [ -z "$current" ]; then
    notify-send "Audio Output" "Sound card $CARD not found" -i dialog-error
    exit 1
fi

if [ "$current" == "$SPEAKERS" ]; then
    target=$HEADPHONES label="Headphones" icon=audio-headphones sink_suffix=analog-stereo
else
    target=$SPEAKERS label="Edifier Speakers" icon=audio-speakers sink_suffix=iec958-stereo
fi

if ! pactl set-card-profile "$CARD" "$target"; then
    notify-send "Audio Output" "Failed to switch to $label" -i dialog-error
    exit 1
fi

# The profile change recreates the sink; wait for it, then make it the default
# so playing streams follow it
sink="alsa_output.${CARD#alsa_card.}.$sink_suffix"
for _ in {1..30}; do
    pactl list sinks short | grep -q "$sink" && break
    sleep 0.1
done

if ! pactl list sinks short | grep -q "$sink"; then
    notify-send "Audio Output" "Switched profile, but $sink did not appear" -i dialog-error
    exit 1
fi

pactl set-default-sink "$sink"

notify-send "Audio Output" "Switched to $label" -i "$icon"
