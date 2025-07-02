## Relazione del Progetto: MyRoutine RPG
Tommaso Conti - Cristian Postovan.
1. Scopo del Progetto
Il progetto "MyRoutine RPG" nasce con l'obiettivo di fornire uno strumento motivazionale e organizzativo per la gestione della routine quotidiana. Si tratta di un'app mobile sviluppata in Flutter, pensata per trasformare le attività quotidiane in "quest" da completare, incentivando l'utente con un sistema a punti esperienza (XP), livelli e notifiche motivazionali.
L'app punta a rendere più gratificante l'organizzazione personale, introducendo dinamiche tipiche dei giochi di ruolo (RPG):
Creazione, modifica ed eliminazione di quest giornaliere
Sistema di progressione XP e livelli, con titoli onorifici
Statistiche utente
Notifiche giornaliere
Presenza di quest predefinite, personalizzabili e randomiche
2. Struttura del Codice Sorgente
Il codice è organizzato seguendo il principio della separazione delle responsabilità e le best practice architetturali:
main.dart: entry point dell'applicazione, imposta la struttura iniziale e richiama i servizi principali.
models/: contiene i modelli dati come Task e UserStats, che rappresentano rispettivamente le attività e le statistiche dell'utente. Include anche estensioni per gestire la difficoltà delle quest e il calcolo dell'XP.
repositories/: ogni area funzionale (Task, Statistiche, Notifiche, Routine preimpostate) ha un proprio repository che si occupa dell'accesso ai dati (persistenza locale, API, ecc.).
viewmodels/: ogni area ha un ViewModel dedicato che gestisce lo stato e la logica di presentazione, interagendo solo con i repository.
screens/: comprende le schermate principali:
home_screen.dart: dashboard principale con riepilogo statistiche e lista delle quest
task_form_screen.dart: form per la creazione/modifica di una quest
stats_screen.dart: mostra le statistiche dettagliate dell'utente
preset_routines_screen.dart: schermata per scegliere tra quest preimpostate
services/:
storage_service.dart: salva e recupera localmente quest, statistiche utente, orari delle notifiche e il conteggio giornaliero delle quest casuali usando SharedPreferences. Garantisce la persistenza dei dati tra le sessioni dell'app.
notification_service.dart: gestisce notifiche motivazionali giornaliere usando il pacchetto awesome_notifications, permettendo di inizializzarle, chiedere i permessi e programmarle a orari specifici. Le notifiche vengono inviate in modo ricorrente con contenuti personalizzati.
motivation_service.dart: recupera una citazione motivazionale casuale dall'API di ZenQuotes. Il metodo fetchMotivationalQuote() effettua una chiamata HTTP e restituisce la citazione formattata con autore.
widgets/: widget riutilizzabili come task_card.dart (scheda singola quest) e stats_header.dart (riepilogo utente nella home).
resources/: tutti i colori, le stringhe e le dimensioni usate nell'app sono ora centralizzati rispettivamente in colors.dart, strings.dart e dimens.dart, per garantire coerenza, riuso e facilità di manutenzione.
3. Punti di Forza
Separazione pulita delle responsabilità: ogni parte dell’app ha un ruolo chiaro, migliorando leggibilità e manutenibilità.
Stato immutabile e copyWith: migliora la stabilità dell'applicazione evitando effetti collaterali imprevisti.
Persistenza locale: grazie a shared_preferences, i dati vengono salvati tra una sessione e l'altra.
Esperienza utente curata: layout responsive, validazioni nei form, dialog di conferma per eliminazioni.
Notifiche locali (gestite via awesome_notification): permettendo di mandare notifiche motivazionali all’utente.
4. Possibili Migliorie
Login, registrazione e sincronizzazione cloud: L'integrazione di un sistema di autenticazione permetterebbe all'utente di salvare le proprie statistiche e quest sul cloud. Questo renderebbe possibile l'accesso da più dispositivi e garantirebbe il recupero dei dati.


Percorsi RPG personalizzati: L'introduzione di percorsi alternativi come Monarca Oscuro, Arcimago o Paladino offrirebbe varietà e personalizzazione all'esperienza dell'utente. Ogni percorso potrebbe prevedere una serie di titoli unici che si sbloccano salendo di livello e un set di quest predefinite coerenti con il ruolo scelto.


Pixel art del personaggio utente: L'app potrebbe includere un avatar in stile pixel art che rappresenti visivamente l'utente. L'aspetto del personaggio evolverebbe in base al livello e al percorso scelto, dando un feedback visivo immediato dei progressi e aumentando il senso di soddisfazione.


Lista amici: Implementare un sistema di amici permetterebbe agli utenti di vedere i progressi reciproci, condividere motivazione e creare una sana competizione. Ogni utente potrebbe vedere le statistiche attuali degli amici (livello, titoli, quest completate).


Calendario: Implementazione di una nuova schermata con all’interno un calendario dove possiamo visualizzare, modificare o cancellare tutte le quest programmate nel futuro .
5. Conclusioni
MyRoutine RPG è stato pensato per rispondere a un bisogno reale in modo creativo. Il sistema a quest e livelli, unito a un'interfaccia intuitiva e a notifiche motivazionali, ha dimostrato come la gamification possa essere applicata con successo anche a contesti quotidiani.
Siamo soddisfatti del risultato raggiunto e consapevoli delle numerose potenzialità di estensione futura.

