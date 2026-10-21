# Guia do HY320 Mini com chip Amlogic

O que funcionou, o que não funcionou e o que evitar ao deixar mais leve e mais seguro um projetor **Magcubic HY320 Mini da versão com chip Amlogic**. Tudo foi testado num aparelho real, com comandos ADB que podem ser desfeitos e sem root.

> Testado em uma unidade, em outubro de 2026. Outros lotes podem ter pacotes diferentes: confira os seus com `adb shell pm list packages` antes de copiar listas.

## 1. Confira qual chip o seu tem

A maioria dos guias da internet é para o HY300/HY320 com chip **Allwinner H713** e Android 11. A unidade testada aqui, vendida como HY320 Mini, tem outro hardware:

```sh
adb shell getprop ro.board.platform   # txhd2 = Amlogic
adb shell getprop ro.soc.model        # t950s_be311
adb shell getprop ro.product.cpu.abi  # armeabi-v7a (32 bits)
adb shell wm size                     # 1280x720
```

| Item | Unidade testada |
|---|---|
| Chip | Amlogic T950S (placa `txhd2`, modelo `t950s_be311`) |
| Sistema | Android 13 (TV), patch de segurança de abril de 2023 |
| Processador | 4 núcleos ARMv7, **apenas 32 bits** (armeabi-v7a) |
| Memória | ~1 GB de RAM, ~4,5 GB para apps |
| Tela real | **1280×720 a 30 quadros por segundo** |
| Bootloader | Já vem destravado de fábrica |

> ⚠️ **Se aparecer txhd2 / T950S:** não use listas, root nem firmware feitos para o H713. Pacotes como `com.hotack.silentsdk`, `com.hysd.vafocus` e `com.softwinner.awlivetv` nem existem nesta versão, e gravar um firmware de H713 pode inutilizar o aparelho.

## 2. Problemas de segurança de fábrica

- **Acesso total pela rede, sem senha.** O ADB fica na porta 5555 com `ro.debuggable=1`, `ro.adb.secure` vazio e `/system/xbin/su`. Qualquer aparelho no mesmo Wi-Fi, ou qualquer app instalado no projetor, consegue controle total.
- **Tela inicial de fábrica suspeita.** A `com.htc.htclauncherhighenglishd08` roda como sistema (UID 1000), pode instalar apps sozinha e mantém um processo `:filedownloader` sempre ativo. Pesquisadores apontam essa tela como maliciosa em outros projetores da mesma família (veja as fontes no fim).
- **Opções do desenvolvedor escondidas.** O truque de tocar 7 vezes em "Build" está bloqueado, mas o ADB continua ligado mesmo assim.
- **A Play Store é original**, apesar de ficar numa pasta chamada `Tubesky`. O certificado é o do Google.

**Como fechar a porta:** neste aparelho, a porta 5555 depende da **Depuração USB**, não da "Depuração por Wi-Fi". Desligue em: Configurações → Preferências do dispositivo → Opções do desenvolvedor → Depuração USB. Testado: depois de reiniciar, a porta **continua fechada**.

Se o menu não aparecer, deixe-o visível (com o ADB ainda ligado):

```sh
adb shell settings put global development_settings_enabled 1
```

## 3. Limpeza sem root

`pm disable-user` desativa sem apagar e pode ser desfeito. Alguns apps estranhos vêm em `/data/app`, e esses dá para desinstalar de vez para liberar espaço. Na unidade testada, o espaço livre passou de **539 MB para 1,3 GB**.

### Desativados (componentes de fábrica e de celular)

```sh
# Desative a tela inicial de fábrica SÓ depois de outra (Projectivy) estar funcionando
for p in com.htc.htclauncherhighenglishd08 com.droidlogic.updater \
  com.google.android.tvrecommendations com.android.printspooler com.android.musicfx \
  com.android.providers.calendar com.android.providers.contacts \
  com.google.android.syncadapters.calendar com.google.android.syncadapters.contacts \
  com.android.wallpaperbackup com.android.adservices.api \
  com.android.ondevicepersonalization.services; do
  adb shell pm disable-user --user 0 $p
done
```

### Apps de origem desconhecida que vieram instalados (rodando em segundo plano)

Na unidade testada: `com.smart.tv.launcher`, `com.ht1.launcher`, `com.overseas.store.appstore`, `com.master.tv.market`, `com.master.accessibility`, `com.jiumao.screen.systemadplayer`, `com.jiumao.projection`, `com.seraphic.openinet.jiumao` e `com.nmvdo.tv`. Não achei documentação pública sobre eles. Foram desativados primeiro e, como nada quebrou, desinstalados com `adb shell pm uninstall <pacote>`.

> ⚠️ **Não mexa nestes:** `com.softwinner.tcorrection` (keystone e ajustes de projeção), `com.htc.htcsettings` (configurações do projetor), `com.droidlogic.*` (imagem, som, HDMI, Wi-Fi, Miracast), `com.jm.jmlauncher` e `com.fb` (apps de fábrica com função não confirmada).

A tela de ajuste de imagem (zoom, trapézio automático, correção de canto) abre direto com:

```sh
adb shell am start -n com.softwinner.tcorrection/.projection.ProjectionSettingActivity
```

## 4. Projectivy como tela inicial

Instale o [Projectivy Launcher](https://github.com/spocky/miproja1/releases) (APK oficial) e rode:

```sh
adb shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity
adb shell settings put secure enabled_accessibility_services \
  com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService
adb shell settings put secure accessibility_enabled 1
```

Depois, no Projectivy, ligue **Configurações → Geral → Sobrepor o launcher atual**. Com a tela de fábrica ainda ativa, o botão Home do controle já abria o Projectivy (o Home enviado pelo ADB não). Com ela desativada, o Projectivy abre sozinho ao ligar. Desligar **"Habilitar canais"** economiza memória.

Dica: o menu do Projectivy abre com a tecla Menu (`KEYCODE_MENU`). O campo de nome de categoria não aceita confirmação enviada pelo ADB, então crie categorias pelo controle.

## 5. Apps que funcionaram (32 bits)

| App | Resultado |
|---|---|
| [SmartTube](https://github.com/yuliskov/SmartTube) (stable, armeabi-v7a) | ✅ Substitui o YouTube oficial, que usava mais de 100% de CPU. Ajuste a qualidade para **720p**, porque a tela é 720p a 30 qps. |
| [android-airplay-server](https://github.com/jqssun/android-airplay-server) | ✅ Espelhamento de iPhone grátis e sem anúncios. Disputa a porta 7000 com o AirScreen ("Error starting server", erro 98): use só um dos dois. |
| Miracast de fábrica (`com.droidlogic.miracast`) | ✅ Para espelhar celular Android. |
| Projectivy Launcher | ✅ Veja a seção 4. |

## 6. Netflix: o que testei

O aparelho não tem certificação da Netflix (a Play Store diz "não compatível" para o Netflix de TV). Testei só APKs originais, com assinatura da Netflix conferida:

| Versão | Resultado |
|---|---|
| Celular 8.143.5 (veio instalado) | ✅ Funciona, com interface de celular e qualidade padrão (SD). |
| Celular 9.26.0 | ⚠️ Pede atualização |
| Celular 9.57.0 e 9.58.0 | ❌ "Não compatível" (a 9.58 é a última versão de 32 bits) |
| Netflix TV 13.2.1 (`com.netflix.ninja`) | ❌ "Não compatível" |

> ⚠️ **Antes de desinstalar o Netflix que veio no aparelho,** faça backup do APK com `adb shell pm path com.netflix.mediaclient` e depois `adb pull`. Ele é assinado com uma chave mais nova da Netflix, e os APKs dos sites espelho não instalam por cima ("signatures do not match"). Se você apagar sem backup, pode ficar sem nenhuma versão que funcione.

Os "mods" de Netflix para aparelhos sem certificação, que aparecem no GitHub, são antigos e os próprios autores marcam como não funcionando. Além disso, pedem a senha da sua conta. O caminho que funciona para ter Netflix em HD é um stick certificado (Fire TV, Chromecast) ligado no HDMI.

## 7. Trocar o sistema

O aparelho aceita sistema genérico (Treble, partições A/B dinâmicas, VNDK 33, bootloader destravado), mas:

- Não achei firmware oficial nem modificado para o T950S_BE311; há pedidos sem resposta e relatos de aparelhos inutilizados no XDA.
- Um sistema genérico de 32 bits quase não existe para TV e provavelmente perderia o keystone e o HDMI, que ficam na partição de sistema.
- A certificação da Netflix fica em chaves gravadas em cada aparelho na fábrica, não no firmware. Gravar o sistema de um modelo certificado não traria o Netflix.

## 8. Como desfazer

```sh
# reativar um pacote desativado
adb shell pm enable <pacote>
# recuperar um pacote de sistema removido do usuário
adb shell cmd package install-existing <pacote>
# voltar para a tela inicial de fábrica
adb shell pm enable com.htc.htclauncherhighenglishd08
adb shell cmd package set-home-activity com.htc.htclauncherhighenglishd08/com.mao.launcher.activity.BarrelActivity
```

Apps de `/data/app` desinstalados com `pm uninstall` não voltam com esses comandos. Só desinstale o que você já testou desativado.

## Fontes e projetos usados

- [CleanYourTV](https://github.com/Gathin23/cleanyourtv) (lista para Stellamore T950S, mesmo chip)
- [hy300pro-debloat](https://github.com/micha102/hy300pro-debloat)
- [hy350max-badbox-removal](https://github.com/maximilian-sh/hy350max-badbox-removal)
- [SmartTube](https://github.com/yuliskov/SmartTube)
- [android-airplay-server](https://github.com/jqssun/android-airplay-server)
- [Projectivy Launcher](https://github.com/spocky/miproja1)
