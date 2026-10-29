# LVA i BJP26

Välj konfiguration **BJP26**, WorkSpace **Swedish Standards** och WorkSet
**Swedish Rail** i OpenRail Designer 2026. Dina lokala NCAD LVA-bibliotek laddas
nu i det ursprungliga WorkSpacet. Något separat test-WorkSpace behövs inte.

WorkSpacet laddar svenska järnvägsstandarder och dina LVA-standardbibliotek,
elementmallar, nivåer och cellbibliotek. Bentleys standardbibliotek för LVA har
tagits bort ur paketet: två DGNLIB-filer, fyra cellbibliotek och den tillhörande
LV_Status-uppslagstabellen. Installationsskriptet säkerhetskopierar och tar bort
dessa sju filer vid uppdatering när hela ersättningen finns i paketet. Övriga
järnvägsbibliotek, designfrön och mallbibliotek finns kvar.

## Innehåll

Sex teknikområden laddas: Bana, Belysning, Kanalisation, Kontaktledning,
Lågspänning och Tele. Varje område har ett standardbibliotek och två
cellbibliotek, för 2D respektive 3D.

Källfilerna var sparade som `.dgn`. Enligt den medföljande instruktionen ska
standardbiblioteken heta `.dgnlib` och cellbiblioteken `.cel`. De lokala kopiorna
har därför dessa filändelser; filinnehållet är identiskt med källan och har
kontrollerats med SHA-256. Detta ändrar inte filernas modeller eller geometri.

Signal ligger under **Arbete pågår** i källan. Dessa tre bibliotek finns i
`Experimental/Signal` och är avstängda från början. För att prova dem, ändra
`BJP26_LVA_ENABLE_SIGNAL : 0` till `BJP26_LVA_ENABLE_SIGNAL : 1` i
`Organization-Civil/LVA.cfg` och ladda om WorkSpacet.

Äldre versioner under OLD, samlingen Befintliga celler och mötesinspelningen
ingår inte. NCAD-biblioteken är de resurser som laddas.
Att ett bibliotek ligger i en teknikmapp innebär inte att objekten är granskade.
Konfigurationsändringen innebär inte att alla objekt har kvalitetsgranskats.

## Dokumentation och återstående kontroll

Källmaterialets arbetsdokument, LOI- och statuskalkylblad distribueras inte
i detta paket och registreras inte som Bentley-uppslagstabeller. Ett separat
NC-OR-ItemTypeLib-bibliotek ingår inte.
Eventuella Item Types som redan finns inbäddade i standardbiblioteken kan laddas.

Konfigurationskontroll och filkontroll kan inte bekräfta alla funktioner i
binärbiblioteken. Prova objekten i en ny testfil: kontrollera att Feature
Definitions och 2D-/3D-elementmallar visas, att cellerna placeras med rätt
geometri och insättningspunkt, samt att nivåer, attribut och eventuella interna
referenser fungerar. Källans instruktion om unika cellnamn måste också
kontrolleras mot de redan inlästa biblioteken.

Installationsskriptets säkerhetskopior av ersatta eller pensionerade filer
finns under `_installer-backups` i konfigurationsroten. Personliga inställningar,
projektfiler, lokala kontrollrapporter och arbetsdokument ingår inte i paketet.
