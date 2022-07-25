# Translator
- Felipe Giuste
- 2022-07-25
  
## Builde Docker Image locally (if needed)
```
docker build -t fgiuste/translator .
```
  
## Word to translate
```
word='hello'
```
  
## Run docker container to create html file with Audio file of translated word, also open created html in google-chrome
```
docker run -it --rm --name translator -v ${PWD}:/data:rw -v /var/run/docker.sock:/var/run/docker.sock fgiuste/translator sh /code/createHTML.sh -w ${word} -o /data/translator.html && google-chrome translator.html
```
