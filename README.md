# Retroprojetor potente: otimizando o Magcubic HY320

Projeto para deixar o Android do projetor **Magcubic HY320** (chip Allwinner H713) mais leve, rápido e seguro, **sem perder** Wi-Fi, foco automático, keystone, HDMI e controle remoto.

> ⚠️ **Importante:** pesquisadores encontraram **malware** de fábrica nesses projetores (ex.: `com.hotack.silentsdk`, que transforma o aparelho em "proxy" e usa sua internet para terceiros). Desativar esses pacotes é o primeiro passo, e também deixa o aparelho mais leve.

## O plano, em 3 fases

| Fase | O que faz | Risco | Precisa de root? |
|---|---|---|---|
| **1. Limpeza via ADB** (este repositório) | Desativa malware e apps inúteis, instala YouTube leve (SmartTube) e launcher melhor (Projectivy), acelera animações | **Nenhum.** Tudo pode ser desfeito | Não |
| **2. Root** (opcional) | Permite remover o que a fase 1 não consegue e desligar scripts de boot que reativam o lixo | Médio | Sim |
| **3. Firmware customizado** (opcional) | Grava um Android já limpo, com Projectivy e Magisk | Médio/alto (pode travar o aparelho se der errado) | Grava novo sistema |

**Comece pela fase 1.** Na maioria dos casos ela já resolve o problema do YouTube.

---

## Fase 1: passo a passo

### 1. Preparar o projetor
1. **Configurações → Sobre** (ou *Preferências do dispositivo → Sobre*).
2. Clique **7 vezes** em **Build / Versão** até aparecer "Você agora é um desenvolvedor".
3. Volte, entre em **Opções do desenvolvedor** e ative **Depuração USB** e, se existir, **Depuração por rede / ADB por Wi-Fi**.
4. Anote o **IP do projetor**: *Configurações → Rede → (sua rede Wi-Fi)*. Algo como `192.168.0.50`.

### 2. Preparar o computador (na mesma rede Wi-Fi)
1. Baixe este repositório: botão verde **Code → Download ZIP** e extraia.
2. Baixe o **ADB (Platform Tools)** do Google: <https://developer.android.com/tools/releases/platform-tools>
   Extraia a pasta `platform-tools` **dentro da pasta deste projeto**.
3. Baixe os aplicativos e coloque os arquivos `.apk` na pasta `apks/`:
   - **SmartTube** (YouTube leve, sem anúncios): <https://github.com/yuliskov/SmartTube/releases>. Pegue o `.apk` "stable" **armeabi-v7a** (o HY320 é 32 bits).
   - **Projectivy Launcher** (tela inicial de Smart TV): pela Play Store do projetor, ou o APK oficial em <https://github.com/spocky/miproja1/releases>

### 3. Rodar o script
- **Windows:** dois cliques em `projetor.bat`
- **Linux/Mac:** `chmod +x projetor.sh && ./projetor.sh`

Siga o menu **nesta ordem**:

1. **Conectar**: digite o IP. Na tela do projetor, aceite o aviso ("sempre permitir").
2. **Gerar relatório**: cria `relatorios/info-projetor.txt`. **Me mande esse arquivo** (cole no chat ou faça commit) para eu ajustar as listas ao seu aparelho exato.
3. **Desativar malware e apps inúteis**: usa `listas/desativar.txt`.
4. **Instalar APKs**: instala o que estiver em `apks/`.
5. **Acelerar**: animações em 0,5x e limpeza de cache.
6. **Reiniciar.**

Se algo parar de funcionar, use a opção **6) Desfazer**: ela reativa tudo.

### 4. Trocar a tela inicial pelo Projectivy
1. Abra o Projectivy. Em *Configurações → Geral*, ative **"Substituir launcher" (Override launcher)** e dê a permissão de acessibilidade pedida.
2. Para ter a **entrada HDMI** no Projectivy, adicione um atalho para o app `com.softwinner.awlivetv`.
3. **Não remova** a tela inicial original: é nela que ficam os ajustes de keystone e imagem.

---

## As listas

| Arquivo | Conteúdo |
|---|---|
| `listas/desativar.txt` | Malware, telemetria, loja e atualizador duvidosos, apps de teste de fábrica |
| `listas/opcional.txt` | Espelhamento de tela (só desative se não usa) |
| `listas/manter.txt` | **Nunca mexer**: foco, HDMI, launcher original |

Sem root, alguns pacotes podem dar "FALHOU". Isso é normal; nesse caso a fase 2 resolve.

## Fases 2 e 3 (depois que a fase 1 estiver ok)
- **Root:** <https://github.com/well0nez/magcubic-root> (testado no HY310/L018, que usam o mesmo chip H713. O HY320 ainda não foi confirmado).
- **Firmware limpo HY300/HY320/L018:** <https://androidpctv.com/firmware-magcubic-hy300-hy320/>

Antes dessas fases, **confira no relatório se o seu aparelho é H713 e armeabi-v7a**. Existem versões "HY320 Pro" com outro hardware, e gravar firmware errado pode travar o projetor.

## Créditos / fontes
- Lista de malware e método de root: [well0nez/magcubic-root](https://github.com/well0nez/magcubic-root)
- Análise do proxy escondido: [micha102/hy300pro-debloat](https://github.com/micha102/hy300pro-debloat)
- Linux para o H713 (experimental, sem imagem ainda): [shift/sun50iw12p1-research](https://github.com/shift/sun50iw12p1-research)
