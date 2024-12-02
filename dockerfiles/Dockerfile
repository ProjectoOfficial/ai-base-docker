# OS SETTINGS
# Here you can choose the OS and the CUDA version you want to mount 

FROM nvidia/cuda:12.0.1-devel-ubuntu22.04


# other examples:
# FROM ubuntu:22.04 # only ubuntu without CUDA
# FROM nvidia/cuda:11.7.1-base-ubuntu22.04
# FROM nvidia/cuda:11.3.1-base-ubuntu20.04 # supports python 3.8 - 3.9
# FROM nvidia/cuda:11.8.0-base-ubuntu18.04 # supports python 3.6 - 3.7
# FROM nvidia/cuda:11.1.1-devel-ubuntu20.04 # supports python 3.8 - 3.9
# FROM nvidia/cuda:11.8.0-devel-ubuntu18.04 # supports python 3.6 - 3.7

# you can find more versions here:
# https://hub.docker.com/r/nvidia/cuda/
# https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=base-ubuntu


# -----------------------------------------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT SETTINGS
# In this section we want to specify which softwares we want to pre-install within the docker

# to be sure we set non interactive bash also here
ENV DEBIAN_FRONTEND=noninteractive

# configuration for x11 forwarding
LABEL com.nvidia.volues.needed="nvidia-docker"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y -q \
    x11-apps mesa-utils && rm -rf /var/lib/apt/lists/*

# remove all the packages within Debian base configuration (not wasting time installing things that will not be used)
RUN rm -f /etc/apt/sources.list.d/*.list

# install Ubuntu Software needed for the development (DEBIAN_FRONTEND="noninteractive" needed to avoid human interaction in the process)
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" && apt-get install -y -q\
    sudo \
    nano \
    tmux \
    git \
    curl \
    wget \
    bash \
    bash-completion \
    build-essential \
    ffmpeg \
    python3.11 \
    python3.11-dev \
    python3-pip \
    python3-tk \
&& rm -rf /var/lib/apt/lists/*

# set python update alternatives - the highest is the preferred one
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
RUN update-alternatives --config python3

# remove python2
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# USER SETTINGS

# the docker's user will be $USER and its home will be '/$USER/home'
ARG UID=1000
ARG GID=1000
ARG USER_NAME=user
ARG USER_HOME=/home/$USER_NAME

# create a new user within the Docker container
RUN groupadd -g $GID -o $USER_NAME \
    && useradd -m -u $UID -g $GID -o -s /bin/bash $USER_NAME \
    && echo "$USER_NAME:Docker!" | chpasswd \
    && mkdir -p /src && chown -R $USER_NAME:$USER_NAME /src \
    && mkdir -p /etc/sudoers.d \
    && usermod -aG video $USER_NAME \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# FINAL SETUPS

# upgrade python pip
RUN pip install --upgrade pip

# install python packages in requirements directory
# project/
# |-- ai-base-docker/
# |   |   |-- build.sh
# |   |   |-- Dockerfile
# |   |   |-- run.sh
# |-- src/
# |   |   |-- model/
# |   |   |-- utils/
# |   |   |-- requirements/
# |   |       |-- base.txt
# |   |       |-- devel.txt

RUN mkdir -p ./tmp
COPY ./src/requirements/* ./tmp/

RUN for file in ./tmp/*; do \
        python3 -m pip install -r $file; \
    done

# .WHL INSTALL: if you need to download .whl packages from a link
# RUN python -m pip download --only-binary :all: --dest . --no-cache PACKAGE-DOWNLOAD-LINK.whl

# CONDA ENVIRONMENT INSTALL: if you need to use a conda environment within the docker
# ENV CONDA_DIR /opt/conda
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda
# ENV PATH=$CONDA_DIR/bin:$PATH

# COPY ../src/environment.yml ./tmp/environment.yml
# RUN conda env create -f tmp/environment.yml
# RUN /bin/bash -c "conda init bash"
# RUN echo "source /opt/conda/bin/activate your_environment_name" >> /home/${USER_NAME}/.bashrc

# --- ROS NOETIC (you must use Ubuntu 20.04) ---
#RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list

# RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
# RUN apt-get update 
# RUN apt-get install -y -q ros-noetic-desktop-full
# RUN apt-get install -y -q \
#         python3-rosdep \
#         python3-rosinstall \
#         python3-rosinstall-generator \
#         python3-wstool \
#         build-essential

# RUN echo '#!/bin/bash\nsource /opt/ros/noetic/setup.bash\nexec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

USER $USER_NAME
WORKDIR $USER_HOME
# ENTRYPOINT ["/entrypoint.sh"] # Always for ROS

# remove all the created/copied/moved file by the docker
RUN rm -rf *

# when the container is launched it will start a bash session
CMD ["/bin/bash"]
