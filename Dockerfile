FROM debian:stable

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update
RUN apt-get -yq upgrade

# install emacs for org mode
RUN apt-get -yq install emacs

# install latex
RUN apt-get -yq install texlive-full
RUN apt-get -yq install texlive-humanities
RUN apt-get -yq install texlive-pictures
RUN apt-get -yq install texlive-publishers
RUN apt-get -yq install texlive-science

# install fonts
RUN apt-get -yq install fonts-liberation2 # free equivalent of microsoft fonts

RUN apt-get -yq install jq # json parser

# Set the working directory
WORKDIR ~/project

COPY src ~/src
COPY emacs.d/ ~/.emacs.d

RUN chmod +x -R ~/src/

CMD "~/src/run.sh"
