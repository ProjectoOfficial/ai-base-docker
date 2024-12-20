# ai-base-docker
![Designer](https://github.com/user-attachments/assets/1bb22c91-bfa7-451f-ba5b-165ef103b889)

This docker aims to support research in being able to run their projects on different machines, and be able to share them in the best way.

### Why do I need a Docker?
Currently there are many ways to share the setup of an Artificial Intelligence research project, many only share the requirements file, while others also provide the configuration file for an environment managed by Anaconda. The problem with research projects is that a lot of time is often wasted just doing a project setup: installing Python, installing GPU drivers, installing CUDA, installing Anaconda, resolving errors and conflicts, ...
Docker is not yet the de-facto standard in research, but I think wider adoption could save a lot of people time. 

Docker allows you to create something similar to a virtual machine, where any action carried out within it, such as installing an ubuntu package or a python library, is canceled once docker is closed. To make a change made on Docker permanent, just write it in the Dockerfile.

in addition to proposing this tool which I think is useful for better managing one's environment, and in any case it is a skill in great demand even within companies (it is worth learning to use it!), I also propose to better organize research projects in this way :
- **`project-directory`**: a folder with the name of your research project.
  - **`ai-base-docker`**: import here the *ai-base-docker* as submodule.
  - **`src`**: the main directory where you implement the project.
    - **`requirements`**: the directory where you specify all the requirements files
        - **`base.txt`**: base requirements
        - **`devel.txt`**: development requirements

## Docker setup
1. Please follow docker base installation: 
    https://docs.docker.com/engine/install/
   or install docker with the following commands:
   ```
   wget https://get.docker.com/ -O get_docker.sh
   chmod +x get_docker.sh
   bash get_docker.sh
   ```

3. Once docker has been installed, install nvidia-docker2 for GPU support (otherwise you can follow [this](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) procedure (Recommended) ):
    ```
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    ```

    update and install the nvidia container tool
    ```
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    ```

    configure nvidia container tool
    ```
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    ```

4. Add required permissions to your user in order to perform actions with docker on containers
    ```
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    ```

5. Import and build docker image: please note that here you are downloading ubuntu, cuda and pytorch, and it may take several minutes
    
    - Importing ai-base-docker as submodule (to use it as it is)
        ```
        git submodule add https://github.com/ProjectoOfficial/ai-base-docker
        git fetch
        git pull
        ```
    - Cloning: recommended when you need to work on a private repository. Delete .git directory within ai-base-docker, in this way you can push your changes without any issue
        ```
        git clone https://github.com/ProjectoOfficial/ai-base-docker
        ```
    - Forking: recommended if you need it but just for a public project (then you create a new branch per each project you need to work on). Click on [Fork](https://github.com/ProjectoOfficial/ai-base-docker/fork) and then:
        ```
        git clone https://github.com/your-github-id/ai-base-docker
        cd ai-base-docker
        git checkout -b project-branch-name
        ```
    
    then go to ai-base-docker directory and build the docker
    ```
    cd ai-base-docker
    ./build.sh
    ```

6. run docker image:
    ```
    ./run.sh
    ```
    - params:
        - (-d /path/to/dir_to_mount): optionally you can specify supplementary volumes (directory) which tipically can be used as data directory (where you store your datasets). You will find it under ```/home/user/src```
        - (-w): enables the docker to mount a webcam

## Coding
To be able to program and execute the code inside the docker at the same time (permanent programming, the files will remain even when the docker is closed) I recommend using [VSCode](https://code.visualstudio.com/).

As extensions to do this I use the following. Go to the VSCode marketplace (CTRL+SHIFT+X) and search for:
- ```ms-azuretools.vscode-docker```
- ```ms-vscode-remote.remote-containers```

once the extensions have been installed and after launching the docker *run* script, in the menu on the left of VSCode you must select the whale icon (docker), and under the "individual containers" item you will find the container you have just launched with a green arrow next to it. By clicking with the right mouse button on it you will find "attach with VSCode", and this will open a new window for programming inside the docker.

It's not over here, one last step is missing! Go to File>Open Folder -> enter "/home/user" as the path

## Remote Host Connection
The script `remote.sh` configurest the local host and the remote host in order to run the docker remotely but develop through VSCode on the local machine. It creates a local SSH key to be used later to attach docker to the remote container, and adds that key into the remote host `~/.ssh/authorized_keys`. Then it creates a local `~/.ssh/config` pointing to that remote host, with the generated key. Finally it updates a docker context on the local machine in order to connect and list the containers running on the remote machine.

```
# Usage

chmod +x remote.sh
./remote.sh
```

## Support & solutions
Here is listed what ai-base-docker is currently able to install and run:
 - CUDA & cudnn
 - ubunutu packages (apt install)
 - Python, pip and multiple requirements.txt install
 - Python .whl install
 - Anaconda 
 - Remote Host Connection
 - ROS Noetic automatic installation within Dockerfile
 - Pre-configured containers for: Raspbery Pi, NVIDIA Jetson Orin Nano, NVIDIA Jetson Nano
 - Automatic device detection for container build an run

## Contributions
If you find errors or have suggestions for improving this project, feel free to open an issue or send a pull request.

tested with docker version: 24.0.7
