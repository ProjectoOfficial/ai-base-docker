# OS SETTINGS
# Here you can choose the OS and the CUDA version you want to mount 

FROM mcr.microsoft.com/azureml/o16n-base/python-assets:20210623.40134510 AS inferencing-assets

FROM nvidia/cuda:11.8.0-devel-ubuntu18.04

# other examples:
# FROM nvidia/cuda:11.7.1-base-ubuntu22.04
# FROM nvidia/cuda:11.3.1-base-ubuntu20.04
# FROM nvidia/cuda:11.8.0-base-ubuntu18.04

# you can find more versions here:
# https://hub.docker.com/r/nvidia/cuda/
# https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=base-ubuntu

USER root:root

ENV com.nvidia.cuda.version $CUDA_VERSION

ENV com.nvidia.volumes.needed nvidia_driver
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64
ENV NCCL_DEBUG=INFO
ENV HOROVOD_GPU_ALLREDUCE=NCCL

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub


# -----------------------------------------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT SETTINGS
# In this section we want to specify which softwares we want to pre-install within the docker

# to be sure we set non interactive bash also here
ENV DEBIAN_FRONTEND=noninteractive

# remove all the packages within Debian base configuration (not wasting time installing things that will not be used)
RUN rm -f /etc/apt/sources.list.d/*.list

# Install necessary packages
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    wget \
    bash \
    bash-completion \
    build-essential \
    ffmpeg \
    python3.7 \
    python3.7-dev \
    python3-pip \
&& rm -rf /var/lib/apt/lists/*

# Set Python alternatives
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
RUN update-alternatives --config python3

# Remove Python 2 links
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# create a new user within the Docker container
ARG USER_NAME=user
ARG USER_HOME=/home/$USER_NAME

RUN useradd -m -s /bin/bash $USER_NAME \
    && echo "$USER_NAME:Docker!" | chpasswd \
    && mkdir -p /src && chown -R $USER_NAME:$USER_NAME /src \
    && mkdir -p /etc/sudoers.d \
    && usermod -aG video $USER_NAME \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME

USER $USER_NAME
WORKDIR $USER_HOME

# -----------------------------------------------------------------------------------------------------------------------------------------------------
# FINAL SETUPS

# upgrade python pip
RUN python -m pip install --upgrade pip

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

# Copy and install Python requirements
COPY ./src/requirements/ $USER_HOME/requirements/
RUN for file in $USER_HOME/requirements/*; do \
        python3 -m pip install -r $file; \
    done

# remove all the created/copied/moved file by the docker
USER root
RUN rm -rf $USER_HOME/*

USER $USER_NAME

# when the container is launched it will start a bash session
CMD ["/bin/bash"]

