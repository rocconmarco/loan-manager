<br />
<div id="readme-top" align="center">

<h3 align="center">Microcredit - Smart Contract</h3>

  <p align="center">
    Smart contract for blockchain-based microcredit services.
    <br />
    <a href="https://github.com/rocconmarco/loan-manager"><strong>Repository GitHub »</strong></a>
    <br />
  </p>
</div>

## About The Project

"Microcredit - Smart Contract" è un progetto che mira a risolvere una
delle problematiche più diffuse tra le persone con pochi mezzi finanziari:
l'accesso al credito. 

<br>

Tramite la tecnologia blockchain, si è voluto dare l'opportunità a tutti di prendere
in prestito delle somme, in un sistema trasparente e verificabile, che non necessita
di un controllo dello score creditizio del debitore, pur mantenendo la 
garanzia di restituzione dei prestiti.

<br>

Lo smart contract è la logica al cuore dell'applicativo, successive
integrazioni e una completa costruzione della piattaforma si vedranno necessarie
una volta deciso di rendere pubblico il progetto.

<br>

## Specs for nerds

Lo smart contract è stato sviluppato interamente in linguaggio Solidity,
tramite l'utilizzo di Remix IDE. Il contratto è poi stato creato sulla
testnet Sepolia, ed è possibile verificarne le transazioni su Etherscan
al seguente indirizzo:

<br>

<strong>0x43caC34655b3aC68d17c1bD0EB6EBcB30014bE22</strong>

<br>

Per verificare tutte le funzionalità dello smart contract di seguito
è descritto un possibile approccio di test:

<br>

<strong>Deposit of collateral and supply of liquidity</strong>

<br>

Selezionare due account di test, uno che agirà come "borrower" e l'altro come 
"lender". Con il primo account selezionare un sufficiente quantitativo di eth
e cliccare su "depositCollateral". Allo stesso modo, con il secondo account
selezionare un quantitativo (possibilmente più elevato) di eth e cliccare su
"supplyLiquidity".

<br>

In questo modo entrambi gli account saranno pronti a operare e il contratto
avrà un bilancio totale dato dalla somma del collateral e del supply.

<br>

<strong>Borrow</strong>

<br>

Per prendere in prestito dei fondi bisognerà disporre del collaterale necessario.
L'utente potrà prendere in prestito fino al 75% del collaterale disponibile,
per garantirne l'effettiva restituzione. Per attivare efficacemente la funzione
"borrow" bisognerà indicare l'indirizzo dell'utente dal quale prendere in prestito
le somme (quest'ultimo dovrà aver fornito sufficiente liquidità), il quantitativo
di wei da prendere in prestito (verranno accettati solo importi in wei, es. se viene
inserito 1, questo verrà inteso come 1 wei), e il numero di giorni che si prevede
di impiegare per la restituzione del prestito (il valore inserito non potrà essere 0).

<br>

Se tutte le condizioni verranno rispettate la transazione andrà a buon fine e 
la somma verrà trasferita nel wallet dell'utente. Da notare che l'equivalente
ammontare in collaterale verrà bloccato fino alla restituzione del prestito, agendo
come garanzia per lo stesso.

<br>

<strong>User balance, check loans, and check penalty</strong>

<br>

Queste tre sono delle funzioni getter, le quali non genereranno una transazione
on chain ma serviranno per controllare i dati presenti sulla stessa. Al fine 
di garantire la trasparenza del sistema, si è deciso di dare la possibilità a tutti,
anche a chi non partecipa attivamente nello scambio, di controllare le attività
nello smart contract. Per controllare il bilancio dell'utente, sarà sufficiente
inserire l'indirizzo dell'utente e cliccare su "userBalance". Verrà mostrata la situazione
dell'utente in termini di collaterale e supply disponibile, il valore totale dei
prestiti richiesti (attivi), e il numero totale dei prestiti richiesti (storico).

<br>

Per avere informazioni su uno specifico prestito, sarà necessario indicare, nuovamente,
l'indirizzo dell'utente e l'id del prestito in questione. Per ogni utente, il primo prestito
avrà id "0", tutti gli altri prestiti avranno un id consecutivo in ordine cronologico
fino al numero totale dei prestiti richiesti (numLoans in userBalance). Verranno visualizzate
tutte le informazioni essenziali del prestito, come indirizzo di borrower e lender, l'ammontare 
del prestito e degli interessi, l'interesse annuo e l'interesse effettivo, la data di 
attivazione e restituzione del prestito, i giorni mancanti alla data di restituzione stabilita, e 
lo stato del prestito.

<br>

L'utente avrà anche la possibilità di controllare se un prestito è soggetto
a penalità di ritardo tramite la funzione checkPenalty. In modo analogo alla funzione
precedente, dovrà essere fornito l'indirizzo dell'utente e l'id del prestito e verranno
mostrati i giorni di ritardo accumulati, il tasso annuo di penalità a cui è soggetto
il prestito, il tasso effettivo calcolato sui giorni di ritardo, e l'ammontare complessivo
della penalità.

<br>

Quest'ultimo punto in particolare vuole essere uno sforzo di trasparenza che permette
al lender di verificare se il borrower non ha rispettato i tempi di restituzione
e quanta penalità va aggiunta all'ammontare da restituire.

<br>

<strong>Cancel loan</strong>

<br>

L'utente ha la possibilità di annullare il prestito appena preso in prestito
entro il limite massimo di 1 giorno. Il ripensamento non avrà un impatto in termini
di importo da restituire e l'utente potrà semplicemente restituire la somma
presa in prestito senza interessi o penalità aggiuntive. Andrà effettuata una transazione
con la somma precisa in wei cliccando su "cancelLoan". Se la somma corrisponde e non
sarà ancora passato un giorno dall'attivazione del prestito, quest'ultimo sarà 
regolarmente restituito e il collaterale corrispondente sarà di nuovo accreditato
nel bilancio dell'utente.

<br>

<strong>Repay loan</strong>

<br>

Passato un giorno dall'attivazione del prestito, il borrower sarà obbligato
a restituire l'ammontare del prestito più gli interessi calcolati dalla libreria
Interest Calculator, che divide i prestiti in fasce temporali in base al tempo
di restituzione indicato dal borrower. Per restituire il prestito, l'utente 
dovrà effettuare una transazione di importo parti all'ammontare del prestito più
gli interessi (tale importo può essere controllato tramite la funzione getLoan).
Se l'importo corrisponde il prestito verrà ripagato correttamente, il corrispondente
ammontare in collaterale verrà riaccreditato sul bilancio del borrower, e l'ammontare
del prestito più gli interessi verrà accreditato nella "available supply" del lender.

<br>

In questo modo il valore totale del contratto sarà aumentato di valore rispetto alla
situazione iniziale, di una somma pari agli interessi aggiunti dal borrower.

<br>

Discorso analogo vale per la restituzione in ritardo. In tal caso, il borrower dovrà sommare
all'importo del prestito, non solo gli interessi ma anche la penalità totale che può essere
consultata tramite la funzione "checkPenalty". Se l'importo della transazione sarà corretto,
il prestito sarà restituito correttamente.

<br>

<strong>Withdraw collateral and supply</strong>

<br>

L'utente potrà, in qualsiasi momento, ritirare dal contratto le somme depositate come collateral
o come supply, a patto che siano disponibili e non utilizzate come garanzia (o come prestito).
Il totale delle somme disponibili per il ritiro potrà essere consultato in "userBalance". Basterà
quindi indicare la somma da ritirare (in wei) e cliccare su "withdrawCollateral" o su "withdrawSupply".

<br>

## Contact

<b>Marco Roccon - Digital Innovation & Development</b><br>
Portfolio website: https://rocconmarco.github.io/<br>
Linkedin: https://www.linkedin.com/in/marcoroccon/<br>
GitHub: https://github.com/rocconmarco

Contract address: 0x43caC34655b3aC68d17c1bD0EB6EBcB30014bE22

<br>

## Copyright

© 2024 Marco Roccon. Tutti i diritti riservati.
