<h1>Business Object Processing Framework</h1>

Il BOPF è un framework basato su Abap Object Oriented. Fornisce un insieme di servizi e funzionalità per accelerare, standardizzare e modularizzare gli sviluppi. Serve per gestire l'intero ciclo di vita dello sviluppo sotto tutti gli aspetti, come gestire e adattare vari componenti (es. Dynpro UI) all'infrastruttura sulla quale vengono implementati.

**Elementi del BOPF**   
Ogni business object del bopf rappresenta un nodo di un albero gerarchico. L'insieme di questi nodi compone il bopf. In ogni nodo è incluso un oggetto con la propria logica di implementazione e una tabella a dictionary, dove ogni istanza del nodo corrisponde ad un record nella tabella. Questo record lega l'oggetto implementato alla logica legata al tipo di nodo.

**Composizione di un Business Object**   
*Nodi*   
I nodi sono usati per modellare il BO. Sono impostati in modo gerarchico sotto un nodo principale (tipo XML).
Esistono diversi tipi di nodi ma vengono utilizzati principalmente quelli persistenti. Possono anche esserci nodi transitori, caricati in runtime.
Ogni nodo contiene uno o più attributi che definiscono il dato contenuto nel nodo stesso e variano in base al tipo di nodo. A runtime un nodo è un container con n righe ( 0 < n < x ).

*Azioni*   
Definiscono le azioni del BO e vengono assegnate al singolo nodo nel BO. La funzionalità fornita da un'azione è solitamente definita in una classe che implementa l'interfaccia /BOBF/IF_FRW_ACTION.

*Associazioni*   
Nonostante i BO siano creati come entità a se stanti possono essere relazionati tra di loro direttamente o indirettamente.
Questo permette che loro possano interagire tra di loro per creare assiemi complessi.

*Determinazioni*   

