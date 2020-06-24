# Data Science 1 Projekt
### Von Julius Rubbe, Frederik Hering und Timo Wehner
Eine Übersicht über die optimierten Algorithmen kann in Overview.ipynb gefunden werden. Hierbei ist auch unser Vorgehen genau beschrieben und jeweils der Code bereits ausgeführt - wodurch die Ergebnisse sofort in einer aufbereiten Form ersichtlich sind. Im Verzeichnis data_preperation sind die Datenaufbereitungsskripte und die Datenbasis zu finden.
***
## Wichtige Information
Leider ist der Immobilienscoutdatensatz zu groß für github. Deswegen muss der Datensatz händisch von https://www.kaggle.com/corrieaar/apartment-rental-offers-in-germany heruntergladen und in das verzeichnis data_preperation/data eingefügt werden.

## Kurze Übersicht der Datenquellen
| Name          | URL           |
| ------------- |:-------------:|
| Immobilienscout   | https://www.kaggle.com/corrieaar/apartment-rental-offers-in-germany | 
| Bevölkerungsstatistik     | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=12411-02-03-4&levelindex=0&levelid=1593015909113     |  
| Arbeitslosenstatistik | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=13211-02-05-4&levelindex=0&levelid=1593015946835     |  
| BIP Statistik | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=82111-01-05-4&levelindex=0&levelid=1593015985767    |  
| Einkommensstatistik | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=82411-01-03-4&levelindex=0&levelid=1593016022155    |  
| Gemeindeverzeichnis | https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/Archiv/GVAuszugQ/AuszugGV2QAktuell.html;jsessionid=D79376DD4ACD5FA8C8BAEDBD94DCD806.internet8741     |  

## Abhänigkeiten:
Für den R-Code müssen folgende Bibliotheken installiert werden:
Dazu einfach den folgenden Codesnipet ausführen
```R
install.packages(c("stringr", "data.table","dplyr", "tidyverse", "magrittr", "openxlsx", "sf")
```
Die Bibliotheken für Python sind in der requirements.txt zu finden. Wichtig: Python 3 muss in der Version 3.6.x vorliegen.
Um die Bibliotheken zu installieren kann der folgende Codesnipet ausgeführt werden.

```Python
pip3 install requierements.txt -R 
```
