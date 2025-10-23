# Plan d'analyse: Le virage nativiste du PQ

## Question centrale

**Le virage nativiste du PQ: stratégie de mobilisation de sa base ou calcul d'expansion électorale?**

**Sous-questions:**
1. Le discours nativiste plaît-il surtout aux péquistes convaincus (base militante) ou aussi à l'électorat potentiel?
2. Y a-t-il un bassin d'électeurs nativistes sous-exploité que le PQ pourrait capter?
3. Ou au contraire, ce discours ferme-t-il des portes et crée-t-il un plafond électoral?

## Trame narrative (ébauche)

1. **Hook:** Les positions controversées du PQ en 2025 (90% appui interdiction signes religieux primaire)
   - Le PQ mène dans les sondages avec un discours durci sur immigration/laïcité
   - Question: Est-ce une stratégie gagnante ou risquée?

2. **Cadrage stratégique:** Deux visions possibles
   - **Vision A - Mobilisation de base:** Discours qui rallye les fidèles mais ferme des portes = plafond électoral
   - **Vision B - Expansion:** Discours qui capte un bassin nativiste sous-exploité = potentiel de croissance

3. **Analyse data 2018-2022:**

   **Analyse 1: Qui est nativiste au Québec?**
   - Base militante PQ vs électeurs actuels PQ vs électorat potentiel PQ vs rejet PQ
   - Sur attitudes immigration, laïcité, critères "être Québécois"
   - **Si base >> électeurs >> électorat potentiel:** Stratégie de base risquée
   - **Si base ≈ électeurs ≈ électorat potentiel:** Alignement, expansion viable

   **Analyse 2: Le plafond électoral**
   - Qui rejette catégoriquement le PQ?
   - Profil de ces électeurs: sont-ils modérés sur immigration?
   - Taille du bassin accessible vs bassin fermé

   **Analyse 3: Évolution 2018-2022** (secondaire)
   - Les électeurs PQ ont-ils changé entre 2018 et 2022?
   - Le PQ a-t-il capté un nouveau segment?

4. **Réponse:** [À déterminer selon résultats]

   **Scénario A - "La stratégie risquée":**
   - Base militante très nativiste
   - Mais électeurs actuels plus modérés
   - Et électorat potentiel beaucoup moins nativiste
   - → Le PQ mobilise sa base au risque d'un plafond électoral

   **Scénario B - "Le bassin sous-exploité":**
   - Base militante nativiste
   - Électeurs actuels aussi nativistes
   - ET électorat potentiel également nativiste
   - → Le PQ a identifié un segment de croissance viable

   **Scénario C - "Le piège de la base":**
   - Base militante très nativiste (pousse le parti)
   - Mais électeurs pragmatiques + électorat potentiel modérés
   - Rejet élevé chez modérés
   - → Le parti est prisonnier de sa base militante

5. **Implications 2026:**
   - Selon le scénario, quelles sont les perspectives du PQ?
   - Peut-il devenir majoritaire ou restera-t-il plafonné?
   - Les autres partis doivent-ils s'inquiéter ou pas?

## Questions utilisées

### A. NATIVISME - Critères "être vraiment Québécois"

**belanger2018 - Q22:** "Pour être vraiment Québécois, à quel point est-il important..."
- Q22_1: D'être né au Québec
- Q22_2: D'avoir vécu la plus grande partie de sa vie au Québec
- Q22_3: D'être capable de parler le français
- Q22_4: D'être catholique [PAS dans 2022]
- Q22_5: De respecter les institutions politiques et les lois québécoises
- Q22_6: De se sentir Québécois
- Q22_7: D'avoir des ancêtres français
- Q22_8: De partager les valeurs des Québécois

Échelle: Très important / Assez important / Peu important / Pas important du tout

**maheo2022 - pes_nativism:** "Certaines personnes disent que les critères ci-bas sont importants pour être un véritable Québécois"
- pes_nativism_1: Être né(e) au Québec
- pes_nativism_2: Que vos grands-parents soient nés au Québec [comparable à "ancêtres français"]
- pes_nativism_3: Être capable de parler le français
- pes_nativism_4: D'être capable de parler l'anglais [PAS dans 2018]
- pes_nativism_5: Respecter les coutumes et les traditions du Québec [PAS dans 2018]
- pes_nativism_6: D'avoir vécu la plus grande partie de sa vie au Québec
- pes_nativism_7: De se sentir Québécois
- pes_nativism_8: De partager les valeurs des Québécois
- pes_nativism_9: De respecter les institutions politiques et les lois québécoises

Échelle: [À vérifier dans codebook complet]

**ITEMS COMPARABLES (7 items communs):**
1. ✅ Né au Québec
2. ✅ Grands-parents/ancêtres nés au Québec
3. ✅ Parler français
4. ✅ Vécu la plus grande partie de sa vie au Québec
5. ✅ Se sentir Québécois
6. ✅ Partager les valeurs des Québécois
7. ✅ Respecter institutions politiques et lois

**Indice à créer:**
- Score nativisme "ethnique" (items 1, 2, 3)
- Score nativisme "civique" (items 4, 5, 6, 7)
- Ratio ethnique/civique par parti et année

---

### B. IMMIGRATION - Attitudes générales

#### Niveau souhaité d'immigration

**belanger2018 - Q39:** "Il y a trop d'immigrants au Québec"
- Échelle: Tout à fait en désaccord / Plutôt en désaccord / Ni en accord ni en désaccord / Plutôt d'accord / Tout à fait d'accord

**maheo2022 - cps_immig:** "Pensez-vous que le Canada devrait admettre..."
- Plus d'immigrants
- Moins d'immigrants
- À peu près autant d'immigrants que maintenant

**maheo2022 - cps_attractimm:** "Pensez-vous que le Québec devrait essayer..."
- D'attirer plus d'immigrants dans la province
- D'attirer moins d'immigrants dans la province
- De maintenir le niveau d'immigrants comme il est actuellement

**durand2018 - rts_q6:** "Pensez-vous que le Québec devrait réduire, garder le même nombre, ou augmenter le nombre d'immigrants qu'il accueille chaque année?"
- Réduire le nombre
- Garder le même nombre
- Augmenter le nombre

**NOTE:** Pas exactement identiques, mais **conceptuellement comparables**
- Créer variable dichotomique: "Favorable à réduire immigration" (Oui/Non)

---

### C. THERMOMÈTRES - Sentiments envers groupes

**belanger2018 - Q34a:** "Que pensez-vous des groupes suivants?" (0-10)
- Immigrants
- Musulmans vivant au Canada
- Minorités ethnoculturelles
- Francophones au Québec
- Anglophones au Québec

**maheo2022 - cps_groups2:** "Que pensez-vous des différents groupes ci-dessous?" (0-100)
- cps_groups2_6: Les immigrants
- cps_groups2_16: Les musulmans vivant au Canada
- cps_groups2_11: Les francophones vivant au Québec
- cps_groups2_18: Les anglophones vivant au Québec
- cps_groups2_7: Les peuples autochtones
- cps_groups2_17: Les allophones vivant au Québec

**TRAITEMENT:**
- Convertir échelles (2018: 0-10 → 0-100 en multipliant par 10)
- Comparer moyennes par parti et année

---

### D. LAÏCITÉ - Positions sur signes religieux

**belanger2018 - Q44:** "Selon vous, devrait-on interdire le port de signes religieux visibles pour les employés de la fonction publique au Québec?"
- Oui
- Non
- Je ne sais pas

**belanger2018 - Q48:** "Certaines personnes pensent que le crucifix à l'Assemblée nationale doit être laissé en place pour refléter l'histoire du Québec. D'autres pensent qu'il devrait être retiré pour affirmer que le Québec est une société laïque. Quelle est votre propre opinion à ce sujet?"
- Le crucifix doit être laissé en place
- Le crucifix devrait être retiré
- Je ne sais pas

**maheo2022:** [Chercher variables laïcité dans section PES - à compléter]

---

### E. IDENTITÉ - Attachement Québec vs Canada

**belanger2018:**
- Q18: "Quel est votre degré d'attachement au Québec?"
- Q19: "Et quel est votre degré d'attachement au Canada?"
- Q20A/B: "Diriez-vous que vous vous considérez... Uniquement Québécois / D'abord Québécois puis Canadien / Également / D'abord Canadien puis Québécois / Uniquement Canadien"

**maheo2022:**
- cps_qc_attach: "Quel est votre degré d'attachement au Québec?"
- cps_can_attach: "Quel est votre degré d'attachement au Canada?"

**TRAITEMENT:**
- Créer score différentiel: Attachement QC - Attachement Canada
- Plus élevé = identité québécoise forte

---

### F. SOUVERAINETÉ

**belanger2018 - Q26:** "Si un référendum sur l'indépendance avait lieu aujourd'hui vous demandant si vous voulez que le Québec devienne un pays indépendant, voteriez-vous OUI ou voteriez-vous NON?"

**maheo2022 - cps_qc_referendum:** Même question

**durand2018 - rts_q7:** "En ce qui concerne l'indépendance du Québec, c'est-à-dire que le Québec ne fasse plus partie du Canada, êtes-vous personnellement..."
- Très favorable / Assez favorable / Assez opposé / Très opposé

---

### G. CATÉGORISATION DES ÉLECTEURS

#### Variables de vote

**belanger2018:**
- Q6: "Pour quel parti avez-vous voté?"
- Q7: "Est-ce que ce parti était votre premier choix?" (Oui/Non)
- Q8: "Quel parti était votre premier choix?" [si Q7=Non]

**maheo2022:**
- cps_votechoice1/2/3: Intention de vote / vote si décidait / vote réel
- cps_votesecond: "Et quel parti serait votre deuxième choix?"
- cps_negativevote: "Y a-t-il des partis pour lesquels vous ne voteriez absolument pas?"

**durand2018:**
- rts_q2: "Et pour qui avez-vous voté?"

#### Identification partisane (PID)

**belanger2018:**
- Q56: "En politique provinciale, vous considérez-vous habituellement comme un... Libéral / Péquiste / Caquiste / Solidaire / Rien de cela"
- Q57: "Vous sentez-vous très fortement [péquiste], assez fortement, ou pas très fortement?"

**maheo2022:**
- Section "PID Prov" (à localiser dans codebook)
- Même structure probable

#### Thermomètres de partis

**maheo2022 seulement:**
- cps_partytherm_23: Parti libéral du Québec
- cps_partytherm_25: Parti québécois
- cps_partytherm_27: Coalition avenir Québec
- cps_partytherm_30: Québec solidaire
- cps_partytherm_33: Parti conservateur du Québec

---

## Variables pour catégoriser les électeurs

### A. VOTE ET INTENTIONS DE VOTE

**Mots-clés pour recherche dans codebooks:** `vote`, `voté`, `parti`, `choix`, `PLQ`, `PQ`, `CAQ`, `QS`, `Parti Québécois`, `Parti québécois`, `péquiste`

#### belanger2018

**Vote réel 2018:**
- **Q5:** "À chaque élection, plusieurs personnes sont incapables de voter... Laquelle correspond le mieux à votre cas?"
  - Je n'ai pas voté
  - Je voulais voter mais ne suis pas allé voter
  - Je vote généralement mais ne suis pas allé cette fois-ci
  - Je suis certain d'avoir voté [→ Q6]
  - Je n'étais pas éligible

- **Q6:** "Pour quel parti avez-vous voté?" [SI Q5 = certain d'avoir voté]
  - Parti libéral du Québec
  - Parti québécois
  - Coalition avenir Québec
  - Québec solidaire
  - Un autre parti
  - J'ai annulé mon vote

**Si n'a pas voté:**
- **Q5A:** "Si vous aviez été voter le jour de cette élection, pour quel parti auriez-vous voté?"
  - [Mêmes options que Q6]

**Premier vs deuxième choix:**
- **Q7:** "Est-ce que ce parti était votre premier choix?" [SI Q6 = un parti]
  - Oui [→ Q9]
  - Non [→ Q8]

- **Q8:** "Quel parti était votre premier choix?" [SI Q7 = Non]
  - [Mêmes options]

**Timing du choix:**
- **Q6A:** "Quand avez-vous arrêté votre choix pour [parti choisi en Q6]?"
  - Plusieurs mois avant la campagne électorale
  - Quelques semaines avant la journée de l'élection
  - Quelques jours avant la journée de l'élection
  - La journée même de l'élection

**Vote passé:**
- **Q9:** "Pour quel parti aviez-vous voté il y a 4 ans lors de l'élection provinciale précédente (7 avril 2014)?"
  - [Mêmes options + "Je ne me rappelle plus" + "Je n'ai pas voté"]

#### maheo2022

**Campaign Period Survey (CPS) - Avant élection:**

**Intention de vote:**
- **cps_turnout:** "L'élection au Québec est prévue pour le 3 octobre 2022. Dans le cadre de cette élection, êtes-vous..."
  - Certain(e) de voter [→ cps_votechoice1]
  - Enclin(e) à voter [→ cps_votechoice1]
  - Peu enclin(e) à voter [→ cps_votechoice2]
  - Certain(e) de ne pas voter
  - J'ai déjà voté [→ cps_votechoice3]
  - Je ne suis pas éligible au vote

**Premier choix (selon cps_turnout):**
- **cps_votechoice1:** "Quel parti prévoyez-vous voter?" [SI certain/enclin à voter]
- **cps_votechoice2:** "Si vous décidez de voter, pour quel parti prévoyez-vous voter?" [SI peu enclin]
- **cps_votechoice3:** "Pour quel parti avez-vous voté?" [SI déjà voté]
  - Parti libéral du Québec
  - Parti québécois
  - Coalition avenir Québec
  - Québec solidaire
  - Parti conservateur du Québec
  - Autre parti
  - Don't know / Préfère ne pas répondre

**Si indécis:**
- **cps_votelean:** "Êtes-vous tenté(e) d'appuyer un parti en particulier?" [SI votechoice = Don't know]
  - [Mêmes options]

**Deuxième choix:**
- **cps_votesecond:** "Et quel parti serait votre deuxième choix?" [SI a un premier choix]
  - [Mêmes options, excluant premier choix]
  - Je ne sais pas

**Vote négatif:**
- **cps_negativevote:** "Y a-t-il un ou des partis pour lesquels vous ne voteriez absolument pas?" [Sélection multiple]
  - cps_negativevote_1: Parti libéral du Québec
  - cps_negativevote_2: Parti québécois
  - cps_negativevote_3: Coalition avenir Québec
  - cps_negativevote_4: Québec solidaire
  - cps_negativevote_7: Parti conservateur du Québec
  - cps_negativevote_5: Autre parti
  - cps_negativevote_6: Je pourrais voter pour n'importe quel parti

**Post-Election Survey (PES) - Après élection:**

**Vote réel 2022:**
- **pes_turnout:** "À chaque élection, certaines personnes sont dans l'incapacité d'aller voter... Avez-vous voté lors de l'élection provinciale du 3 octobre 2022?"
  - Yes / Oui [→ pes_votechoice]
  - No / Non
  - Je voulais voter mais je n'ai pas pu
  - Je vote généralement mais je ne suis pas allé(e) cette fois-ci

- **pes_votechoice:** "Pour quel parti avez-vous voté?" [SI pes_turnout = Yes]
  - Parti libéral du Québec
  - Parti Québécois
  - Coalition avenir Québec
  - Québec solidaire
  - Parti conservateur du Québec
  - Autre parti

---

### B. IDENTIFICATION PARTISANE (PID)

**Mots-clés pour recherche:** `identification`, `considérez-vous`, `péquiste`, `libéral`, `caquiste`, `solidaire`, `habituel`

#### belanger2018

- **Q56:** "En politique provinciale, vous considérez-vous habituellement comme un...?"
  - Libéral
  - Péquiste
  - Caquiste
  - Solidaire
  - Rien de cela [→ Q58]
  - Je ne sais pas [→ Q58]
  - Je préfère ne pas répondre [→ Q58]

**Force de l'identification:**
- **Q57:** "Vous sentez-vous très fortement [péquiste/libéral/etc.], assez fortement, ou pas très fortement?" [SI Q56 = un parti]
  - Très fortement
  - Assez fortement
  - Pas très fortement

#### maheo2022

- **cps_provpid:** "En politique provinciale, vous considérez-vous habituellement comme étant:"
  - libéral
  - péquiste
  - caquiste
  - solidaire
  - conservateur
  - Un autre parti
  - Aucun de ces partis [→ skip cps_provpidstr]

**Force de l'identification:**
- **cps_provpidstr:** "À quel point vous sentez-vous [péquiste/libéral/etc.]?" [SI cps_provpid ≠ Aucun]
  - Très proche (Very strongly)
  - Proche (Fairly strongly)
  - Pas très proche (Not very strongly)

---

### C. THERMOMÈTRES - PARTIS

**Mots-clés pour recherche:** `thermomètre`, `aimez`, `pensez-vous`, `0 à 10`, `0 à 100`, `parti`

#### belanger2018

**PAS de thermomètres de PARTIS dans belanger2018** (seulement leaders, voir section D)

**ALTERNATIVE - Meilleur parti pour enjeux:**
- **Q16:** "Lorsque vous pensez à chacun des enjeux suivants, à quel parti politique pensez-vous spontanément?"
  - Items: intérêts du Québec, identité/culture QC, économie, éducation, environnement, santé, pauvreté, immigration
  - Options: PLQ, PQ, CAQ, QS, Autre parti, Aucun

- **Q51a:** "Selon vous, quel parti est le meilleur pour..."
  - [Mêmes items que Q16]

#### maheo2022

**Thermomètres de partis (0-100):**
- **cps_partytherm:** "Que pensez-vous des partis politiques provinciaux énumérés ci-dessous?" [Échelle 0-100]
  - cps_partytherm_23: Parti libéral du Québec
  - cps_partytherm_25: Parti québécois
  - cps_partytherm_27: Coalition avenir Québec
  - cps_partytherm_30: Québec solidaire
  - cps_partytherm_33: Parti conservateur du Québec
  - Échelle: 0 = "Je n'aime vraiment pas du tout" → 100 = "J'aime vraiment beaucoup"
  - Option: "Je ne connais pas ce parti"

**Meilleur parti pour enjeux:**
- **cps_partybest_issues:** "Selon vous, quel parti est le meilleur pour..."
  - cps_partybest_issues_1: Les soins de santé
  - cps_partybest_issues_2: L'éducation
  - cps_partybest_issues_3: L'environnement
  - cps_partybest_issues_4: Le crime et la justice
  - cps_partybest_issues_5: L'immigration et les minorités
  - cps_partybest_issues_6: L'économie
  - cps_partybest_issues_7: Le logement abordable
  - cps_partybest_issues_8: L'intégration des immigrants au Québec
  - cps_partybest_issues_9: La défense des intérêts du Québec
  - cps_partybest_issues_10: La défense de l'identité et de la culture Québécoise

---

### D. THERMOMÈTRES - LEADERS

**Mots-clés pour recherche:** `leader`, `chef`, `Couillard`, `Lisée`, `Legault`, `Massé`, `Anglade`, `PSPP`, `St-Pierre Plamondon`, `Nadeau-Dubois`, `Duhaime`

#### belanger2018

**Thermomètres de leaders (0-10):**
- **Q33a:** "Où 0 veut dire que vous N'AIMEZ VRAIMENT PAS DU TOUT un politicien, et 10 veut dire que vous L'AIMEZ VRAIMENT BEAUCOUP, que pensez-vous de..."
  - Q33a_a: Philippe Couillard (PLQ)
  - Q33a_b: Jean-François Lisée (PQ)
  - Q33a_c: François Legault (CAQ)
  - Q33a_d: Manon Massé (QS)
  - Q33a_e: Véronique Hivon (PQ)
  - Q33a_f: Gabriel Nadeau-Dubois (QS)
  - Option: "Je ne le/la connais pas"

**Meilleur PM:**
- **Q1:** "Lequel des chefs des principaux partis provinciaux ferait le meilleur premier ministre du Québec?"
  - Philippe Couillard (PLQ)
  - Jean-François Lisée (PQ)
  - François Legault (CAQ)
  - Manon Massé (QS)
  - Aucun d'entre eux

#### maheo2022

**Thermomètres de leaders (0-100):**
- **cps_leadertherm:** "Sur la même échelle, que pensez-vous des chef(fe)s de partis politiques provinciaux énumérés ci-dessous?"
  - cps_leadertherm_1: Dominique Anglade (PLQ)
  - cps_leadertherm_2: Paul St-Pierre Plamondon (PQ)
  - cps_leadertherm_3: François Legault (CAQ)
  - cps_leadertherm_7: Gabriel Nadeau-Dubois (QS)
  - cps_leadertherm_8: Éric Duhaime (PCQ)
  - Échelle: 0 = "Je n'aime vraiment pas du tout" → 100 = "J'aime vraiment beaucoup"
  - Option: "Je ne connais pas ce chef(fe)"

**Traits de leadership:**
- **cps_intelligent:** "Il(elle) est intelligent(e)?" [Pour chaque leader]
- **cps_stronglead:** "Il(elle) fait preuve d'un leadership fort?"
- **cps_trustworthy:** "Il(elle) est digne de confiance?"
- **cps_cares:** "Il(elle) se soucie vraiment des gens comme vous?"
  - Échelle: 1-5 (Fortement en désaccord → Fortement en accord)

---

### E. AUTRES VARIABLES PERTINENTES

#### Certitude du choix

**belanger2018:**
- **Q6A (voir section A):** Timing du choix (plusieurs mois avant → jour même)

**maheo2022:**
- Pas de variable équivalente dans CPS

#### Intérêt et sophistication politique

**belanger2018:**
- **Q27:** "Quel est votre intérêt pour la politique et les enjeux publics en général?"
  - Très intéressé / Assez intéressé / Peu intéressé / Pas du tout intéressé

**maheo2022:**
- **cps_interest_1:** "Quel est votre niveau d'intérêt pour la politique en général?" (0-10)
- **cps_intelection_1:** "Quel est votre niveau d'intérêt pour cette élection au Québec?" (0-10)

---

## Catégories d'électeurs à créer

**IMPORTANT:** Les catégories doivent être créées de manière comparable entre 2018 et 2022.

### 1. BASE MILITANTE PQ

**Définition:** Péquistes convaincus, base dure du parti

**belanger2018 - Critères (AU MOINS 2 sur 3):**
1. S'identifient "très fortement péquistes" (Q56=PQ ET Q57=Très fortement)
2. OU Thermomètre Lisée (chef PQ) ≥ 8/10 (équivalent 80/100)
3. OU Vote PQ (Q6) ET était premier choix (Q7=Oui) ET choix fait plusieurs mois avant (Q6A=1)

**maheo2022 - Critères (AU MOINS 2 sur 3):**
1. S'identifient "très fortement péquistes" (cps_provpid=péquiste ET cps_provpidstr=Très proche)
2. OU Thermomètre PQ ≥ 80/100 (cps_partytherm_25)
3. OU Vote PQ ET PQ pas dans negativevote ET 2e choix absent/faible

**N.B.:** Ajuster seuils thermomètres pour comparabilité (2018: 8/10 = 80/100 en 2022)

---

### 2. ÉLECTEURS PQ (TOUS)

**Définition:** Tous ceux qui votent ou ont voté PQ, incluant vote stratégique/par défaut

**belanger2018:**
- Q6 = "Parti québécois" (vote réel 2018)

**maheo2022:**
- pes_votechoice = "Parti Québécois" (vote réel 2022)
- OU cps_votechoice1/2/3 = "Parti québécois" (intention si pes non disponible)

---

### 3. ÉLECTEURS PQ PRAGMATIQUES

**Définition:** Votent PQ mais pas fortement attachés au parti (vote stratégique, par défaut, ou récent)

**belanger2018 - Critères (TOUS):**
1. Votent PQ (Q6)
2. ET (Q56 ≠ Péquiste OU Q57 = Pas très fortement)
3. ET (Thermomètre Lisée < 8/10 OU Q7 = Non [pas premier choix])

**maheo2022 - Critères (TOUS):**
1. Votent PQ (pes_votechoice ou cps_votechoice)
2. ET (cps_provpid ≠ péquiste OU cps_provpidstr ≠ Très proche)
3. ET (Thermomètre PQ < 80/100 OU 2e choix non-vide)

---

### 4. ÉLECTORAT POTENTIEL PQ

**Définition:** Ne votent pas PQ mais restent ouverts à le faire (PQ dans zone de considération)

**belanger2018 - Critères (AU MOINS 1):**
1. Ne votent PAS PQ (Q6 ≠ PQ)
2. MAIS:
   - Q8 = PQ (était premier choix mais a voté autre chose)
   - OU Thermomètre Lisée ≥ 5/10 (équivalent 50/100 = favorable)
   - OU Q16/Q51 = PQ pour au moins 2 enjeux (PQ associé à leurs préoccupations)

**maheo2022 - Critères (AU MOINS 1):**
1. Ne votent PAS PQ (pes_votechoice ≠ PQ)
2. MAIS:
   - cps_votesecond = PQ (PQ est 2e choix)
   - OU Thermomètre PQ ≥ 50/100
   - OU PQ PAS dans cps_negativevote (ne rejette pas absolument)
   - OU cps_partybest_issues = PQ pour au moins 2 enjeux

---

### 5. REJET CATÉGORIQUE DU PQ

**Définition:** Rejettent absolument le PQ, hors de leur zone de considération

**belanger2018:**
- **Proxy (pas de variable directe):**
  - Thermomètre Lisée ≤ 2/10 (équivalent 20/100 = rejet fort)
  - OU Q16/Q51 = "Aucun de ces partis" pour majorité des enjeux + identification forte autre parti

**maheo2022:**
- **cps_negativevote_2 = Selected:** "Parti québécois" sélectionné dans vote négatif
- (Variable directe disponible!)

---

### 6. ÉLECTEURS INDÉCIS / VOLATILS

**Définition:** Pas d'ancrage partisan fort, susceptibles de changer

**belanger2018:**
- Q56 = "Rien de cela" ou "Je ne sais pas"
- OU Q7 = Non (n'était pas premier choix)
- OU Q6A = 4 (choix fait jour même)
- ET Thermomètres leaders dispersés (pas de favori clair)

**maheo2022:**
- cps_provpid = "Aucun de ces partis"
- OU cps_votechoice = "Don't know" puis cps_votelean = "Don't know"
- OU cps_votesecond présent ET thermomètres serrés (différence <20 points entre top 2)

---

## Comparabilité inter-sondages

### Harmonisation des échelles

**Thermomètres:**
- belanger2018: Échelle 0-10
- maheo2022: Échelle 0-100
- **Conversion:** Multiplier 2018 par 10 → échelle 0-100 commune

**Seuils comparables:**
| Concept | 2018 (0-10) | 2022 (0-100) |
|---------|-------------|--------------|
| Rejet fort | 0-2 | 0-20 |
| Défavorable | 3-4 | 30-40 |
| Neutre | 5 | 50 |
| Favorable | 6-7 | 60-70 |
| Très favorable | 8-10 | 80-100 |

**Force PID:**
- 2018: "Très fortement" / "Assez fortement" / "Pas très fortement"
- 2022: "Très proche" / "Proche" / "Pas très proche"
- **Équivalence directe**

### Variables manquantes

**2018 manque (mais présent en 2022):**
- Thermomètres de partis (seulement leaders)
- Vote négatif explicite (negativevote)
- Deuxième choix explicite

**2022 manque (mais présent en 2018):**
- Timing du choix (plusieurs mois avant, etc.)
- Vote passé 2014 (pour analyser stabilité)

**Solutions:**
- Utiliser thermomètres leaders 2018 comme proxy thermomètres partis
- Créer proxy vote négatif 2018 avec thermomètres très bas
- Pour 2e choix 2018: utiliser Q8 (premier choix si différent du vote)

---

## Analyses principales

### ANALYSE CENTRALE: Nativisme selon la proximité au PQ (2022)

**Question:** Le discours nativiste vise-t-il la base ou l'expansion?

**Comparer 4 groupes:**
1. **Base militante PQ** (péquistes convaincus)
2. **Électeurs PQ actuels** (tous ceux qui votent PQ)
3. **Électorat potentiel PQ** (PQ 2e choix, ou thermomètre favorable, ou pas dans rejet)
4. **Rejet catégorique PQ** (PQ dans negativevote ou thermomètre très bas)

**Variables à comparer:**
- Score nativisme ethnique (né QC, ancêtres QC, parler français)
- Score nativisme civique (vécu QC, se sentir QC, valeurs, institutions)
- Attitudes immigration: % favorable réduire (Q39 2018 / cps_immig 2022)
- Thermomètres immigrants/musulmans
- Attachement identitaire: QC vs Canada

**Interprétation:**

**→ Si Base >> Électeurs >> Électorat potentiel >> Rejet:**
- **Gradient clair:** Plus on est proche du PQ, plus on est nativiste
- **Conclusion:** Stratégie de mobilisation de base
- **Risque:** Plafond électoral - le discours ferme des portes
- **Graphique clé:** Barres dégradées montrant le gradient

**→ Si Base ≈ Électeurs ≈ Électorat potentiel > Rejet:**
- **Palier:** Tous les électeurs accessibles au PQ sont également nativistes
- **Conclusion:** Stratégie d'expansion viable
- **Opportunité:** Bassin nativiste sous-exploité à capter
- **Graphique clé:** Barres plates (similaires) puis chute pour rejet

**→ Si Base >> Électeurs ≈ Électorat potentiel > Rejet:**
- **Tension:** Base pousse le parti mais électeurs actuels/potentiels plus modérés
- **Conclusion:** Le parti est prisonnier de sa base militante
- **Risque:** Désalignement entre direction du parti et son électorat
- **Graphique clé:** Base élevée, puis plateau plus bas

---

### Analyse 2: Taille des bassins électoraux (2022)

**Question:** Combien d'électeurs le PQ peut-il espérer gagner ou perdre?

**Calculer proportions:**
- Base militante PQ: X%
- Électeurs PQ actuels: Y%
- Électorat potentiel PQ: Z%
- Rejet catégorique PQ: W%
- Reste (indifférents): (100 - X - Y - Z - W)%

**Analyser:**
- **Si électorat potentiel > rejet:** Place pour croissance
- **Si rejet > électorat potentiel:** Plafond atteint
- **Profil de l'électorat potentiel vs rejet:** Qui sont-ils? D'où viennent-ils? (CAQ, QS, PLQ?)

**Graphique:** Diagramme empilé ou "funnel" montrant tailles relatives

---

### Analyse 3: Évolution 2018 → 2022 (secondaire)

**Question:** Le PQ a-t-il changé de segment démographique/attitudinal?

**Comparer électeurs PQ 2018 vs 2022:**
- Score nativisme ethnique/civique
- Thermomètres immigrants/musulmans
- Démographie (âge, éducation, région, langue)

**Si changement significatif:**
- Le PQ a capté un nouveau segment en 2022
- Analyser: Qui a quitté? Qui est arrivé?

**Si stable:**
- L'électorat PQ est resté constant malgré changement de chef (Lisée → PSPP)
- Le discours nativiste reflète les préférences existantes

**Graphique:** Comparaison 2018 vs 2022 (barres ou profils radar)

---

## Graphiques prévus (LinkedIn-friendly)

### GRAPHIQUE PRINCIPAL: "Stratégie de base ou d'expansion?"

**Type:** Barres groupées avec ligne de tendance

**Axe X:** 4 groupes ordonnés de gauche à droite
1. Rejettent PQ catégoriquement
2. Électorat potentiel PQ (2e choix)
3. Électeurs PQ actuels
4. Base militante PQ

**Axe Y:** % favorable à réduire immigration (ou score nativisme)

**Couleurs:**
- Rouge/orange: Rejet PQ
- Jaune: Potentiel
- Bleu clair: Électeurs PQ
- Bleu foncé: Base militante

**Ligne de tendance pointillée:** Montre le gradient (ou palier)

**Titre accrocheur (selon résultat):**
- Si gradient: *"Le PQ mobilise sa base au risque d'un plafond électoral"*
- Si palier: *"Un bassin nativiste sous-exploité: la stratégie d'expansion du PQ"*
- Si tension: *"Le PQ prisonnier de sa base militante"*

**Annotation clé:** Flèche ou encadré soulignant l'écart (ou absence d'écart) entre électorat potentiel et base

**Pourquoi LinkedIn-friendly:**
- Message visuel immédiat
- Titre qui pose le débat stratégique
- Couleurs distinctes
- 1 insight clair par graphique

---

### GRAPHIQUE 2 (optionnel): "Le plafond électoral du PQ"

**Type:** Diagramme en entonnoir (funnel) ou barres empilées

**Segments:**
- Base militante: X%
- Électeurs actuels: Y%
- Électorat potentiel: Z%
- Indifférents: ?%
- Rejet catégorique: W%

**Couleurs dégradées:** Du bleu foncé (base) au rouge (rejet)

**Annotation:** Ratio "Potentiel vs Rejet" avec interprétation
- Ex: "1.5 : 1 - Pour chaque électeur que le PQ peut gagner, 1 le rejette catégoriquement"

**Titre:** *"Combien d'électeurs le PQ peut-il gagner?"*

---

### GRAPHIQUE 3 (optionnel): "Évolution 2018-2022"

**Type:** Barres ou profils radar comparatifs

**Si changement significatif:**
- Titre: *"Le PQ a capté un nouvel électorat plus nativiste"*
- Comparaison électeurs PQ 2018 vs 2022

**Si stable:**
- Titre: *"L'électorat PQ: remarquablement stable malgré le changement de chef"*
- Montrer similarité 2018/2022

---

## Variables démographiques (contrôles)

- Âge: age (2018), cps_age_in_years (2022)
- Éducation: d3 (2018), cps_edu (2022)
- Langue: s1 (2018), langue maternelle
- Région: fsa_tabl/region (2018), région (2022)
- Sexe: sexfix (2018), cps_genderid (2022)
- Revenu: d5 (2018)

---

## Notes méthodologiques

**Pondération:**
- belanger2018: pas de poids mentionné dans codebook (à vérifier)
- maheo2022: cps_weight_general ou cps_weight_general_trimmed
- durand2018: weight

**Tailles d'échantillon:**
- belanger2018: ~1250 répondants
- maheo2022: CPS=1521, PES=1220 (panel)
- durand2018: ~1250 répondants

**Années électorales:**
- 2018: Élection 1er octobre (CAQ majoritaire, PQ 17%, 3e position)
- 2022: Élection 3 octobre (CAQ majoritaire réélu, PQ 14.6%, 2e position)

# Variables de maheo2022 à ajouter

- cps_impissue_matrix
- cps_partybest_issues
- pes_immfitin
- pes_immjobs
- pes_groups
- pes_immecon
- pes_cultureharm
- pes_immigrantcrime
- pes_dominorities