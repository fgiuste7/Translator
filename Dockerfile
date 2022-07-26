# fgiuste/translator
# 2022-07-25

FROM docker
# NB: sh not bash

#-----------------------------
# Non-interactive Frontend 
# Prevents installation stalls
#-----------------------------
ENV DEBIAN_FRONTEND=noninteractive 

#--------------------------
# Create new user: mainuser
#--------------------------
USER root
RUN adduser -D mainuser

#---------------------------
# Change Folder Permissions:
#---------------------------
USER root
# RUN chmod -R 777 /home/mainuser && chmod a+s /home/mainuser
RUN mkdir -p /code && chmod -R 777 /code
RUN mkdir -p /data && chmod -R 777 /data

#------------------------------
# Copy Script into Code directory:
#------------------------------
# USER mainuser 
COPY --chown=mainuser ./createHTML.sh /code/

#-----------------------------------------------
# Command: Run script to process PDFs in folder:
#-----------------------------------------------
# USER mainuser
CMD ["/bin/sh", "./createHTML.sh"]

#-------------------------
# Login as user: mainuser:
#-------------------------
# USER mainuser
WORKDIR /code

# docker build -t fgiuste/translator .
# phrase='hello'
# docker run -it --rm --name translator -v ${PWD}:/data:rw -v /var/run/docker.sock:/var/run/docker.sock fgiuste/translator sh createHTML.sh -w "${phrase}" && google-chrome translator.html