FROM debian:buster-slim

ARG DEBIAN_FRONTEND=noninteractive

# Installed packages
# - emacs without GUI support (for org mode)
# - whole latex suite
# - fonts-liberation2: free equivalent of microsoft fonts
# - graphviz: create graphs with latex
# - jq: json output parser
# - python3-pygments: syntax highlight
RUN apt -yq update && apt -yq upgrade && \
    apt install -yq emacs-nox \
        texlive-full texlive-humanities texlive-pictures texlive-publishers texlive-science \
        fonts-liberation2 \
        graphviz \
        jq \
        python3-pygments

# Cleanup apt cache to reclaim some space
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /root/project

COPY src /root/src

RUN chmod +x /root/src/run.sh

CMD "/root/src/run.sh"
