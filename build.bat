@echo off

set IMAGE_NAME=ai-base-docker
set IMAGE_TAG=1.0.0
set DOCKERFILE_PATH=docker\Dockerfile

echo Started build for %IMAGE_NAME%:%IMAGE_TAG%

:: Trova il percorso assoluto del Dockerfile
set "MAIN_DIR=%~dp0/.."
echo Setting main directory as %CD%

:: Esegui la build dell'immagine Docker
echo Building: %MAIN_DIR%\%DOCKERFILE_PATH%
docker build -t "%IMAGE_NAME%:%IMAGE_TAG%" -f "%MAIN_DIR%\%DOCKERFILE_PATH%" "%MAIN_DIR%"

:: Controlla se la build è stata completata con successo
if %errorlevel% equ 0 (
    echo Build dell'immagine completata con successo.
) else (
    echo Si è verificato un errore durante la build dell'immagine.
)

:: Attendi l'input prima di chiudere lo script
pause
