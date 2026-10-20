#!/usr/bin/env bash
# Otimizacao do projetor Magcubic HY320 via ADB (Linux / macOS).
# Uso: ./projetor.sh
set -u
cd "$(dirname "$0")"

ADB=adb
[ -x platform-tools/adb ] && ADB=./platform-tools/adb
DEVICE=""

a() {
  if [ -n "$DEVICE" ]; then "$ADB" -s "$DEVICE" "$@"; else "$ADB" "$@"; fi
}

pacotes() {
  # Le um arquivo de lista ignorando comentarios e linhas vazias.
  while read -r pkg _; do
    [ -z "$pkg" ] || [ "${pkg#\#}" != "$pkg" ] && continue
    echo "$pkg"
  done < "$1"
}

conectar() {
  read -rp "IP do projetor (ex: 192.168.0.50): " ip
  "$ADB" connect "$ip:5555"
  DEVICE="$ip:5555"
  echo "Se aparecer um aviso na tela do projetor, aceite (marque 'sempre permitir')."
  a wait-for-device && echo "Conectado: $(a shell getprop ro.product.model)"
}

coletar_info() {
  mkdir -p relatorios
  local arq="relatorios/info-projetor.txt"
  {
    echo "== Aparelho =="
    for p in ro.product.manufacturer ro.product.model ro.product.device ro.board.platform \
             ro.hardware ro.product.cpu.abi ro.build.version.release ro.build.display.id; do
      echo "$p = $(a shell getprop "$p" | tr -d '\r')"
    done
    echo; echo "== Memoria =="; a shell "head -n 3 /proc/meminfo"
    echo; echo "== Armazenamento =="; a shell "df -h /data"
    echo; echo "== Launcher atual =="
    a shell "cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME"
    echo; echo "== Pacotes suspeitos =="; a shell "pm list packages | grep -E 'hotack|htc|toofifi|huawei|rockchip'"
    echo; echo "== Pacotes ja desativados =="; a shell "pm list packages -d"
    echo; echo "== Apps instalados por voce =="; a shell "pm list packages -3"
    echo; echo "== Apps do sistema =="; a shell "pm list packages -s"
    echo; echo "== O que esta pesando agora =="; a shell "top -b -n 1 | head -n 30"
  } > "$arq" 2>&1
  echo "Relatorio salvo em $arq"
}

desativar_pkg() {
  local pkg=$1
  if ! a shell pm path "$pkg" 2>/dev/null | grep -q '^package:'; then
    echo "  -  $pkg: nao instalado"
  elif a shell pm disable-user --user 0 "$pkg" 2>&1 | grep -qi disabled; then
    echo "  OK $pkg desativado"
  elif a shell pm uninstall -k --user 0 "$pkg" 2>&1 | grep -qi success; then
    echo "  OK $pkg removido do usuario (reversivel)"
  else
    echo "  FALHOU $pkg (precisa de root)"
  fi
}

desativar() {
  echo "Desativando malware, telemetria e lixo de fabrica..."
  for pkg in $(pacotes listas/desativar.txt); do desativar_pkg "$pkg"; done
  read -rp "Desativar tambem o espelhamento de tela (listas/opcional.txt)? (s/n): " r
  if [ "$r" = s ] || [ "$r" = S ]; then
    for pkg in $(pacotes listas/opcional.txt); do desativar_pkg "$pkg"; done
  fi
}

desfazer() {
  echo "Reativando todos os pacotes das listas..."
  for pkg in $(pacotes listas/desativar.txt) $(pacotes listas/opcional.txt); do
    a shell cmd package install-existing "$pkg" >/dev/null 2>&1
    a shell pm enable "$pkg" >/dev/null 2>&1
    echo "  $pkg restaurado"
  done
}

instalar_apks() {
  shopt -s nullglob
  local apks=(apks/*.apk)
  if [ ${#apks[@]} -eq 0 ]; then
    echo "Nenhum .apk na pasta apks/. Veja o README para baixar SmartTube e Projectivy."
    return
  fi
  for apk in "${apks[@]}"; do
    echo "Instalando $(basename "$apk")..."
    a install -r "$apk"
  done
}

acelerar() {
  a shell settings put global window_animation_scale 0.5
  a shell settings put global transition_animation_scale 0.5
  a shell settings put global animator_duration_scale 0.5
  a shell pm trim-caches 128G
  echo "Animacoes aceleradas e cache limpo."
}

while true; do
  cat <<'EOF'

==== Projetor HY320 - otimizacao ====
 1) Conectar ao projetor pelo Wi-Fi
 2) Gerar relatorio do aparelho (faca isso antes de tudo)
 3) Desativar malware e apps inuteis
 4) Instalar os APKs da pasta apks/
 5) Acelerar animacoes e limpar cache
 6) Desfazer (reativar tudo que foi desativado)
 7) Reiniciar o projetor
 0) Sair
EOF
  read -rp "Escolha: " op
  case $op in
    1) conectar ;;
    2) coletar_info ;;
    3) desativar ;;
    4) instalar_apks ;;
    5) acelerar ;;
    6) desfazer ;;
    7) a reboot ;;
    0) exit 0 ;;
    *) echo "Opcao invalida" ;;
  esac
done
