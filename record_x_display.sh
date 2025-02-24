#!/bin/bash
#
# Ted's screen recorder script
#
# Capture & record desktop with audio, and in re-encode into HD 1080p.
# Must have FFMPEG installed, works best with version 0.8.3 with all the codec installed.  Also make sure you have x11grab installed.

# Variables for the script.
capdate=date +%H-%M-%S-%d-%m-%y
capdir="$HOME/Videos/" #Change this path to wherever you want to save the videos.

# This will do a screen capture of your main monitor.  You will need to change -s option to fit your resolution of your monitor.
ffmpeg -f alsa -ac 2 -i pulse -f x11grab -r 30 -s 1920x1080 -i :0.0 -acodec mp3 -vcodec libx264 -threads 0 -y ${capdir}video-${capdate}.mkv ;

# This will encode the video as H.264 video and resolution of hd1080 or 1920x1080 with AAC audio. It will save the video as a MP4 video.
ffmpeg -i ${capdir}video-${capdate}.mkv -acodec mp3 -ab 128k -ac 2 -vcodec libx264 -s hd1080 -crf 22 -threads 0 ${capdir}youtube-${capdate}.mp4 ;
