# Projet Substack: Le virage nativiste du PQ

## Contexte du projet

Ce projet est le premier article de notre chaîne Substack **Opubliq** (https://opubliq.com/).

**À propos d'Opubliq:**
- Startup de services en analyse de données politiques
- Mission: transformer les données en actions stratégiques pour comprendre l'opinion publique
- Services: analyse de données, études personnalisées, accompagnement stratégique de campagnes
- Public cible: acteurs politiques, équipes électorales, organisations

**Objectifs de ce billet (content marketing):**
- Démontrer nos capacités techniques en analyse de données électorales
- Générer des leads commerciaux (équipes de campagne, partis politiques)
- Établir notre crédibilité comme experts de l'opinion publique québécoise
- Créer du contenu partageable pour augmenter notre visibilité
- Produire des analyses rigoureuses et accessibles en français

**Contraintes éditoriales:**
- **Public cible:** Grand public intéressé par la politique (pas nécessairement politologues)
- **Ton:** Neutre politiquement, analytique, data-driven, rigoureux mais accessible
- **Longueur:** Approfondie mais pas trop longue, digestible
- **Visuel:** 1-2 graphiques facilement compréhensibles et partageables sur LinkedIn
- **Objectif:** Impressionner par la qualité de l'analyse sans être trop complexe

## Sujet de l'article

**Thème principal:** Le virage "nativiste" du Parti Québécois sur les enjeux d'immigration et de laïcité

**Contexte politique (octobre 2025):**
- Le PQ mène dans les sondages avant l'élection de 2026
- Nouvelles positions controversées sur l'immigration et la laïcité
- Débat public intense sur ces enjeux

**Positions récentes du PQ:**
1. **Sur la laïcité** (appuis des membres PQ):
   - Interdiction des signes religieux "ostensibles" au primaire (90% d'appui)
   - Interdiction des prières de rue (95% d'appui)
   - Interdiction des prières dans établissements scolaires publics (96% d'appui)

2. **Sur l'immigration:**
   - Discours sur "seuils astronomiques" nuisant à la natalité
   - Publicité controversée mélangeant demandeurs d'asile et immigration permanente
   - Critiquée pour affirmations inexactes par experts (Louise Harel, Pierre Céré, universitaires)

**Critiques médiatiques:**
- Paul Journet (La Presse): "surenchère" entre CAQ et PQ - "ma laïcité est plus grosse que la tienne"
- Régis Labeaume: exploitation cynique des enjeux identitaires pour vote francophone
- CBC: Question si les musulmans sont considérés comme Québécois à part entière
- Controverse éditoriale: La Presse refuse réplique du PQ accusant le journal de "diffamation"

**Définition du "virage nativiste":**
Le PQ semble adopter une approche qui:
- Lie immigration élevée à menace culturelle/démographique
- Cible particulièrement pratiques musulmanes
- Priorise protection identité québécoise "traditionnelle"
- Utilise cadrage identitaire plutôt qu'économique

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

**Questions de recherche:**

1. **Profil des électeurs du PQ**
   - Qui vote PQ? Démographie (âge, éducation, langue, région)
   - Comment ce profil a-t-il évolué entre 2018 et 2022?

2. **Attitudes sur l'immigration et laïcité**
   - Les électeurs PQ sont-ils plus restrictifs que ceux des autres partis?
   - Quelle est l'ampleur des différences inter-partis?
   - Évolution temporelle: durcissement entre 2018 et 2022?

3. **Identité et nativisme**
   - Lien entre identité québécoise forte et positions sur immigration
   - Corrélation avec attitudes envers musulmans, immigrants
   - Le PQ capte-t-il un électorat plus "nativiste"?

**Variables clés à analyser:**
- Vote PQ 2018 et 2022 (Q6, cps_votechoice)
- Attitudes immigration (Q39, cps_immig, cps_attractimm)
- Thermomètres groupes (Q34a, cps_groups2: immigrants, musulmans)
- Signes religieux fonction publique (Q44, variables laïcité 2022)
- Identité QC vs Canada (Q20A/B, cps_qc_attach, cps_can_attach)
- Critères être "Québécois" (Q22)
- Démographie: âge, éducation, langue, région

**Graphiques LinkedIn-friendly à produire:**
1. **Graphique principal:** Attitudes sur immigration par parti (barres comparatives simples)
   - Axe Y: % favorable à réduire immigration
   - Axe X: Partis (PLQ, PQ, CAQ, QS)
   - Titre accrocheur, couleurs partis, message clair

2. **Graphique secondaire (optionnel):** Évolution temporelle 2018-2022
   - Ligne montrant durcissement attitudes anti-immigration chez électeurs PQ
   - Ou profil démographique électeurs PQ (âge, éducation)

## Stack technique

**Langage principal:** R

**Librairies suggérées:**
- `dplyr` et autres packages de la `tidyverse` pour la manipulation de données (ne jamais loader `tidyverse` directement)
- `ggplot2` pour les visualisations
- `haven` pour lire les fichiers SPSS/SAS
- `knitr`/`rmarkdown` pour la production du rapport

## Structure proposée de l'article

**Format:** Article Substack de longueur moyenne (8-12 minutes de lecture)

1. **Introduction (hook accrocheur)**
   - Lead avec citation controversée ou fait surprenant
   - Présentation de la question: le PQ a-t-il vraiment viré "nativiste"?
   - Annonce: "Nous avons analysé les données d'enquêtes 2018 et 2022..."

2. **Méthodologie (court et accessible)**
   - Sources: études électorales québécoises
   - Échantillon, période (1 paragraphe maximum)
   - Définition simple du "nativisme" pour lecteurs non-spécialistes

3. **Analyse principale: Qui vote PQ en 2022?**
   - Graphique #1: Attitudes immigration par parti
   - Constat principal en gras
   - 2-3 paragraphes d'interprétation accessible

4. **Évolution 2018-2022: Un durcissement?**
   - Graphique #2: Évolution temporelle OU profil démographique
   - Comparaison avant/après
   - Mise en contexte avec positions récentes du parti

5. **Ce que ça signifie pour 2026**
   - Interprétation stratégique (neutre)
   - Implications pour campagne électorale
   - Questions ouvertes

6. **Conclusion**
   - Résumé des constats principaux
   - Ouverture: "Ces données soulèvent des questions importantes..."
   - [CTA subtil?] "Pour des analyses approfondies de votre électorat..."

**Note méthodologique (encadré ou fin):**
- Détails techniques pour lecteurs intéressés
- Lien vers données brutes/codebooks