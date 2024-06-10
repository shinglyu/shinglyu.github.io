---
layout: post
title: Streamline my local transcription command for Raycast
categories: AI
date: 2024-06-10 16:00:00 +02:00
excerpt_separator: <!--more-->
---


In my previous [blog]({{site_url}}/ai/2024/05/25/transcribe-voice-to-text-locally-with-whisper-cpp-and-raycast.html), I asked Raycast to create an iTerm2 terminal to run the transcription script. This was because I needed to press CTRL+C to stop the `sox` recording. However, I found that launching iTerm2 and `zsh` took a significant amount of time, sometimes up to 5 to 10 seconds, which was too slow for quickly jotting down thoughts.

To address this issue, I discovered a way to stop the sox recording without opening the iTerm terminal. Instead of using CTRL+C, I can send a kill signal to the `sox` process. To achieve this, I utilize some shell script tricks to save the PID (Process ID) of sox and display a macOS pop-up. When I press the pop-up button, it sends a kill signal to the sox process, effectively stopping the recording.

<!--more-->

Here's the updated code:

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Transcribe
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💬

# Documentation:
# @raycast.description Transcribe with local model
# @raycast.author Shing Lyu
# @raycast.authorURL https://shinglyu.com

WHISPER_CPP_PATH=/Users/shinglyu/whisper.cpp
MODEL=models/ggml-small.bin
RECORDING_PATH="${TMPDIR}/transcribe/"
RECORDING_FILE="${RECORDING_PATH}/recording-$(date +%s).wav"
TRANSCRIPTION_FILE="${RECORDING_FILE}.txt"

mkdir $RECORDING_PATH
echo "Press Ctrl-C to stop the recording"
sox -t coreaudio "MacBook Pro Microphone" -r 16000 -c 1 -b 16 "${RECORDING_FILE}" &
pid=$!

# Display a confirmation popup
osascript -e 'tell app "System Events" to display dialog "Press Stop to stop recording" buttons {"Stop"} default button "Stop" with icon caution'

# If the user clicks "Stop", kill the sox process
if [ "$?" -eq 0 ]; then
    kill "$pid"
fi

cd "${WHISPER_CPP_PATH}"
./main -m "${MODEL}" -f "${RECORDING_FILE}" -otxt "${TRANSCRIPTION_FILE}" --language auto

clear
echo "Transcription:"
echo "--------------"
cat "${TRANSCRIPTION_FILE}" | sed 's/^[ \t]*//g' | tr '\n' ' ' | sed 's/  */ /g' | tee pbcopy
echo ""
echo "--------------"

# copy the file content to clipboard
cat "${TRANSCRIPTION_FILE}" | sed 's/^[ \t]*//g' | tr '\n' ' ' | sed 's/  */ /g' | pbcopy
echo "Copied to clipboard"
osascript -e "display notification \"$message\" with title \"Transcription finished\""
```

The key part of this code is the following section:

```bash
sox -t coreaudio "MacBook Pro Microphone" -r 16000 -c 1 -b 16 "${RECORDING_FILE}" &
pid=$!

# Display a confirmation popup
osascript -e 'tell app "System Events" to display dialog "Press Stop to stop recording" buttons {"Stop"} default button "Stop" with icon caution'

# If the user clicks "Stop", kill the sox process
if [ "$?" -eq 0 ]; then
    kill "$pid"
fi
```

This code displays a macOS confirmation pop-up with a "Stop" button. If the user clicks the "Stop" button, it sends a kill signal to the sox process, effectively stopping the recording.

Since we no longer need to open iTerm, we don't require a wrapper AppleScript. This approach allows for a faster and more streamlined transcription process from Raycast. Now the recording starts almost instantaneously after triggering from Raycast.

`TMPDIR` is a special directory on MacOS that serves as a designated location for storing temporary files. Additionally, I changed the output directory to this `TMPDIR`, ensuring that the recorded audio file will be automatically cleaned up after the transcription process is complete. This helps in maintaining a tidy system by preventing the accumulation of unnecessary files.

## Bonus: Opening Bedrock Chat

Since I frequently use Amazon Bedrock's chat through the AWS console, I added a parameter to the script that allows me to immediately open the Bedrock Chat URL. This way, I can either paste what I just said into the chat or type a prompt and then paste my transcription.

```bash
# if $1 is set to `--open-bedrock-chat`, open the URL https://eu-central-1.console.aws.amazon.com/bedrock/home?region=eu-central-1#/chat-playground?modelId=anthropic.claude-3-sonnet-20240229-v1%3A0
if [ "$1" = "--open-bedrock-chat" ]; then
    open "https://eu-central-1.console.aws.amazon.com/bedrock/home?region=eu-central-1#/chat-playground?modelId=anthropic.claude-3-sonnet-20240229-v1%3A0"
    echo "Opened Bedrock Chat"
fi
```

## Bonus 2 : Improving `zsh` Startup

Before implementing the above solution, I tried to speed up the `zsh` startup. While I did manage to make `zsh` launch faster, it was still not fast enough. But it might be useful for you. Here's how I approached it:

1. **Profiling zsh launch**

   To profile the launch time of zsh, I added the following lines to the beginning and end of my `~/.zshrc` file:

   ```zsh

   zmodload zsh/zprof

   # main content of zshrc

   zprof

   ```

   This allowed me to identify the parts of the configuration that were taking the most time. Tuns out that loading `nvm` (a Node.js version manager) takes a lot of time.

2. **Lazy loading nvm (Node Version Manager)**

   I used the `zsh-nvm` plugin to lazy load nvm (Node Version Manager) in zsh. Here's how to set it up with Oh My Zsh:

   - Clone the repository: `git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm`

   - Add the plugin to your `~/.zshrc` file: `plugins+=(zsh-nvm)`

   - Add the lazy loading configuration before the plugin line: `export NVM_LAZY_LOAD=true`


3. **Speed up iTerm2 launch by avoiding ASL log loading**

    To speed up iTerm2 launch time, set the custom command to `/bin/zsh -il` in the profile. This bypasses searching the system ASL logs (reference: [macos - iTerm/Terminal OS X slow in opening a shell - Super User](https://superuser.com/questions/512859/iterm-terminal-os-x-slow-in-opening-a-shell)).

While these steps helped improve the `zsh` startup time, it was still not fast enough for my needs. The updated Whisper.cpp transcription script with the macOS pop-up approach proved to be a more efficient solution.