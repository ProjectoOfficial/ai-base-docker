@echo off
setlocal

REM exit on error
set "ERRORLEVEL=0"

if not "%2"=="" (
    echo Usage: run.bat [path to data directory]
    exit /b 1
)

set "IMAGE_NAME=ai-base-docker"
set "IMAGE_TAG=1.0.0"

echo %IMAGE_NAME%:%IMAGE_TAG% started!

set "CONTAINER_NAME=ai-base"
set "PATH_TO_SRC_FOLDER="

set "MOUNT_SRC_PATH=-v %~dp0..\\src:/home/user/src"
set "MOUNT_WEBCAM="
set "MOUNT_DATA="

if not "%1"=="" (
    set MOUNT_DATA=%1
)

set "launch_command=docker run "
set "base_options=-p 8080:8080 --shm-size 2GB -it --rm --gpus all "
set "options=-v /media:/media "
set "options=%options% -e http_proxy -e https_proxy"
set "options=%options% %MOUNT_SRC_PATH% "
REM set "options=%options% -e DISPLAY=%DISPLAY% -e QT_X11_NO_MITSHM=1 "
REM set "options=%options% -v %XSOCK%:%XSOCK% -v %XAUTH%:%XAUTH% "
REM set "options=%options% -e XAUTHORITY=%XAUTH% "
set "options=%options% --name %CONTAINER_NAME% "
REM set "options=%options% --user %USERDOMAIN%\%USERNAME% "
set "options=%options%--net=host "
set "options=%options% %MOUNT_WEBCAM% "

set "mount_data_option="
if not "%MOUNT_DATA%" == "" (
    echo mounting data directory: %MOUNT_DATA%
    set "options=%options% -v %MOUNT_DATA%:/home/user/data "
)

set "options=%options% %IMAGE_NAME%:%IMAGE_TAG% "

echo Launching: %launch_command% %base_options% %options% %mount_data_option%
%launch_command% %base_options% %options% %mount_data_option%

:: Attendi l'input prima di chiudere lo script
pause

:end
endlocal
