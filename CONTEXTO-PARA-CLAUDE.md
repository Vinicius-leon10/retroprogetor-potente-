# Contexto para o Claude (leia antes de tudo)

Este arquivo resume uma conversa anterior com o dono do projeto, para que uma nova sessão do Claude Code continue o trabalho sem perder nada.

## Quem é o usuário
- Fala português (Brasil). **É leigo em tecnologia**: explique o porquê de cada passo em linguagem simples, sem jargão.
- Quer que o Claude **faça as coisas por ele** (baixar, instalar, rodar, pesquisar e entregar links prontos) em vez de mandar ele fazer manualmente. Só peça a ele o que for fisicamente impossível para você, como apertar botões no controle remoto do projetor.
- Computador: **Windows**. Esta sessão deve estar rodando localmente no PC dele.

## O aparelho
- Projetor **Magcubic HY320**, chip Allwinner **H713**, Android 11 personalizado (fabricante "Hotack"), provavelmente 32 bits (armeabi-v7a). **Confirmar no relatório.**
- **IP na rede local:** veja em Configurações → Rede e Internet no projetor (ADB na porta 5555).
- Problema: muito lento; o YouTube trava, dá erro e fecha.
- Ele quer manter tudo funcionando: **Wi-Fi, foco automático, keystone, HDMI, controle remoto e som.**

### Hardware REAL (relatório de 2026-10-20, `relatorios/info-projetor.txt`)
- **Não é Allwinner H713.** É **Amlogic T950S** (board `txhd2`, modelo `t950s_be311`), **Android 13**, armeabi-v7a, **~1 GB de RAM**, /data 80% cheio.
- Os pacotes hotack, `com.hysd.vafocus` e `com.softwinner.awlivetv` **não existem** neste aparelho. Keystone = `com.softwinner.tcorrection`. Launcher original = `com.htc.htclauncherhighenglishd08`.
- Tem `/system/xbin/su` e o adbd roda com contexto de root: qualquer um na rede com ADB tem root. Desligar a depuração por rede quando não estiver usando.
- **Root e firmware para H713 (fases 2 e 3) NÃO servem para este aparelho.**

### Fase 1 já feita em 2026-10-20
- Listas em `listas/` refeitas para este hardware; os 11 pacotes de `desativar.txt` + `opcional.txt` foram desativados com `disable-user --user 0`.
- SmartTube stable 32.68 armeabi-v7a e Projectivy 4.72 instalados; animações em 0.5x; projetor reiniciado.
- Projectivy configurado: `cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity`, serviço de acessibilidade ativado via `settings put secure enabled_accessibility_services`, "Sobrepor o launcher atual" ligado. Home pelo ADB ainda abre o launcher htc, mas o usuário confirmou que o Home do controle abre o Projectivy.
- Netflix: só a versão de celular roda; a Play Store diz que o aparelho não é compatível com o Netflix TV (sem certificação Netflix). Decidido não instalar mods.
- Testes com APKs originais (assinatura Netflix "PPD Builder" conferida) da APKMirror: celular 9.58 e 9.57 = "não compatível"; TV 13.2.1 (com.netflix.ninja) = "não compatível"; celular 9.26 = pede atualização. A 8.143.5 instalada (assinada com a chave nova da Netflix, por isso não aceita atualizar por cima com os APKs da APKMirror) é a única que funciona. Backup: `apks/backup-netflix-8.143.5.apk.bak`. Não vale testar 9.38/9.54/9.55.
- Rodada 2 (mesmo dia): desativados o launcher htc (apontado como malicioso, roda como UID 1000 e tem INSTALL_PACKAGES), os componentes de celular da lista do CleanYourTV para T950S (github.com/Gathin23/cleanyourtv, examples/stellamore-t950s) e com.google.android.tvrecommendations; "Habilitar canais" do Projectivy desligado. Depois de reiniciar, Projectivy abre sozinho e o keystone (tcorrection) roda.
- A Play Store fica em /system/priv-app/Tubesky, mas o certificado é do Google (SHA-256 F0FD6C5B...DB83), então é genuína.
- ro.debuggable=1 e ro.adb.secure vazio: ADB root sem autenticação na rede.
- Trocar o Android: o modelo é o HY320 Mini (T950S_BE311). Não há firmware oficial nem custom para baixar (há pedidos sem resposta no XDA e um relato de brick ao tentar root). Não gravar firmware.
- Rodada 3: desinstalados (pm uninstall, apps de /data/app) os 9 apps lixo que estavam desativados, Prime Video de celular, YouTube TV original, MX Player, Max e Disney+. Espaço livre: 539 MB -> 1,3 GB. Tela real: 1280x720 a 30 fps.
- Instalado o Downloader (Play Store) e liberado "instalar apps desconhecidos" só para ele, a pedido do usuário.
- Instalado jqssun/android-airplay-server v0.0.36 (io.github.jqssun.airplay, GitHub oficial, tem armeabi-v7a). Funciona: iPhone espelhou. Conflitava com o AirScreen na porta 7000 (erro 98); AirScreen desinstalado a pedido do usuário. Para celular Android sobra o Miracast de fábrica (com.droidlogic.miracast).
- Opções do desenvolvedor vinham escondidas (o truque das 7 vezes em "Build" está bloqueado). Liberadas com `settings put global development_settings_enabled 1`. O ADB pela rede (porta 5555) depende da "Depuração USB" (adb_enabled), não da "Depuração por Wi-Fi". Caminho: Menu do Projectivy → Configurações do Android → Preferências do dispositivo → Opções do desenvolvedor → Depuração USB.
- 2026-10-20: o usuário DESLIGOU a Depuração USB; depois de reiniciar, a porta 5555 continua fechada (não religa sozinha). Para usar ADB de novo, o usuário precisa religar a Depuração USB.
- Keystone/imagem: com.softwinner.tcorrection/.projection.ProjectionSettingActivity ("Configurações de projeção").
- Guia público sem dados pessoais em `guia-publico/` (README.md e versão HTML). A pasta `para-github/` tem só o que pode subir; `.gitignore` bloqueia `.claude/`, `platform-tools/`, `relatorios/` e os APKs.
- Falta: o usuário testar keystone, Wi-Fi, som, controle e SmartTube.

## O que já foi descoberto
- Esses projetores vêm com **malware de fábrica**. O principal é `com.hotack.silentsdk`, que transforma o aparelho em proxy residencial e usa a internet do dono. Fontes: github.com/well0nez/magcubic-root e github.com/micha102/hy300pro-debloat.
- **Não existe** porte do Fire OS para o projetor (o Fire OS é fechado e preso ao hardware da Amazon).
- Existe um Android TV **beta** para o H713 (tópico no XDA: "[BETA] Android TV and Root Tutorial for AllWinner H713 based Projectors"), testado no HY300 Pro+ e não confirmado no HY320. **Não recomendado agora.**
- Existe um firmware limpo para HY300/HY320/L018 (androidpctv.com/firmware-magcubic-hy300-hy320/). Fica para a fase 3, só depois de confirmar o hardware.
- Linux para o H713 (well0nez/allwinner-h713-linux, shift/sun50iw12p1-research) ainda não tem imagem nem som. Não serve.
- Projeto parecido, feito para usar com o Claude Code: github.com/itsmeterrylin/fire-tv-cleanup. Pode servir de referência.

## O plano (fase 1, sem risco, tudo reversível)
1. Baixar o **ADB** (Platform Tools para Windows, do Google) e extrair a pasta `platform-tools` na raiz deste projeto.
2. Baixar para a pasta `apks/`, **só de fontes oficiais**:
   - SmartTube **stable armeabi-v7a**: github.com/yuliskov/SmartTube/releases
   - Projectivy Launcher: github.com/spocky/miproja1/releases
3. `adb connect <IP-do-projetor>:5555`. O usuário precisa aceitar "Permitir depuração?" na tela do projetor. Avise-o na hora.
4. Gerar o relatório (mesmos comandos da opção 2 do `projetor.bat`) e **mostrar ao usuário em linguagem simples**: chip, ABI, versão do Android, RAM, pacotes suspeitos encontrados e o que está consumindo CPU.
5. **Antes de desativar qualquer coisa, mostre a lista e peça confirmação.** Use `pm disable-user --user 0` (reversível). Nunca use uninstall sem `--user 0`.
6. Instalar os APKs, acelerar as animações (0.5x), reiniciar.
7. Ajudar a configurar o Projectivy (Override launcher + atalho para a entrada HDMI `com.softwinner.awlivetv`).
8. Pedir ao usuário para testar: foco, keystone, HDMI, Wi-Fi e YouTube (SmartTube).

## Regras de segurança
- **NUNCA desativar:** `com.hysd.vafocus` (foco), `com.softwinner.awlivetv` (HDMI), launchers originais `com.htc.magcubicos` / `com.htc.luminaos` / `com.htc.htclauncherhighenglishd08` (têm o ajuste de keystone). Veja `listas/manter.txt`.
- Pacotes de espelhamento de tela (`listas/opcional.txt`): perguntar antes, porque ele pode usar.
- Sem flash de firmware e sem root nesta fase.
- Se algo quebrar: opção "Desfazer" (reativar com `pm enable` / `cmd package install-existing`).

## Arquivos deste repositório
- `README.md`: guia completo
- `projetor.bat` / `projetor.sh`: menu que automatiza tudo via ADB
- `listas/desativar.txt`, `listas/opcional.txt`, `listas/manter.txt`
