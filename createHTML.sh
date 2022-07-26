#!/bin/bash
# Felipe Giuste
# 2022-07-25
# Create a website which pronounces the provided word/name

# https://www.redhat.com/sysadmin/arguments-options-bash-scripts
Help()
{
    # Display Help
    echo "Create and open website with word of interest pronunciation"
    echo
    echo "Syntax: createHTML [-w|--word] [-o|--ofile] [-h|--help]"
    echo "Options:"
    echo "w     word to translate."
    echo "L     2-letter language code."
    echo "o     Output html file."
    echo "h     Print this Help."
    echo
    exit
}

# Check if no argument list
if [ "${1:-}" == "" ]
then
  echo 'Missing Arguments'
    Help
fi


# https://stackoverflow.com/questions/9271381/how-can-i-parse-long-form-arguments-in-shell
word_of_interest='hello'
ofile='/data/translator.html'
lang='zh'
while [ "${1:-}" != "" ]; do
case "$1" in
    "-w" | "--word")
        shift
        word_of_interest=${1}
        ;;
    "-o" | "--ofile")
        shift
        ofile=${1}
        ;;
    "-L" | "--language")
        shift
        lang=${1}
        ;;
    "-h" | "--help")
        Help
        exit 1
        ;;
    \?) 
        echo "Error: Invalid option"
        Help
        exit 1
        ;;
    --)
        shift
        break
        ;;
    *)
        Help
        exit 1
        ;;
esac
shift
done


# Generate HTML
GenerateHTML()
{
    echo 'Running...'
    echo ${1} # Phrase to translate
    echo ${2} # Output HTML path
    touch ${2}

    ## Note: This is the URL encoded chinese spelling! Required to get the Chinese interpretation
    # Change % -> percent and remove redundant Chinese character for % after translation
    encoded_word=`echo "${1}" | sed 's/%/ percent/g'`
    encoded_word=`docker run -it --rm soimort/translate-shell -b ":${lang}" "${encoded_word}" | tr -d '的'`
    if [ $? -ne 0 ]
    then
        echo 'Translation Unsuccessful';
        exit 1
    fi
    echo 'Translated'
    encoded_word="\"${encoded_word}\""
    echo ${encoded_word}
    echo
    encoded_word=`echo "${encoded_word}" | xxd -p | tr -d '\n' | sed 's/../%&/g' | tr '\n' '+'`
    # encoded_word=`docker run --rm python python -c "import urllib.parse; print(urllib.parse.quote(${encoded_word}) )" | tr -d '\n' sed 's/../%&/g' | tr '\n' '+'`
    if [ $? -ne 0 ]
    then
        echo 'Encoding Unsuccessful';
        exit 1
    fi
    echo 'Encoded String'
    echo ${encoded_word}
    echo

    # Fetch Audio file from URL-encoded word
    # audio_base64=`curl "https://www.google.com/async/translate_tts?ei=A_DeYs2lHdCwqtsPj8is4AY&yv=3&ttsp=tl:zh-CN,txt:${encoded_word},spd:1&cs=0&async=_fmt:jspb" --compressed | grep -o '\[.*\]' | sed 's/[][]//g' | sed 's/"//g'`
    # audio_base64=`wget -q -O - "https://www.google.com/async/translate_tts?ttsp=tl:zh-CN,txt:${encoded_word},spd:1&cs=0&async=_fmt:jspb" | grep -o '\[.*\]' | sed 's/[][]//g' | sed 's/"//g'`
    if [ ${lang} == 'fr' ]
    then
        echo 'French'
        # French pronunciation
        audio_base64=`wget -q -O - "https://www.google.com/async/translate_tts?ttsp=tl:fr,txt:${encoded_word},spd:1&cs=0&async=_fmt:jspb" | grep -o '\[.*\]' | sed 's/[][]//g' | sed 's/"//g'`
    else
        echo 'Chinese'
        # Chinese pronunciation
        audio_base64=`wget -q -O - "https://www.google.com/async/translate_tts?ttsp=tl:zh-CN,txt:${encoded_word},spd:1&cs=0&async=_fmt:jspb" | grep -o '\[.*\]' | sed 's/[][]//g' | sed 's/"//g'`
    fi

    if [ $? -ne 0 ]
    then
        echo 'TTS Unsuccessful';
        exit 1
    fi
    echo 'TTS'
    echo ${audio_base64}
    echo


    cat > ${2} << EOF
      <!DOCTYPE html>
      <html>
        <head>
          <title>New Page</title>
          <script>
          function myFunction() {
          (document.getElementById("audioRecordDownload")).click();
          }
          </script>
        </head>
        <body>
          <h1>Hello!</h1>
        
          <audio controls="controls" autobuffer="autobuffer" autoplay="autoplay">
            <source src="data:audio/mp3; base64, ${audio_base64}" />
          Your browser does not support the audio element.
          </audio>

          <button onclick="myFunction()">Download</button>
          <a style="display:none" download="audio-file" id="audioRecordDownload" href="data:audio/mp3; base64, ${audio_base64}">Download audio</a>

        </body>
      </html>
EOF


    if [ $? -ne 0 ]
    then
        echo 'Unsuccessful';
        exit 1
    else
        echo 'Completed';
    fi
}

# Check if last command failed ($? is last exit command)
if [ $? -ne 0 ]
then
    Help
fi

GenerateHTML "${word_of_interest}" "${ofile}"

# Open HTML
# google-chrome translator.html