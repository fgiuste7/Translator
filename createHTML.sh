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
    echo "o     Output html file"
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
ofile='translator.html'
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
    "-h" | "--help")
        Help
        exit
        ;;
    \?) 
        echo "Error: Invalid option"
        Help
        exit
        ;;
    --)
        shift
        break
        ;;
    *)
        Help
        exit
        ;;
esac
shift
done

# Check if last command failed ($? is last exit command)
if [ $? -ne 0 ]
then
    Help
fi

# Generate HTML
GenerateHTML()
{
    echo 'Generating HTML...'
    echo ${1}
    echo ${2}
    touch ${2}

    ## Note: This is the URL encoded chinese spelling! Required to get the Chinese interpretation
    encoded_word=`docker run -it soimort/translate-shell -b :zh ${1} | xxd -p | tr -d \\n | sed 's/../%&/g'`
    if [ $? -ne 0 ]
    then
        echo 'Docker Unsuccessful';
        exit
    fi
    echo ${encoded_word}

    # Fetch Audio file from URL-encoded word
    # audio_base64=`curl "https://www.google.com/async/translate_tts?ei=A_DeYs2lHdCwqtsPj8is4AY&yv=3&ttsp=tl:zh-CN,txt:${encoded_word},spd:1&cs=0&async=_fmt:jspb" --compressed | grep -o '\[.*\]' | sed 's/[][]//g' | sed 's/"//g'`
    audio_base64=`wget -q -O - "https://www.google.com/async/translate_tts?ei=A_DeYs2lHdCwqtsPj8is4AY&yv=3&ttsp=tl:zh-CN,txt:${encoded_word},spd:1&cs=0&async=_fmt:jspb" | grep -o '\[.*\]' | sed 's/[][]//g' | sed 's/"//g'`
    if [ $? -ne 0 ]
    then
        echo 'Fetch Unsuccessful';
        exit
    fi

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
        exit
    else
        echo 'Completed Successfully!';
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