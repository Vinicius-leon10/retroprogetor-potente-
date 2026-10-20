@echo off
rem Otimizacao do projetor Magcubic HY320 via ADB (Windows).
rem Uso: de dois cliques neste arquivo.
setlocal EnableExtensions
cd /d "%~dp0"

set "ADB=adb"
if exist "platform-tools\adb.exe" set "ADB=platform-tools\adb.exe"
set "DEV="

:menu
echo.
echo ==== Projetor HY320 - otimizacao ====
echo  1) Conectar ao projetor pelo Wi-Fi
echo  2) Gerar relatorio do aparelho (faca isso antes de tudo)
echo  3) Desativar malware e apps inuteis
echo  4) Instalar os APKs da pasta apks
echo  5) Acelerar animacoes e limpar cache
echo  6) Desfazer (reativar tudo que foi desativado)
echo  7) Reiniciar o projetor
echo  0) Sair
set "OP="
set /p "OP=Escolha: "
if "%OP%"=="1" goto conectar
if "%OP%"=="2" goto coletar_info
if "%OP%"=="3" goto desativar
if "%OP%"=="4" goto instalar_apks
if "%OP%"=="5" goto acelerar
if "%OP%"=="6" goto desfazer
if "%OP%"=="7" "%ADB%" %DEV% reboot
if "%OP%"=="0" exit /b
goto menu

:conectar
set /p "IP=IP do projetor (ex: 192.168.0.50): "
"%ADB%" connect %IP%:5555
set "DEV=-s %IP%:5555"
echo Se aparecer um aviso na tela do projetor, aceite (marque "sempre permitir").
"%ADB%" %DEV% wait-for-device
"%ADB%" %DEV% shell getprop ro.product.model
goto menu

:coletar_info
if not exist relatorios mkdir relatorios
set "ARQ=relatorios\info-projetor.txt"
(
  echo == Aparelho ==
  for %%p in (ro.product.manufacturer ro.product.model ro.product.device ro.board.platform ro.hardware ro.product.cpu.abi ro.build.version.release ro.build.display.id) do (
    echo %%p:
    "%ADB%" %DEV% shell getprop %%p
  )
  echo.
  echo == Memoria ==
  "%ADB%" %DEV% shell "head -n 3 /proc/meminfo"
  echo.
  echo == Armazenamento ==
  "%ADB%" %DEV% shell "df -h /data"
  echo.
  echo == Launcher atual ==
  "%ADB%" %DEV% shell "cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME"
  echo.
  echo == Pacotes suspeitos ==
  "%ADB%" %DEV% shell "pm list packages | grep -E 'hotack|htc|toofifi|huawei|rockchip'"
  echo.
  echo == Pacotes ja desativados ==
  "%ADB%" %DEV% shell "pm list packages -d"
  echo.
  echo == Apps instalados por voce ==
  "%ADB%" %DEV% shell "pm list packages -3"
  echo.
  echo == Apps do sistema ==
  "%ADB%" %DEV% shell "pm list packages -s"
  echo.
  echo == O que esta pesando agora ==
  "%ADB%" %DEV% shell "top -b -n 1 | head -n 30"
) > "%ARQ%" 2>&1
echo Relatorio salvo em %ARQ%
goto menu

:desativar
echo Desativando malware, telemetria e lixo de fabrica...
call :aplicar_lista "listas\desativar.txt"
set "R="
set /p "R=Desativar tambem o espelhamento de tela (listas\opcional.txt)? (s/n): "
if /i "%R%"=="s" call :aplicar_lista "listas\opcional.txt"
goto menu

:desfazer
echo Reativando todos os pacotes das listas...
for /f "usebackq eol=# tokens=1" %%p in ("listas\desativar.txt") do call :restaurar_pkg %%p
for /f "usebackq eol=# tokens=1" %%p in ("listas\opcional.txt") do call :restaurar_pkg %%p
goto menu

:instalar_apks
if not exist "apks\*.apk" (
  echo Nenhum .apk na pasta apks. Veja o README para baixar SmartTube e Projectivy.
  goto menu
)
for %%f in ("apks\*.apk") do (
  echo Instalando %%~nxf...
  "%ADB%" %DEV% install -r "%%~f"
)
goto menu

:acelerar
"%ADB%" %DEV% shell settings put global window_animation_scale 0.5
"%ADB%" %DEV% shell settings put global transition_animation_scale 0.5
"%ADB%" %DEV% shell settings put global animator_duration_scale 0.5
"%ADB%" %DEV% shell pm trim-caches 128G
echo Animacoes aceleradas e cache limpo.
goto menu

rem ---- sub-rotinas ----

:aplicar_lista
for /f "usebackq eol=# tokens=1" %%p in (%1) do call :desativar_pkg %%p
exit /b

:desativar_pkg
"%ADB%" %DEV% shell pm path %1 2>nul | findstr /b "package:" >nul || (
  echo   -  %1: nao instalado
  exit /b
)
"%ADB%" %DEV% shell pm disable-user --user 0 %1 2>&1 | findstr /i "disabled" >nul && (
  echo   OK %1 desativado
  exit /b
)
"%ADB%" %DEV% shell pm uninstall -k --user 0 %1 2>&1 | findstr /i "Success" >nul && (
  echo   OK %1 removido do usuario - reversivel
  exit /b
)
echo   FALHOU %1 - precisa de root
exit /b

:restaurar_pkg
"%ADB%" %DEV% shell cmd package install-existing %1 >nul 2>&1
"%ADB%" %DEV% shell pm enable %1 >nul 2>&1
echo   %1 restaurado
exit /b
