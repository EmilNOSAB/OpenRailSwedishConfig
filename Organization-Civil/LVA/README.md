# LVA i BJP26

Välj konfiguration **BJP26**, WorkSpace **Swedish Standards** och WorkSet
**Swedish Rail** i OpenRail Designer 2026.

## LVA från ConnectConfiguration

Sju resurser har kopierats från `C:\ConnectConfiguration` till motsvarande
mappar i `Organization-Civil/Swedish Standards`:

- `Cell/LV Assets 3D.cel`
- `Cell/LV Assets Annotations.cel`
- `Cell/LV Assets Plan.cel`
- `Cell/LV Assets Sch.cel`
- `Dgnlib/Feature Definitions/Rail/LV Assets Item Types.dgnLib`
- `Dgnlib/Feature Definitions/Rail/LVA Rail Settings Features Annotations Levels Elem Temp Metric.dgnLib`
- `Dgnlib/Item Types/LV_Status.xlsx`

Biblioteken laddas genom de befintliga sökvägarna för svenska järnvägsstandarder.
`LV_Status.xlsx` är åter ansluten som `ITEMTYPE_LOOKUP`. Kopiornas SHA-256 är
identiska med källfilerna. Installationsskriptet behåller nu dessa resurser även
när hela NCAD-paketet ingår. Det tidigare borttagningssteget är borttaget.

## Svenska sektionsmallar och kabelrännor

Standardbiblioteket för järnväg är **Templatesbibliotek_TRV - Remapped.itl**,
med 153 mallar. Under **Komponenter, kanalisation** finns 12 kabelrännemallar,
bland annat `Kabelränna_350`, `Kabelränna_520`, `Kabelränna_535`,
`Kabelränna_560`, `Kabelränna_720` och `Kabelränna_880` samt varianter för
bangård och linjesektion. Originalbiblioteket och Bentleys ITL-filer finns kvar.

Starta om OpenRail efter uppdateringen. Om en mallväljare i en befintlig session
fortfarande visar `OpenRail Templates Metric.itl`, öppna
`Organization-Civil/Swedish Standards/Template Library/Templatesbibliotek_TRV - Remapped.itl`
i mallbibliotekets öppna-dialog.

## NCAD-bibliotek

`Organization-Civil/LVA.cfg` lägger också till 18 NCAD-bibliotek från sex
teknikområden: Bana, Belysning, Kanalisation, Kontaktledning, Lågspänning och
Tele. Varje område har ett standardbibliotek och två cellbibliotek, för 2D och
3D. Källfilerna var sparade som `.dgn`; kopiornas ändelser har ändrats till
`.dgnlib` och `.cel` utan ändring av byteinnehållet.

Signal ligger under **Arbete pågår** i NCAD-källan. Dess tre bibliotek finns i
`Experimental/Signal` och är avstängda från början. För att prova dem, ändra
`BJP26_LVA_ENABLE_SIGNAL : 0` till `BJP26_LVA_ENABLE_SIGNAL : 1` i `LVA.cfg`.

NCAD-källans LOI- och statusarbetsböcker distribueras inte och registreras inte
som uppslagstabeller. Ett separat NC-OR-ItemTypeLib-bibliotek saknas i den källan.
Detta gäller inte de återställda ConnectConfiguration-resurserna ovan.

Kontroll av resurslistor och filinnehåll ersätter inte placeringsprov av alla
bibliotekens objekt, geometri, insättningspunkter och attribut.
