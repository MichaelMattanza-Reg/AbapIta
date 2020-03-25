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
Questi ordini pianificati vengono convertiti in ordini di produzione schedulati per tempistiche e routing. Una volta che l'ordine di produzione è stato completato viene creata una conferma dell'ordine con movimenti merci e materiali usati. 
</br></br></br>
**Demand Management**   
La gestione della domanda è data dalla stima delle quantità e delle date di consegna per il prodotto finito. La gesitone della domanda sfrutta il *PIR* (Planned indipendent requirement) e il customer requirement.   
Le strategie di pianificazione devono essere fatte per ogni prodotto. Rappresenta il metodo di produzione. Ci sono due metodi per fare questo:   
- Made to stock: Indipendenetemente dagli ordini di vendita viene prodotto stock
- Made to order: Produzione di materiale in base agli ordini di vendita generati
</br></br></br>
**MRP (Material Requirement Planning)**   
Il MRP determina le carenze e crea le procedure per ottenere il necessario. Calcola e genera ordini pianificati per la produzione in-casa di materiali e ordini di acquisto per il materiale primario.   
   
Gestisce il tempo delle schedulazioni e calcola le date di produzione in ordini pianificati.   
   
Genera proposte di approvigionamento in base al BOM.
</br></br></br>
**Capacity Planning & Leveling**
La pianificazione di capacità è usata per analizzare la capacità dei centri di lavoro di gestire il sovraccarico e spostare gli ordini per evitare problemi sulla capacità ( collo di bottiglia ).   
   
I requisiti di capacità vengono generati dal MRP sui work center e fino a che i work center lavorano con capacità infinite e pianificano tutto sui centri di lavoro. E' richiesto livellare la capacità dei work center.   
   
La capacità viene impostata per forzare le pianificazioni di produzione tramite una tabella di pianificazione.
</br></br></br>
**Production Order**   
L'output del MRP è un ordine pianificato che deve essere convertito in un ordine di produzione per il proseguimento del processo.
L'ordine di produzione è un elemento di ricevuta fisso non affetto dalle lavorazioni del MRP, diversamente dall'ordine pianificato.
    
L'orinde di produzione è un documento che contiene i materiali e le quantità che devono essere prodotte. Contiene anche i componenti e le operazioni da effetturare nel work center. 

**Production Order Confirmation**   
Quando le merci vengono prodotte l'ordine di produzione deve essere confermato. 
Durante la conferma i materiali possono essere consumati in Backflush ( distinta base prelevata dal magazzino alla consegna del prodotto finito ) e l'entrata merci può essere fatta automaticamente tramite l'operazione di Control Key nel Routing.


**Production Order close**   
Una volta confermato un ordine, questo diventa teco e viene dai fabbisogni materiale.


