# Contexto para o Claude (leia antes de tudo)

Este arquivo resume uma conversa anterior com o dono do projeto, para que uma nova sessão do Claude Code continue o trabalho sem perder nada.

## Quem é o usuário
- Vinicius. Fala português (Brasil). **É leigo em tecnologia**: explique o porquê de cada passo em linguagem simples, sem jargão.
- Quer que o Claude **faça as coisas por ele** (baixar, instalar, rodar, pesquisar e entregar links prontos) em vez de mandar ele fazer manualmente. Só peça a ele o que for fisicamente impossível para você, como apertar botões no controle remoto do projetor.
- Computador: **Windows**. Esta sessão deve estar rodando localmente no PC dele.

## O aparelho
- Projetor **Magcubic HY320**, chip Allwinner **H713**, Android 11 personalizado (fabricante "Hotack"), provavelmente 32 bits (armeabi-v7a). **Confirmar no relatório.**
- **IP na rede local: `192.168.3.180`** (ADB na porta 5555).
- Problema: muito lento; o YouTube trava, dá erro e fecha.
- Ele quer manter tudo funcionando: **Wi-Fi, foco automático, keystone, HDMI, controle remoto e som.**

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
3. `adb connect 192.168.3.180:5555`. O usuário precisa aceitar "Permitir depuração?" na tela do projetor. Avise-o na hora.
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
