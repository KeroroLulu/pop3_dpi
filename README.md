# Implémentation d'un parseur POP3 en langage C

## POP3

POP3 permet d'accéder dynamiquement à une boîte mail se trouvant dans un serveur
distant. Les opérations sont simples comme lire et supprimer le mail. Pour une
utilisation plus avancée il faudrait utiliser IMAP4.

Il y a  états dans POP3 :
1. Authorisation : cet état est le premier où le serveur envoie un message de la forme +OK POP3 server ready
2. Transaction : une fois que le client c'est identifier dans l'état d'authorisation qui permet de rentrer et gérer la boite mail.
3. Update : on rentre dans l'état d'Update lorsqu'on utilise la commande QUIT dans l'état de transaction ce qui met à jour la boite mail.

Voici les différentes commandes possibles :
* Principale
    * QUIT
    * STAT
    * LIST
    * RETR
    * DELE
    * NOOP
    * RSET
* Optionnelle
    * TOP
    * UIDL
    * USER
    * PASS
    * APOP
    * CAPA

### QUIT

Cette commande ne prend pas d'arguments et à différentes significations selon
l'état où se trouve le serveur. Dans l'état d'authorisation QUIT permet de se
déconnecter du serveur dans ce cas il recevra une répond +OK de la forme :

    +OK dewey POP3 server signing off

Dans l'état de mise à jour la commande QUIT supprime les messages qui sont
marqués comme supprimés avant de se déconnecter. Il y a deux réponses possibles :

* +OK
* -ERR some deleted messages not removed

Exemple :

    +OK dewey POP3 server signing off (maildrop empty) - si la boite mail est vide
ou
    +OK dewey POP3 server signing off (2 messages left) - si il reste 2 messages

### STAT

Cette commande ne prend pas d'arguments et peut être utilisé que dans l'état de
transaction.

Réponses possibles :
    +OK nn mm, avec nn le nombre de messages et mm la taille de la boite mail.
Exemple :
    C: STAT
    S: +OK 2 320

### LIST [msg]

Cette prend en argument qui est le numéro du message qu'on souhaite. Si on ne
met pas d'argument le serveur retournera la liste de tous les messages dans la
boite mail. Cette commande ne peut être utilisée que dans l'état de transaction.

Réponses possibles :
    +OK
    -ERR no such message
Exemple :
    C: LIST
    S: +OK 2 messages (320 octets)
    S: 1 120
    S: 2 200
    S: .
    ...
    C: LIST 2
    S: +OK 2 200
    ...
    C: LIST 3
    S: -ERR no such message, only 2 messages in maildrop

### RETR msg

Cette commande prend en argument le numéro du message, ce denier est obligatoire.
Si le message existe le serveur renverra le contenu de ce dernier. Cette commande
ne peut être utilisée que dans l'état de transaction.

Réponses possibles :
    +OK
    -ERR no such message
Exemple :
    C: RETR 1
    S: +OK 120 octets
    S: <le serveur POP3 envoie la totalité du message>
    S: .

### DELE msg

Cette commande prend en argument le numéro du message, ce denier est obligatoire.
Si le message existe le serveur le marquera comme supprimé. Cette commande ne
peut être utilisée que dans l'état de transaction.

Réponses possibles :
    +OK
    -ERR no such message
Exemple :
    C: RETR 1
    S: +OK message 1 deleted
    S: RETR 1
    S: -ERR message 1 already deleted

### NOOP

Cette commande ne prend pas d'arguments. Elle n'a aucun effet le serveur répondra
uniquement +OK. Ne peut être utilisé que dans l'état de transaction.

Exemple :
    C: NOOP
    S: +OK

### RSET

Cette commande ne prend pas d'arguments. Si il existe des messages marqués comme
supprimés, les marques seront effacées. Ne peut être utilisé que dans l'état de
transaction.

Réponses possibles :
    +OK
Exemple :
    C: RSET
    S: +OK maildrop has 2 messages (320 octets)

### TOP

### UIDL

### USER

### PASS

### APOP

## Parseur

**TODO : mettre le code du parseur avec les explications**

## Implémentation

**TODO : détailler les règles et comment on a fait pour vérifier si elles sont correctes**

*Par Benjamin Guighil, Paul Lenczner et Vincent Bonnevalle*
