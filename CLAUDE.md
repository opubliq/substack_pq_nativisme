# Projet Substack: Le virage nativiste du PQ

## Contexte du projet

Ce projet est le premier article de notre chaîne Substack **Opubliq** (https://opubliq.com/).

**Objectifs:**
- Démontrer nos capacités en analyse de données politiques
- Créer du contenu data science de qualité sur la politique québécoise
- Développer notre visibilité et notre réputation
- Produire des analyses en français

## Sujet de l'article

**Thème principal:** Le virage "nativiste" du Parti Québécois sur les enjeux d'immigration et de laïcité

**Contexte politique (octobre 2025):**
- Le PQ mène dans les sondages
- Nouvelles positions controversées sur l'immigration et la laïcité
- Débat public intense sur ces enjeux

## Sources médiatiques

**Articles de référence:**
- [PQ critiqué pour une publicité sur l'immigration](https://www.lapresse.ca/actualites/politique/2025-09-11/le-pq-critique-pour-une-publicite-sur-l-immigration.php)
- [Le référendum en questions](https://www.lapresse.ca/actualites/chroniques/2025-08-31/le-referendum-en-questions.php)
- [On est mal barrés](https://www.lapresse.ca/dialogue/chroniques/2025-09-15/politique-quebecoise/on-est-mal-barres.php)
- [Pourquoi la réplique du PQ n'a pas été publiée](https://www.lapresse.ca/actualites/chroniques/2025-10-19/dans-le-calepin-de-l-editeur-adjoint/voici-pourquoi-la-replique-du-pq-n-a-pas-ete-publiee.php)
- [Ma laïcité est plus grosse que la tienne](https://www.lapresse.ca/actualites/chroniques/2025-10-02/ma-laicite-est-plus-grosse-que-la-tienne.php)
- [PQ: interdiction des signes religieux au primaire](https://www.lapresse.ca/actualites/politique/2025-09-25/eleves-du-primaire/le-pq-compte-interdire-le-port-de-signes-religieux.php)
- [Plan immigration et natalité du PQ](https://ici.radio-canada.ca/nouvelle/2115650/parti-quebecois-plan-immigration-natalite?depuisRecherche=true)

## Données

**Source principale:** Études électorales québécoises 2018 et 2022
- Portail: https://csdc-cecd.ca/portail-quebecois-sur-lopinion-publique/#section1

**Questions de recherche potentielles:**
- Quel est le profil démographique des électeurs du PQ?
- Comment les attitudes sur l'immigration varient-elles selon les partis?
- Évolution des positions sur la laïcité entre 2018 et 2022
- Corrélations entre identité nationale et positions sur l'immigration

## Stack technique

**Langage principal:** R

**Librairies suggérées:**
- `dplyr` et autres packages de la `tidyverse` pour la manipulation de données (ne jamais loader `tidyverse` directement)
- `ggplot2` pour les visualisations
- `haven` pour lire les fichiers SPSS/SAS
- `knitr`/`rmarkdown` pour la production du rapport

## Structure proposée de l'article

1. **Introduction:** Contexte politique actuel
2. **Méthodologie:** Présentation des données et méthodes
3. **Analyse 1:** Profil des électeurs du PQ
4. **Analyse 2:** Attitudes sur l'immigration par parti
5. **Analyse 3:** Évolution temporelle (2018-2022)
6. **Conclusion:** Interprétation et mise en contexte
7. **Annexes:** Détails méthodologiques