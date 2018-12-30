# Implémentation d'un parseur POP3 en langage C

Voici le rapport pour le projet d'Ingénierie des Protocoles. Il ya les instructions
sur les prérequis du logiciel ainsi que son fonctionnement (compilation et exécution).

## POP3

[Ici](POP3.md) vous pouvez trouver la documentation de POP3 qui est le protocole
choisis pour ce projet.
Il y a toutes les règles qui sont reconnues par le parseur.

## Parseur

Nous n'avons pas pu tester le code sur windows et il y a des problèmes sur MacOS.
Il est donc conseillé d'utiliser un environnement linux pour ce logiciel.

Le parseur utilise `bison`, `flex`, `libpcap` et la version 6 ou supérieur de `gcc/mingw`

`bison` ne permet pas de renvoyer de données. La fonction effectuant le parsing ne renvoie qu'un code d'erreur. Pour récupérer le résultat du parsing, on passe par une variable globale, initialisé dans la fonction `yyparse`. On a créé une fonction utilitaire qui appelle le parser et retourne la variable globale contenant la liste des commandes parsées.

```c
Command_list* parse(const char* str)
{
    extern Command_list* list_of_commands___;
    scan_string(str);
    yyparse();
    return list_of_commands___;
}
```

`bison` prend en entrée un flux de lexème. C'est pour ça qu'il est souvent associé à un lexer comme `flex` (utilisé ici). Le comportement par défaut de `flex` est de prendre en paramètre un fichier (`FILE*`). Pour lexer une chaîne de caractère, il faut utiliser des fonctions de `flex` pour lui indiquer quelles données prendre en entrée. C'est le but de la fonction `scan_string`.

```c
void scan_string(const char* str)
{
    yy_switch_to_buffer(yy_scan_string(str));
}
```

`bison` permet de créer le parser à partir d'une description de la grammaire du langage interprété. La description de la grammaire (faite dans `pop.y`), est très proche de la définition des commandes dans [pop3.md](POP3.md).

## Implémentation

**TODO : détailler les règles et comment on a fait pour vérifier si elles sont correctes**

*Par Benjamin Guighil, Paul Lenczner et Vincent Bonnevalle*
