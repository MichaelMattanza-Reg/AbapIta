<h1>Modulo PP</h1>

Il modulo PP, Production Planning, e gestisce il processo di produzione di un prodotto finito. E' tutto basato sul Plant
( luogo specifico ). 
Esistono 5 principali Master Data per il modulo PP.

*Material Master*</br>
Il Material Master contiene informazioni su tutti i materiali gestiti e lavorati dalla compania. I materiali con caratteristiche comuni 
vengono raggruppati tra di loro ( finiti, primari, ecc... ).</br>
Viene utilizzato principalmente per:
- Comprare materiale
- Per un movimento materiale ( ricezione, problemi, ecc... )
- Per le fatture
- Per gli ordini di vendita e distribuzione 
- Per la pianificazione di produzione, schedulazioni e produzioni di processi confermati

*Bill of Material ( BOM )*</br>
E' una lista strutturata e completa di materiali con rispettive quantità utilizzati per produrre un prodotto. Viene utilizzata per 
la richiesta di materiali e il calcolo dei costi del prodotto.
</br></br>
*Work Center*</br>
E' una macchina o un gruppo di macchine dove vengono effettuate le operazioni. I work center vengono usati in task:
- Scheduling
- Capacity
- Costing

*Routing*</br>
Sequenza di azioni eeguite in un work center ( schedulazioni ). Vengono specificati anche i tempi per la lavorazione. 
</br></br>
*Production Version*</br>
E' un collegamento tra BOM e Routing. Possono esserci più versioni di processo per la produzione di un prodotto.</br> 
</br></br></br>
**Piano di produzione e controllo**</br>
*Planning*   
Basato sui piani di vendita di un prodotto. Con la domanda di un prodotto viene generato un input per la richiesta di materialo (MRP) che controlla la disponibiltà dei vari materiali primari usati durante le varie fasi di produzione del prodotto attraverso una Master Data (es. BOM).   
   
*Execution*   
Questi ordini pianificati vengono convertiti in ordini di produzione schedulati per tempistiche e routing. Una volta che l'ordine di produzione è stato completato viene creata una conferma dell'ordine, .... 
