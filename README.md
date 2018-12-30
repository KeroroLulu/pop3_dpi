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

```c
Command_list* parse(const char* str)
{
    extern Command_list* list_of_commands___;
    scan_string(str);
    yyparse();
    return list_of_commands___;
}
```

```c
void scan_string(const char* str)
{
    yy_switch_to_buffer(yy_scan_string(str));
}
```

voici les morceaux de codes permettant de parser les commandes.

## Implémentation

**TODO : détailler les règles et comment on a fait pour vérifier si elles sont correctes**

*Par Benjamin Guighil, Paul Lenczner et Vincent Bonnevalle*
