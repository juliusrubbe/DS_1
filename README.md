# Data Science 1 Projekt
### Von Julius Rubbe, Frederik Hering und Timo Wehner
Eine Übersicht über die optimierten Algorithmen kann in Overview.ipynb gefunden werden. Hierbei ist auch unser Vorgehen genau beschrieben und jeweils der Code bereits ausgeführt - wodurch die Ergebnisse sofort in einer aufbereiten Form ersichtlich sind. 
Im Verzeichnis data_preperation sind die Datenaufbereitungsskripte und die Datenbasis zu finden. Hier wurde R für die Implementierung verwendet, da wir ein technologieunabhängiges Team sind und R sich besonders gut für das Aufbereiten von Daten eignet.
Da die Implementierung des genetischen Algorithmus komplex war, ist diese im Ordner Neural_network_optimization zu finden. Hier muss erwähnt werden, dass ein Großteil des Optimierers von https://github.com/harvitronix/neural-network-genetic-algorithm stammt.
Die Optimierungsschritte für KNN und GDB sind in den jeweiligen Dateien im Hauptverzeichnis zu finden.

## Wichtige Information
Leider ist der Immobilienscoutdatensatz zu groß für github. Deswegen muss der Datensatz händisch von https://www.kaggle.com/corrieaar/apartment-rental-offers-in-germany heruntergladen und in das verzeichnis data_preperation/data eingefügt werden.
Die Optimierungsskripte für das NN und den GBD wurden auf einer Microsoft Azure VM mit 14Gb Arbeitsspeicher ausgeführt und sind mehrere Stunden lang gelaufen.

## Kurze Übersicht der Datenquellen
| Name          | URL           |
| ------------- |:-------------:|
| Immobilienscout   | https://www.kaggle.com/corrieaar/apartment-rental-offers-in-germany | 
| Bevölkerungsstatistik     | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=12411-02-03-4&levelindex=0&levelid=1593015909113     |  
| Arbeitslosenstatistik | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=13211-02-05-4&levelindex=0&levelid=1593015946835     |  
| BIP Statistik | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=82111-01-05-4&levelindex=0&levelid=1593015985767    |  
| Einkommensstatistik | https://www.regionalstatistik.de/genesis//online/data?operation=table&code=82411-01-03-4&levelindex=0&levelid=1593016022155    |  
| Gemeindeverzeichnis | https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/Archiv/GVAuszugQ/AuszugGV2QAktuell.html;jsessionid=D79376DD4ACD5FA8C8BAEDBD94DCD806.internet8741     |  

Alle Daten beziehn sich auf die Jahre 2018 und 2017.

## Abhänigkeiten:
Für den R-Code müssen folgende Bibliotheken installiert werden:
Dazu einfach den folgenden Codesnipet ausführen
```R
install.packages(c("stringr", "data.table","dplyr", "tidyverse", "magrittr", "openxlsx", "sf"))
```
Die Bibliotheken für Python sind in der requirements.txt zu finden. Wichtig: Python 3 muss in der Version 3.6.x vorliegen.
Um die Bibliotheken zu installieren kann der folgende Codesnipet ausgeführt werden.

```Python
pip3 install requierements.txt -r
```


## Einschränkungen
Bitte beachten Sie, dass diese Arbeit nicht perfekt ist. Alle Modelle die gefunden und implementiert wurden liefern valide Ergebnisse, sind jedoch keinesfalls die besten Modelle die existieren. Die Performance jedes einzelnen Modells hätte mit mehr Zeit und mit mehr Computerpower verbessert werden können. Jedoch soll diese Arbeit auch nicht zeigen, wie man das beste Modell implementiert. Das wäre ohnehin für die meisten Usecases nicht sinnvoll.
Uns ging es viel mehr darum zu zeigen, dass das Kombinieren von Destatis-Daten und Immobilienscout-Daten sinnvoll ist und zu guten Vorhersageergebnissen führen kann. Des Weiteren wollten wir ein Gefühl dafür bekommen welcher Machine Learning Algorithmus am Besten für die vorhandene Datenbasis geeignet ist. Beide Anforderungen konnten wir unserer Meinung nach erfüllen und konnten darüber hinaus neue praxisrelevante Erkenntnisse gewinnen.

