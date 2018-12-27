# Implémentation d'un parseur POP3 en langage C

## POP3

POP3 permet d'accéder dynamiquement à une boîte mail se trouvant dans un serveur
distant. Les opérations sont simples comme lire et supprimer le mail. Pour une
utilisation plus avancée il faudrait utiliser IMAP4.

Il y a  états dans POP3 :
1. Authorisation : cet état est le premier où le serveur envoie un message de la forme +OK POP3 server ready
2. Transaction : une fois que le client c'est identifié dans l'état d'authorisation qui permet de rentrer et gérer la boite mail.
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

Dans la suite du rapport si une commande a en paramètre le numéro du message, ce
dernier ne doit pas être marqué comme supprimé.

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

* +OK nn mm, avec nn le nombre de messages et mm la taille de la boite mail.

Exemple :

    C: STAT

    S: +OK 2 320

### LIST [msg]

Cette prend en argument qui est le numéro du message qu'on souhaite. Si on ne
met pas d'argument le serveur retournera la liste de tous les messages dans la
boite mail. Cette commande ne peut être utilisée que dans l'état de transaction.

Réponses possibles :

* +OK
* -ERR no such message

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

* +OK
* -ERR no such message

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

* +OK
* -ERR no such message

Exemple :

    C: DELE 1

    S: +OK message 1 deleted

    S: DELE 1

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

* +OK

Exemple :

    C: RSET

    S: +OK maildrop has 2 messages (320 octets)

### TOP msg n

Cette commande prend en paramètre le numéro du message et le nombre de ligne qui
doit être positif. Les deux arguments sont obligatoires. Si le message existe le
serveur retournera plusieurs lignes. La première ligne sera l'entête suivis des
n premières lignes du message. Ne peut être utilisé que dans l'état de transaction.

Réponses possibles :

* OK+
* -ERR no such message

Exemple :

    C: TOP 1 10

    S: +OK

    S: <the POP3 server sends the headers of the
       message, a blank line, and the first 10 lines
       of the body of the message>

    S: .

    ...

    C: TOP 100 3

    S: -ERR no such message

### UIDL [msg]

Cette commande prend en argument le numéro du message ce qui est optionnel. Si il
n'y a pas d'arguments le serveur renverra plusieurs réponses qui sera la liste des
messages qui ne sont pas marqués comme supprimés avec leurs id uniques. Ne peut
être utilisé que dans l'état de transaction.

Réponses possibles :

* +OK suivit de la liste des id-uniques
* -ERR no such message

Exemple :

    C: UIDL

    S: +OK

    S: 1 whqtswO00WBw418f9t5JxYwZ

    S: 2 QhdPYR:00WBw1Ph7x7

    S: .

    ...

    C: UIDL 2

    S: +OK 2 QhdPYR:00WBw1Ph7x7

    ...

    C: UIDL 3

    S: -ERR no such message, only 2 messages in maildrop

### USER name et PASS string

Ces commandes doivent être utilisées en ensemble. USER prend en argument le nom
de la boite mail à laquelle on souhaite se connecté et PASS prend le mot de passe
de cette dernière. Les arguments sont tous obligatoire. Le client peut également
choisir de faire QUIT pour arrêter la session.
Si le serveur donne une réponse positive à USER cela veut dire que le client peut
essayer de se connecter en utilisant PASS à la boite mail. Si la réponse est
négative cela veut dire que la boite mail n'existe pas ou n'est pas valide.
Ces commandes sont à utiliser dans l'état d'authorisation.

Réponses possibles USER :

* +OK name est une boite mail valide
* -ERR la boite mail n'existe pas

Exemple USER :

    C: USER frated

    S: -ERR sorry, no mailbox for frated here

    ...

    C: USER mrose

    S: +OK mrose is a real hoopy frood

Réponses possibles PASS :

    * +OK la boite mail est vérouillée et prête
    * -ERR mot de passe invalide
    * -ERR il n'est pas possible de verouiller la boite mail

Exemple PASS :

    C: USER mrose

    S: +OK mrose is a real hoopy frood

    C: PASS secret

    S: -ERR maildrop already locked

    ...

    C: USER mrose

    S: +OK mrose is a real hoopy frood

    C: PASS secret

    S: +OK mrose's maildrop has 2 messages (320 octets)

### APOP name digest

Cette commande prend en argument le nom de la boite mail en string, et un digest
MD5 en string également. Les deux arguments sont obligatoires.
Elle remplace l'utilisation de USER/PASS pour la connexion à la boite mail. Lorsque
le serveur signale qu'il est prêt il donne un timestamp qui sera ensuite utilisé.
Il y aura un secret partagé uniquement du client et du serveur qui sera mis à la
suite du timestamp et chiffré par MD5 puis envoyé par en digest.
Cette commande est à utiliser dans l'état d'authorisation.

Réponses possibles :

    * +OK maildrop locked and ready
    * -ERR permission denied

Exemples :

    S: +OK POP3 server ready <1896.697170952@dbc.mtview.ca.us>

    C: APOP mrose c4c9334bac560ecc979e58001b3e22fb

    S: +OK maildrop has 1 message (369 octets)

Dans cet exemple, le secret partagé est le string 'tanstaaf'. Par conséquent,
l'algorithme MD5 est appliqué à la chaîne

    <1896.697170952@dbc.mtview.ca.us>tanstaaf

Qui produit le digest suivant

    c4c9334bac560ecc979e58001b3e22fb

## Parseur

**TODO : mettre le code du parseur avec les explications**

## Implémentation

**TODO : détailler les règles et comment on a fait pour vérifier si elles sont correctes**

*Par Benjamin Guighil, Paul Lenczner et Vincent Bonnevalle*
