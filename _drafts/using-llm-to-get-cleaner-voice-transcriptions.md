---
layout: post
title: Using LLM to get cleaner voice transcriptions
categories: AI
date: 2024-01-17 22:20:00 +01:00
excerpt_separator: <!--more-->
---
Transcribing natural speech is a challenging task for voice-to-text services. When using traditional transcription tools, speakers are expected to talk slowly and clearly, avoiding fillers like "um" and "uh" as much as possible. However, this puts a huge cognitive load on the speaker to monitor every word before it's spoken. Suddenly, having a normal conversation becomes an artificial performance.

Recent advances in natural language processing have enabled a better approach - transcribing first, then cleaning up the transcript afterward using a language model. The key insight is that language models can leverage contextual information and an understanding of language semantics to automatically fix many common mistakes and disfluencies in a transcript. 

For example, say I'm giving an informal presentation and say:

"The, uh, model, uh no, algorithm, um, is able to...correct itself, uh, when it makes erroneous, uh, predictions..." 

A language model could process this rough transcript and output: 

"The algorithm is able to correct itself when it makes erroneous predictions."
<!--more-->

By postponing the error correction to a second stage, the burden is removed from the speaker to be unnaturally precise. The transcript reflects the natural cadence and flow of human speech, but is still converted to an accurate written form.

## Build this solution using AWS

AWS provides many AI services that can do this for us without extensive codeing.  Amazon Transcribe is an automatic speech recognition service that makes it easy to add speech to text capabilities to applications. Amazon Bedrock is a service that allows you to run Claude v2.1, Anthropic's LLM, to improve text like transcripts.

The code below uses `bash` on macOS. It depends on `sox` to record audio, `curl` and `jq` to interact with APIs, `pbcopy` to copy text to the clipboard, and the AWS CLI to interact with AWS services. To install `sox`, `curl`, `jq`, and `pbcopy`, use Homebrew with the command `brew install sox curl jq pbcopy`. The AWS CLI can be installed by following the instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). 

When using Amazon Transcribe for speech-to-text transcription, you'll need to create an Amazon S3 bucket to store the audio recording files. It's recommended to configure a lifecycle policy on the S3 bucket to automatically delete files after a set period of time. You'll also need to configure the AWS CLI with credentials that have permissions to put objects in the S3 bucket. See [this documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html) on how to setup authentication for your AWS CLI.

```bash
#!/bin/bash
TEMPJOB=recording-$(uuidgen)
TEMPFILE=${TEMPJOB}.flac
S3BUCKET=my-s3-bucket-name

echo "Recording"
echo "Press Ctrl+C to stop the recording"
# sox -d ${TEMPFILE} silence 1 0.1 3% 1 2.0 3%
sox -d "${TEMPFILE}"

echo "Uploading"
aws s3 cp "${TEMPFILE}" "s3://${S3BUCKET}/recordings/${TEMPFILE}" --profile transcribe

echo "Transcribing"
aws transcribe start-transcription-job --profile transcribe --transcription-job-name "${TEMPJOB}" --media "MediaFileUri=s3://${S3BUCKET}/recordings/${TEMPFILE}" --language-code=en-US --no-cli-pager
while [ "$(aws transcribe get-transcription-job --profile transcribe --transcription-job-name "${TEMPJOB}" --query "TranscriptionJob.TranscriptionJobStatus" --output text)" = "IN_PROGRESS" ];
do 
	aws transcribe get-transcription-job --profile transcribe --transcription-job-name "${TEMPJOB}" --query "TranscriptionJob.TranscriptionJobStatus" --output text --no-cli-pager
	echo "Transcribing..."
	sleep 1
done
echo "Getting transcription"
TRANSCRIPTURL=$(aws transcribe get-transcription-job --transcription-job-name "${TEMPJOB}" --profile transcribe | jq '.TranscriptionJob.Transcript.TranscriptFileUri' --raw-output)
TRANSCRIPTION="$(curl "$TRANSCRIPTURL" --connect-timeout 5 | jq '.results.transcripts[0].transcript' --raw-output)"
echo "$TRANSCRIPTION" > raw_transcription.txt


echo "Sending to Bedrock for cleaning"
PAYLOAD=$(echo "{ \"prompt\": \"Human: clean up this voice transcription. Remove any filler words, typos and correct any words that is not in the context. If I correct myself, only include the corrected version. Only output the cleaned transcript, do not say anything like 'Here is the cleaned up transcript' in the beginning. Transcript start after the '---' line.\n---\n${TRANSCRIPTION}\n\nAssistant: \", \"max_tokens_to_sample\": 2048, \"temperature\": 1.0, \"top_k\": 250, \"top_p\": 1, \"stop_sequences\": [ \"\\n\\nHuman:\" ], \"anthropic_version\": \"bedrock-2023-05-31\" }" | base64)

aws bedrock-runtime invoke-model \
	--no-cli-pager \
	--model-id "anthropic.claude-v2:1" \
	--body "${PAYLOAD}" \
	cleaned_output.json > /dev/null
CLEANED=$(jq -r '.completion' cleaned_output.json)

echo "${CLEANED}" | pbcopy
echo "Copied to clipboard: ${CLEANED}"

echo -n "Do you want to keep all the temporary files? (y/n)"
read -r KEEP
if [ "${KEEP}" = "y" ]; then
	echo "Temporary files not deleted"
	echo "You can find the temporary files in the current directory"
else
	rm "${TEMPFILE}"
	rm raw_transcription.txt
	rm cleaned_output.json
	echo "Temporary files deleted"
fi
```

## Code walkthrough
First, it records audio from the microphone using `sox` and saves it as a file locally. We choose to let the user manually stop the recording instead of automatically stopping the recording on silence detection to give user more time to think.

Next, it uploads the audio file to an Amazon S3 bucket for temporary storage. After uploading, the code starts a transcription job on Amazon Transcribe, referencing the audio recording in S3.

Once started, the code periodically checks the status of the transcription job until it is marked as completed. This may take some time depending on the length of the audio. 

When done, the transcript text is retrieved from Transcribe and sent to Amazon Bedrock . We use the Claude v2.1 model by Antropic. Claude reviews the transcript to clean up any errors and formatting issues, producing a polished text document. Be careful that the `aws bedrock-runtime invoke-model` command expects a base64 encoded, well-formatted JSON payload. The Claude v2.1 model also expect the prompt to start and end with "Human: ... Assistant:". You can play around with the prompt and the LLM parameters to see if you can get even better results. 

The cleaned transcript is then copied to the system clipboard for easy pasting. Finally, the code can optionally keep the temporary audio and transcript files for debugging.

## Future improvements
This is just a very basic example, future improvements could be made in the following ways:

* Use real-time transcription to reduce waiting times for results.
* Fine-tune the cleanup prompt to increase efficiency and accuracy. 
* Allow users to select preferred output styles and formats.
* Formatting and serializing (and base64 encoding) the payload to the Bedrock CLI is very tricky. Implement the script in Python or another programming language with AWS SDK can avoid the complexity of bash scripting.

In conclusion, by utilizing services like Amazon Transcribe for the speech recognition coupled with Bedrock to provide natural language understanding, two-stage speech recognition solutions allow for a more natural speaking style while still producing an accurate transcript. Rather than building complex speech recognition systems from scratch, you can leverage robust cloud services and be productive right away.

