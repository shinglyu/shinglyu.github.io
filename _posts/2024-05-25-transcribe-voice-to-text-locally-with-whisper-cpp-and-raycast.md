---
layout: post
title: Transcribe voice to text locally with Whisper.cpp and Raycast
categories: AI
date: 2024-05-25 21:34:00 +02:00
excerpt_separator: <!--more-->
---
## Why local transcription?

In today's world, many of us rely on cloud-based services for tasks like speech-to-text transcription. While these services are convenient, they come with drawbacks like high latency due to network transfers and potential privacy concerns as our audio data is sent to the cloud.

Local transcription addresses these issues by performing the speech recognition process entirely on your device, ensuring low latency and keeping your audio data private. This is where whisper.cpp comes in.
<!--more-->
## What is whisper.cpp?

Whisper.cpp is a high-performance implementation of OpenAI's Whisper automatic speech recognition model. It's written in C/C++ with no dependencies, making it lightweight and efficient. Key features of whisper.cpp include:

- Support for various platforms like macOS, Linux, Windows, and even mobile (iOS, Android)

- Optimized for Apple Silicon with ARM NEON, Accelerate, and Metal/Core ML

- Mixed precision support (F16/F32) and integer quantization for reduced memory usage

- GPU acceleration via CUDA (NVIDIA), OpenCL, and more

In this blog post, we are going to set up Whisper.cpp on MacOS for local voice to text transcription. Then, we'll write a wrapper script to allow easy invocation from Raycast, a popular productivity tool that enables users to streamline various tasks with customizable keyboard shortcuts and integrations.

# How to set up this Whisper.cpp

Setting up the whisper.cpp project on macOS involves the following steps:

1. Clone the whisper.cpp repository and navigate into it:

```bash
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
```

2. Download a pre-converted Whisper model in the ggml format. For example, to get the base English model:

```bash
bash ./models/download-ggml-model.sh base.en
```

3. Build the main example:

```bash
make
```

4. Transcribe an audio file:

```bash
./main -m models/ggml-base.en.bin -f /path/to/audio.wav
```

Later in the post we'll show you how to easily record the `.wav` file from command-line.

## Playing with multiple languages

I speak Mandarin Chinese and English, so transcribing Chinese mixed with English is an interesting use case for me.

To transcribe audio with a mix of Chinese and English, simply set `--language auto` and do NOT set `--translate`. This will auto-detect the language and transcribe accordingly.

The above command runs the transcription tool on a mixed-audio file located at `/path/to/mixed-audio.wav`, using the `ggml-base.en.bin` model. The `--language auto` option instructs the tool to automatically detect the language of the audio file.

The `--translate` option is a unique feature of this transcription tool that sets it apart from traditional transcription tools. When this option is used, the tool not only transcribes the audio but also translates the transcription into the specified target language. This is particularly useful for multilingual contexts or when working with audio files in languages different from the user's native language.

An interesting observation is that when using Chinese on smaller models, whisper would hallucinate. For example, I said "中文測試" (Chinese test), the transcription becomes:

```
中文測試
劇終
[CC 字幕組]
```

(Chinese test

The End

CC subtitle group)

You commonly see this at the end of the unofficial Chinese subtitle of pirated movies, suggesting that Whisperer is trained on pirated movie subtitles scrapped from the internet.

But overall, the transcription quality is pretty good even for small models, the it can finish within seconds.

## Integrating with Raycast for one-click transcription

Raycast is a popular productivity launcher for macOS that allows you to create custom scripts and workflows. Here's how to integrate whisper.cpp with Raycast for convenient one-click transcription:

1. Create a new script named `transcribe.sh` with the following content. This script captures audio, runs whisper.cpp transcription, and copies the result to your clipboard:

```bash
WHISPER_CPP_PATH=/Users/shinglyu/whisper.cpp
MODEL=models/ggml-small.bin
RECORDING_PATH=/Users/shinglyu/recordings/
RECORDING_FILE="${RECORDING_PATH}/recording-$(date +%s).wav"
TRANSCRIPTION_FILE="${RECORDING_FILE}.txt"
sox -d -r 16000 -c 1 -b 16 "${RECORDING_PATH}/recording-$(date +%s).wav"

cd "${WHISPER_CPP_PATH}"
./main -m "${MODEL}" -f "${RECORDING_FILE}" -otxt "${TRANSCRIPTION_FILE}" --language auto

echo "Transcription:"
echo "--------------"
cat "${TRANSCRIPTION_FILE}"
echo "--------------"

# copy the file content to clipboard
pbcopy < "${TRANSCRIPTION_FILE}"
echo "Copiled to clipboard"
```

Sox (Sound eXchange) is a cross-platform command-line utility that can record, play, and convert various audio file formats. The clipboard part involves the `pbcopy` command, which is a utility on macOS that copies the input data to the system clipboard.

The script sets up various paths and filenames, records audio using Sox with a sample rate of 16000 Hz, mono channel, and 16-bit depth, and saves it as a WAV file. Next, it navigates to the Whisper.cpp directory and runs the `main` executable, passing in the model file, recorded audio file, and output text file paths. The transcription is then printed to the console and copied to the clipboard using `pbcopy`. The final line outputs the message "Copied to clipboard" to indicate the operation's success.

2. Create a Raycast script that opens a terminal window and runs the transcription script:

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

osascript <<EOF

    tell application "iTerm2"
         create window with default profile
         tell current session of current window
              delay 1
              write text "cd $(pwd)"
              write text "./transcribe.sh"
          end tell
    end tell
EOF
```

This code is a Bash script that opens a new iTerm2 window and runs the `transcribe.sh` script in the current directory. The script uses the `osascript` command to interact with the macOS scripting environment and automate the iTerm2 application. The `tell` statements are used to send commands to iTerm2, such as creating a new window, navigating to the current directory, and executing the `transcribe.sh` script. The delay of 1 second is added to ensure that the commands are executed in the correct order.

Now, you can simply invoke the "Transcribe" command in Raycast, and it will capture audio, transcribe it locally using whisper.cpp, and copy the transcription to your clipboard – all with just one click!

## Further reading: clean up the transcription

If you find the quality of the transcription is not good enough, you can clean them up with LLMs using the method outlined here: [Using LLM to get cleaner voice transcriptions]({{site_url}}/ai/2024/01/17/using-llm-to-get-cleaner-voice-transcriptions.html). You can also use LLM to summarize, or rewrite your transcription into bullet points. There are commercial products like [AudioPen](https://audiopen.ai/) but you can easily roll your own.

## Conclusion:

Whisper.cpp brings OpenAI's powerful Whisper speech recognition model to your local device, ensuring low latency and privacy. Combined with Raycast's convenience, you can now enjoy seamless, one-click local transcription on your Mac. Give it a try and experience the power of on-device speech recognition!