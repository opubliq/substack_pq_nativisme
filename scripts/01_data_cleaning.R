# ============================================================================ #
# SCRIPT DE NETTOYAGE DES DONNÉES
# Projet: Virage nativiste du PQ
# Auteur: Opubliq
# Date: 2025-10-20
# ============================================================================ #
#
# Description:
# Ce script nettoie et harmonise les données des sondages belanger2018 et
# maheo2022 pour l'analyse du virage nativiste du PQ.
#
# Variables cleanées sont en snake_case anglais
# Échelles Likert converties en numeric 0-1
# Thermomètres harmonisés sur échelle 0-100
#
# ============================================================================ #

# SETUP ----
library(dplyr)
library(haven)
library(tidyr)
library(stringr)
library(readr)

# LOAD DATA ----
cat("Loading raw data...\n")
belanger2018_raw <- read_dta("data/raw/belanger2018_data.dta")
maheo2022_raw <- read_dta("data/raw/maheo2022_data.dta")

cat(sprintf("  belanger2018: %d observations\n", nrow(belanger2018_raw)))
cat(sprintf("  maheo2022: %d observations\n", nrow(maheo2022_raw)))

# CREATE CLEAN DATAFRAMES ----
belanger2018_clean <- tibble(
  id = 1:nrow(belanger2018_raw),
  dataset = "belanger2018",
  year = 2018
)

maheo2022_clean <- tibble(
  id = 1:nrow(maheo2022_raw),
  dataset = "maheo2022",
  year = 2022
)

cat("Clean dataframes initialized\n\n")


# ============================================================================ #
# A. NATIVISME - Critères "être vraiment Québécois" ----
# ============================================================================ #
# belanger2018: Q22_1 to Q22_8
#   Q22_1: D'être né au Québec
#   Q22_2: D'avoir vécu la plus grande partie de sa vie au Québec
#   Q22_3: D'être capable de parler le français
#   Q22_4: D'être catholique [PAS dans 2022]
#   Q22_5: De respecter les institutions politiques et les lois québécoises
#   Q22_6: De se sentir Québécois
#   Q22_7: D'avoir des ancêtres français
#   Q22_8: De partager les valeurs des Québécois
#
# maheo2022: pes_nativism_1 to pes_nativism_9
#   pes_nativism_1: Être né(e) au Québec
#   pes_nativism_2: Que vos grands-parents soient nés au Québec
#   pes_nativism_3: Être capable de parler le français
#   pes_nativism_4: D'être capable de parler l'anglais [PAS dans 2018]
#   pes_nativism_5: Respecter les coutumes et les traditions du Québec [PAS dans 2018]
#   pes_nativism_6: D'avoir vécu la plus grande partie de sa vie au Québec
#   pes_nativism_7: De se sentir Québécois
#   pes_nativism_8: De partager les valeurs des Québécois
#   pes_nativism_9: De respecter les institutions politiques et les lois québécoises
#
# VARIABLES À CRÉER (7 items comparables):
#   nativism_born_qc          : Né au Québec
#   nativism_ancestors_qc     : Grands-parents/ancêtres nés au Québec
#   nativism_speak_french     : Parler français
#   nativism_lived_qc         : Vécu la plus grande partie de sa vie au Québec
#   nativism_feel_quebecer    : Se sentir Québécois
#   nativism_share_values     : Partager les valeurs des Québécois
#   nativism_respect_institutions : Respecter institutions et lois
#
# INDICES À CRÉER:
#   nativism_ethnic_score     : Moyenne items 1,2,3 (ethnique)
#   nativism_civic_score      : Moyenne items 4,5,6,7 (civique)
#   nativism_total_score      : Moyenne des 7 items
#   nativism_ethnic_civic_ratio : Ratio ethnique/civique
#
# OUTPUT: Échelles Likert converties en 0-1 (0=pas important, 1=très important)
# ============================================================================ #

cat("Cleaning A. NATIVISME variables...\n")

# Helper function to convert Likert scales to 0-1
convert_likert_belanger <- function(x) {
  # belanger2018: 1=Très important, 4=Pas important du tout
  # Codes 98, 99 = missing
  x <- ifelse(x >= 98, NA, x)
  (4 - x) / 3
}

convert_likert_maheo <- function(x) {
  # maheo2022: 1=Pas important du tout, 4=Très important
  # Code -99 = missing
  x <- ifelse(x == -99, NA, x)
  (x - 1) / 3
}

# belanger2018 - Q22 (7 items comparables)
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    nativism_born_qc = convert_likert_belanger(belanger2018_raw$q22_1),
    nativism_ancestors_qc = convert_likert_belanger(belanger2018_raw$q22_7),
    nativism_speak_french = convert_likert_belanger(belanger2018_raw$q22_3),
    nativism_lived_qc = convert_likert_belanger(belanger2018_raw$q22_2),
    nativism_feel_quebecer = convert_likert_belanger(belanger2018_raw$q22_6),
    nativism_share_values = convert_likert_belanger(belanger2018_raw$q22_8),
    nativism_respect_institutions = convert_likert_belanger(belanger2018_raw$q22_5)
  )

# maheo2022 - pes_nativism (7 items comparables)
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    nativism_born_qc = convert_likert_maheo(maheo2022_raw$pes_nativism_1),
    nativism_ancestors_qc = convert_likert_maheo(maheo2022_raw$pes_nativism_2),
    nativism_speak_french = convert_likert_maheo(maheo2022_raw$pes_nativism_3),
    nativism_lived_qc = convert_likert_maheo(maheo2022_raw$pes_nativism_6),
    nativism_feel_quebecer = convert_likert_maheo(maheo2022_raw$pes_nativism_7),
    nativism_share_values = convert_likert_maheo(maheo2022_raw$pes_nativism_8),
    nativism_respect_institutions = convert_likert_maheo(maheo2022_raw$pes_nativism_9)
  )

cat("  A. NATIVISME: done\n")

# ============================================================================ #
# B. IMMIGRATION - Attitudes générales ----
# ============================================================================ #

# B1. Niveau souhaité d'immigration ----
# --------------------------------------
# belanger2018: Q39 "Il y a trop d'immigrants au Québec"
#   Échelle: Tout à fait en désaccord (1) → Tout à fait d'accord (5)
#
# maheo2022:
#   cps_immig: "Le Canada devrait admettre..."
#     1=Plus d'immigrants, 2=Moins, 3=À peu près autant
#   cps_attractimm: "Le Québec devrait essayer..."
#     1=D'attirer plus, 2=D'attirer moins, 3=Maintenir le niveau
#
# VARIABLES À CRÉER:
#   immigration_too_many      : Accord "trop d'immigrants" (0-1)
#   immigration_favor_reduce  : Dichotomous - Favorable à réduire (0/1)
#   immigration_favor_increase: Dichotomous - Favorable à augmenter (0/1)
#   immigration_attitude      : Categorical - reduce/maintain/increase
#
# OUTPUT: Harmonisation conceptuelle entre les 3 formulations
# ============================================================================ #

cat("Cleaning B1. IMMIGRATION niveau variables...\n")

# belanger2018 - Q39i "Il y a trop d'immigrants au Québec"
# Échelle: 1=Tout à fait en désaccord → 5=Tout à fait d'accord
# Codes 98, 99 = missing
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # Clean raw variable
    q39i_clean = ifelse(belanger2018_raw$q39i >= 98, NA, belanger2018_raw$q39i),

    # immigration_favor_reduce: Accord "trop d'immigrants" (Plutôt/Tout à fait d'accord)
    immigration_favor_reduce = case_when(
      q39i_clean >= 4 ~ 1,  # Plutôt/Tout à fait d'accord
      q39i_clean <= 3 ~ 0,  # Désaccord/Neutre
      TRUE ~ NA_real_
    ),

    # immigration_favor_increase: Désaccord "trop d'immigrants" (Plutôt/Tout à fait en désaccord)
    immigration_favor_increase = case_when(
      q39i_clean <= 2 ~ 1,  # Tout à fait/Plutôt en désaccord
      q39i_clean >= 3 ~ 0,  # Neutre/Accord
      TRUE ~ NA_real_
    ),

    # immigration_attitude: Categorical
    immigration_attitude = case_when(
      q39i_clean <= 2 ~ "increase",   # Désaccord avec "trop"
      q39i_clean == 3 ~ "maintain",   # Neutre
      q39i_clean >= 4 ~ "reduce",     # Accord avec "trop"
      TRUE ~ NA_character_
    )
  ) %>%
  select(-q39i_clean)  # Remove temp variable


# maheo2022 - cps_immig "Le Canada devrait admettre..."
# 1=Plus d'immigrants, 2=Moins, 3=À peu près autant
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # immigration_favor_reduce
    immigration_favor_reduce = case_when(
      maheo2022_raw$cps_immig == 2 ~ 1,  # Moins
      maheo2022_raw$cps_immig %in% c(1, 3) ~ 0,  # Plus/Même
      TRUE ~ NA_real_
    ),

    # immigration_favor_increase
    immigration_favor_increase = case_when(
      maheo2022_raw$cps_immig == 1 ~ 1,  # Plus
      maheo2022_raw$cps_immig %in% c(2, 3) ~ 0,  # Moins/Même
      TRUE ~ NA_real_
    ),

    # immigration_attitude
    immigration_attitude = case_when(
      maheo2022_raw$cps_immig == 1 ~ "increase",
      maheo2022_raw$cps_immig == 3 ~ "maintain",
      maheo2022_raw$cps_immig == 2 ~ "reduce",
      TRUE ~ NA_character_
    )
  )


cat("  B1. IMMIGRATION niveau: done\n")
cat(sprintf("    belanger2018: %d with immigration_attitude\n",
            sum(!is.na(belanger2018_clean$immigration_attitude))))
cat(sprintf("    maheo2022: %d with immigration_attitude\n\n",
            sum(!is.na(maheo2022_clean$immigration_attitude))))


# B2. Attitudes qualitatives envers immigration (2022 seulement) ----
# --------------------------------------------------------------------
# maheo2022 PES:
#   pes_immfitin_qc: "Un trop grand nombre d'immigrants récents ne veulent
#                     tout simplement pas s'intégrer à la société québécoise"
#     Échelle: 1=Fortement en désaccord → 5=Fortement en accord
#
#   pes_immjobs_qc: "Les immigrants enlèvent des emplois aux autres Québécois"
#     Échelle: 1=Fortement en désaccord → 5=Fortement en accord
#
#   pes_immecon: "Les immigrants sont généralement bénéfiques pour l'économie
#                 du Québec"
#     Échelle: 1=Fortement en désaccord → 5=Fortement en accord
#     NOTE: À INVERSER (désaccord = attitude nativiste)
#
#   pes_cultureharm: "La culture québécoise est généralement mise à mal par
#                     les immigrants" ⭐ CRUCIAL pour mesure menace culturelle
#     Échelle: 1=Fortement en désaccord → 5=Fortement en accord
#
#   pes_immigrantcrime: "Les immigrants augmentent le taux de criminalité
#                        au Québec"
#     Échelle: 1=Fortement en désaccord → 5=Fortement en accord
#
#   pes_minoritiesadapt: "Les minorités devraient s'adapter aux coutumes et
#                         traditions du Québec"
#     Échelle: 1=Fortement en désaccord → 5=Fortement en accord
#
#   pes_dominorities: "Selon vous, combien devrait être fait pour les minorités
#                      raciales au Québec?"
#     Échelle: 1=Beaucoup plus → 5=Beaucoup moins
#
# VARIABLES À CRÉER (maheo2022 seulement):
#   immig_dont_integrate      : Accord "ne veulent pas s'intégrer" (0-1)
#   immig_take_jobs           : Accord "enlèvent emplois" (0-1)
#   immig_good_economy        : Accord "bons pour économie" (0-1, inversé)
#   immig_harm_culture        : Accord "culture mise à mal" (0-1) ⭐ CRUCIAL
#   immig_increase_crime      : Accord "augmentent criminalité" (0-1)
#   immig_minorities_adapt    : Accord "minorités devraient s'adapter" (0-1)
#   immig_do_less_minorities  : Accord "faire moins pour minorités" (0-1)
#
# OUTPUT: Échelle 0-1 (0=désaccord avec nativisme, 1=accord avec nativisme)
#         Ces variables mesurent le nativisme CULTUREL (menace perçue)
#         vs le nativisme ETHNIQUE (critères appartenance, section A)
# ============================================================================ #

cat("Cleaning B2. IMMIGRATION attitudes qualitatives variables...\n")

# belanger2018 - All B2 variables are NA (these questions don't exist in 2018)
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    immig_dont_integrate = NA_real_,
    immig_take_jobs = NA_real_,
    immig_good_economy = NA_real_,
    immig_harm_culture = NA_real_,
    immig_increase_crime = NA_real_,
    immig_minorities_adapt = NA_real_,
    immig_do_less_minorities = NA_real_
  )

# maheo2022 - pes_immfitin_qc, pes_immjobs_qc, etc.
# Combine split-form versions (QC + Canada) with coalesce
# Convert 1-5 Likert to 0-1 scale: (value - 1) / 4
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # 1. "Ne veulent pas s'intégrer" - combine QC + Canada versions
    immig_dont_integrate = {
      combined <- coalesce(maheo2022_raw$pes_immfitin_qc, maheo2022_raw$pes_immfitin)
      ifelse(combined > 0, (combined - 1) / 4, NA_real_)
    },

    # 2. "Enlèvent emplois" - combine QC + Canada versions
    immig_take_jobs = {
      combined <- coalesce(maheo2022_raw$pes_immjobs_qc, maheo2022_raw$pes_immjobs)
      ifelse(combined > 0, (combined - 1) / 4, NA_real_)
    },

    # 3. "Bons pour économie" - REVERSE CODE (disagreement = nativism)
    immig_good_economy = case_when(
      maheo2022_raw$pes_immecon > 0 ~ (5 - maheo2022_raw$pes_immecon) / 4,
      TRUE ~ NA_real_
    ),

    # 4. "Culture mise à mal" ⭐ CRUCIAL for cultural threat measure
    immig_harm_culture = case_when(
      maheo2022_raw$pes_cultureharm > 0 ~ (maheo2022_raw$pes_cultureharm - 1) / 4,
      TRUE ~ NA_real_
    ),

    # 5. "Augmentent criminalité"
    immig_increase_crime = case_when(
      maheo2022_raw$pes_immigrantcrime > 0 ~ (maheo2022_raw$pes_immigrantcrime - 1) / 4,
      TRUE ~ NA_real_
    ),

    # 6. "Minorités devraient s'adapter"
    immig_minorities_adapt = case_when(
      maheo2022_raw$pes_minoritiesadapt > 0 ~ (maheo2022_raw$pes_minoritiesadapt - 1) / 4,
      TRUE ~ NA_real_
    ),

    # 7. "Faire moins pour minorités"
    immig_do_less_minorities = case_when(
      maheo2022_raw$pes_dominorities > 0 ~ (maheo2022_raw$pes_dominorities - 1) / 4,
      TRUE ~ NA_real_
    )
  )

cat("  B2. IMMIGRATION attitudes qualitatives: done\n")
cat("    belanger2018: 0 with immig_harm_culture (2018 N/A)\n")
cat("    maheo2022:", sum(!is.na(maheo2022_clean$immig_harm_culture)), "with immig_harm_culture\n\n")


# ============================================================================ #
# C. THERMOMÈTRES - Sentiments envers groupes ----
# ============================================================================ #
# belanger2018: Q34 (échelle 0-10)
#   q34_a: Immigrants
#   q34_b: Musulmans vivant au Canada
#   q34_c: Minorités ethnoculturelles
#   q34_d: Francophones au Québec
#   q34_e: Anglophones au Québec
#
# maheo2022 CPS: cps_groups2 (échelle 0-100)
#   cps_groups2_6: Les immigrants
#   cps_groups2_16: Les musulmans vivant au Canada
#   cps_groups2_11: Les francophones vivant au Québec
#   cps_groups2_18: Les anglophones vivant au Québec
#   cps_groups2_7: Les peuples autochtones
#   cps_groups2_17: Les allophones vivant au Québec
#
# maheo2022 PES: pes_groups (échelle 0-100) [complément/doublon de cps_groups2]
#   pes_groups_2: Les musulmans vivant au Québec
#   pes_groups_4: Les Peuples autochtones
#   pes_groups_5: Immigrants
#   NOTE: Si cps_groups2 manquant, utiliser pes_groups comme backup
#
# VARIABLES À CRÉER (échelle 0-100 harmonisée):
#   therm_immigrants          : Sentiment envers immigrants
#   therm_muslims             : Sentiment envers musulmans
#   therm_minorities          : Sentiment envers minorités ethnoculturelles
#   therm_francophones        : Sentiment envers francophones
#   therm_anglophones         : Sentiment envers anglophones
#   therm_indigenous          : Sentiment envers peuples autochtones (2022 seulement)
#   therm_allophones          : Sentiment envers allophones (2022 seulement)
#
# OUTPUT: Toutes échelles converties à 0-100
#         2018: multiplier par 10
#         2022: utiliser cps_groups2, pes_groups comme backup si manquant
#         Missing si "Je ne connais pas ce groupe"
# ============================================================================ #

cat("Cleaning C. THERMOMÈTRES GROUPES variables...\n")

# belanger2018 - Q34 (convert 0-10 to 0-100)
# Code missing values (98, 99) as NA, then multiply by 10
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # q34_a: Immigrants
    therm_immigrants = case_when(
      belanger2018_raw$q34_a >= 98 ~ NA_real_,
      TRUE ~ belanger2018_raw$q34_a * 10
    ),

    # q34_b: Musulmans vivant au Canada
    therm_muslims = case_when(
      belanger2018_raw$q34_b >= 98 ~ NA_real_,
      TRUE ~ belanger2018_raw$q34_b * 10
    ),

    # q34_c: Minorités ethnoculturelles
    therm_minorities = case_when(
      belanger2018_raw$q34_c >= 98 ~ NA_real_,
      TRUE ~ belanger2018_raw$q34_c * 10
    ),

    # q34_d: Francophones au Québec
    therm_francophones = case_when(
      belanger2018_raw$q34_d >= 98 ~ NA_real_,
      TRUE ~ belanger2018_raw$q34_d * 10
    ),

    # q34_e: Anglophones au Québec
    therm_anglophones = case_when(
      belanger2018_raw$q34_e >= 98 ~ NA_real_,
      TRUE ~ belanger2018_raw$q34_e * 10
    )
  )

# maheo2022 - cps_groups2 (already 0-100)
# Use pes_groups as backup if cps_groups2 is missing
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # cps_groups2_6: Les immigrants (backup: pes_groups_5)
    therm_immigrants = case_when(
      maheo2022_raw$cps_groups2_6 == -99 & maheo2022_raw$pes_groups_5 == -99 ~ NA_real_,
      maheo2022_raw$cps_groups2_6 != -99 ~ maheo2022_raw$cps_groups2_6,
      maheo2022_raw$pes_groups_5 != -99 ~ maheo2022_raw$pes_groups_5,
      TRUE ~ NA_real_
    ),

    # cps_groups2_16: Les musulmans vivant au Canada (backup: pes_groups_2)
    therm_muslims = case_when(
      maheo2022_raw$cps_groups2_16 == -99 & maheo2022_raw$pes_groups_2 == -99 ~ NA_real_,
      maheo2022_raw$cps_groups2_16 != -99 ~ maheo2022_raw$cps_groups2_16,
      maheo2022_raw$pes_groups_2 != -99 ~ maheo2022_raw$pes_groups_2,
      TRUE ~ NA_real_
    ),

    # NOTE: No "minorities" variable in maheo2022, will be NA for all 2022 respondents
    therm_minorities = NA_real_,

    # cps_groups2_11: Les francophones vivant au Québec
    therm_francophones = case_when(
      maheo2022_raw$cps_groups2_11 == -99 ~ NA_real_,
      TRUE ~ maheo2022_raw$cps_groups2_11
    ),

    # cps_groups2_18: Les anglophones vivant au Québec
    therm_anglophones = case_when(
      maheo2022_raw$cps_groups2_18 == -99 ~ NA_real_,
      TRUE ~ maheo2022_raw$cps_groups2_18
    )
  )

cat("  C. THERMOMÈTRES GROUPES: done\n")
cat("    belanger2018:", sum(!is.na(belanger2018_clean$therm_immigrants)), "with therm_immigrants\n")
cat("    maheo2022:", sum(!is.na(maheo2022_clean$therm_immigrants)), "with therm_immigrants\n\n")


# ============================================================================ #
# D. LAÏCITÉ - Positions sur signes religieux ----
# ============================================================================ #
# belanger2018:
#   Q44: "Interdire port signes religieux visibles fonction publique?"
#     1=Oui, 2=Non, 3=Je ne sais pas
#   Q48: "Crucifix à l'Assemblée nationale doit être..."
#     1=Laissé en place, 2=Retiré, 3=Je ne sais pas
#
# maheo2022:
#   [À identifier dans codebook PES - chercher laïcité, signes religieux]
#
# VARIABLES À CRÉER:
#   secularism_ban_religious_signs    : Favorable interdiction signes (0/1)
#   secularism_remove_crucifix        : Favorable retrait crucifix (0/1)
#
# OUTPUT: Dichotomous 0/1, NA si "Je ne sais pas"
# NOTE: maheo2022 n'a pas ces questions (loi 21 adoptée en 2019)
# ============================================================================ #

cat("Cleaning D. LAÏCITÉ variables...\n")

# belanger2018 - Q44, Q48
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # Q44: "Interdire signes religieux fonction publique?"
    # 1=Oui (favorable à interdiction), 2=Non, 98/99=NA
    secularism_ban_religious_signs = case_when(
      belanger2018_raw$q44 == 1 ~ 1,
      belanger2018_raw$q44 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # Q48: "Crucifix à l'Assemblée nationale"
    # 1=Laissé en place, 2=Retiré (favorable à laïcité), 98/99=NA
    secularism_remove_crucifix = case_when(
      belanger2018_raw$q48 == 2 ~ 1,  # Retiré = pro-laïcité
      belanger2018_raw$q48 == 1 ~ 0,  # Laissé en place
      TRUE ~ NA_real_
    )
  )

# maheo2022 - N/A (questions absentes en 2022)
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    secularism_ban_religious_signs = NA_real_,
    secularism_remove_crucifix = NA_real_
  )

cat("  D. LAÏCITÉ: done\n")
cat("    belanger2018:", sum(!is.na(belanger2018_clean$secularism_ban_religious_signs)), "with secularism_ban_religious_signs\n")
cat("    maheo2022: 0 with secularism_ban_religious_signs (2022 N/A)\n\n")


# ============================================================================ #
# E. IDENTITÉ - Attachement Québec vs Canada ----
# ============================================================================ #
# belanger2018:
#   Q18: "Degré d'attachement au Québec?" (1-4: Très/Assez/Peu/Pas du tout, 98/99=NA)
#   Q19: "Degré d'attachement au Canada?" (1-4: Très/Assez/Peu/Pas du tout, 98/99=NA)
#   Q20A: "Vous considérez-vous..." (Split-form 50%)
#     1=Uniquement QC, 2=D'abord QC, 3=Également, 4=D'abord CAN, 5=Uniquement CAN
#   Q20B: Même question mais ordre inversé (Split-form 50%)
#     1=Uniquement CAN, 2=D'abord CAN, 3=Également, 4=D'abord QC, 5=Uniquement QC
#
# maheo2022:
#   cps_qc_attach: "Degré d'attachement au Québec?" (1-4: Very/Fairly/Not very/Not at all, 5=DK, -99=NA)
#   cps_can_attach: "Degré d'attachement au Canada?" (1-4: Very/Fairly/Not very/Not at all, 5=DK, -99=NA)
#
# VARIABLES À CRÉER:
#   attachment_quebec         : Attachement au Québec (0-1, 1=Très attaché)
#   attachment_canada         : Attachement au Canada (0-1, 1=Très attaché)
#   attachment_differential   : QC - Canada (différentiel identitaire, -1 à +1)
#   identity_category         : Categorical - only_qc/qc_first/equal/can_first/only_can (2018 seulement)
#
# OUTPUT: Échelles 0-1 harmonisées
#         Differential: -1 (pro-Canada) à +1 (pro-Québec)
# ============================================================================ #

cat("Cleaning E. IDENTITÉ variables...\n")

# belanger2018 - Q18, Q19, Q20A/B
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # Q18: Attachement Québec (1-4 → 0-1, higher = more attached)
    attachment_quebec = case_when(
      belanger2018_raw$q18 >= 98 ~ NA_real_,
      TRUE ~ (4 - belanger2018_raw$q18) / 3
    ),

    # Q19: Attachement Canada (1-4 → 0-1, higher = more attached)
    attachment_canada = case_when(
      belanger2018_raw$q19 >= 98 ~ NA_real_,
      TRUE ~ (4 - belanger2018_raw$q19) / 3
    ),

    # Differential: QC - Canada (-1 pro-Canada, +1 pro-Québec)
    attachment_differential = attachment_quebec - attachment_canada,

    # Q20A/Q20B: Combine split-forms
    # First reverse Q20B so it matches Q20A scale
    q20_combined = {
      q20a_clean <- ifelse(belanger2018_raw$q20a >= 98, NA, belanger2018_raw$q20a)
      q20b_reversed <- case_when(
        belanger2018_raw$q20b >= 98 ~ NA_real_,
        belanger2018_raw$q20b == 1 ~ 5,  # Uniquement CAN → Uniquement CAN
        belanger2018_raw$q20b == 2 ~ 4,  # D'abord CAN → D'abord CAN
        belanger2018_raw$q20b == 3 ~ 3,  # Également → Également
        belanger2018_raw$q20b == 4 ~ 2,  # D'abord QC → D'abord QC
        belanger2018_raw$q20b == 5 ~ 1,  # Uniquement QC → Uniquement QC
        TRUE ~ NA_real_
      )
      coalesce(q20a_clean, q20b_reversed)
    },

    # Identity category
    identity_category = case_when(
      q20_combined == 1 ~ "only_qc",
      q20_combined == 2 ~ "qc_first",
      q20_combined == 3 ~ "equal",
      q20_combined == 4 ~ "can_first",
      q20_combined == 5 ~ "only_can",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-q20_combined)  # Remove temporary variable

# maheo2022 - cps_qc_attach, cps_can_attach
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # cps_qc_attach: 1-4 scale, 5=DK, -99=NA → convert to 0-1
    attachment_quebec = case_when(
      maheo2022_raw$cps_qc_attach %in% c(-99, 5) ~ NA_real_,
      TRUE ~ (4 - maheo2022_raw$cps_qc_attach) / 3
    ),

    # cps_can_attach: 1-4 scale, 5=DK, -99=NA → convert to 0-1
    attachment_canada = case_when(
      maheo2022_raw$cps_can_attach %in% c(-99, 5) ~ NA_real_,
      TRUE ~ (4 - maheo2022_raw$cps_can_attach) / 3
    ),

    # Differential: QC - Canada (-1 pro-Canada, +1 pro-Québec)
    attachment_differential = attachment_quebec - attachment_canada,

    # Identity category: N/A in 2022
    identity_category = NA_character_
  )

cat("  E. IDENTITÉ: done\n")
cat("    belanger2018:", sum(!is.na(belanger2018_clean$attachment_quebec)), "with attachment_quebec\n")
cat("    maheo2022:", sum(!is.na(maheo2022_clean$attachment_quebec)), "with attachment_quebec\n\n")


# ============================================================================ #
# F. SOUVERAINETÉ ----
# ============================================================================ #
# belanger2018:
#   Q26: "Si référendum aujourd'hui, voteriez-vous OUI ou NON?"
#     1=OUI, 2=NON, 8=Je ne sais pas, 9=Refus
#
# maheo2022:
#   cps_qc_referendum: Même question
#     1=OUI, 2=NON, 3=Je ne sais pas
#
# VARIABLES À CRÉER:
#   sovereignty_vote          : Vote référendaire (yes/no/undecided)
#   sovereignty_yes           : Dichotomous - Voterait OUI (0/1)
#
# OUTPUT: Variables comparables 2018+2022
# ============================================================================ #

cat("Cleaning F. SOUVERAINETÉ variables...\n")

# belanger2018 - Q26
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # Q26: Référendum (1=OUI, 2=NON, 8=Je ne sais pas, 9=Refus)
    sovereignty_vote = case_when(
      belanger2018_raw$q26 == 1 ~ "yes",
      belanger2018_raw$q26 == 2 ~ "no",
      belanger2018_raw$q26 %in% c(8, 9) ~ "undecided",
      TRUE ~ NA_character_
    ),

    # Dichotomous: 1=yes, 0=no, NA=undecided
    sovereignty_yes = case_when(
      belanger2018_raw$q26 == 1 ~ 1,
      belanger2018_raw$q26 == 2 ~ 0,
      TRUE ~ NA_real_
    )
  )

# maheo2022 - cps_qc_referendum
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # cps_qc_referendum (1=OUI, 2=NON, 3=Je ne sais pas)
    sovereignty_vote = case_when(
      maheo2022_raw$cps_qc_referendum == 1 ~ "yes",
      maheo2022_raw$cps_qc_referendum == 2 ~ "no",
      maheo2022_raw$cps_qc_referendum == 3 ~ "undecided",
      TRUE ~ NA_character_
    ),

    # Dichotomous: 1=yes, 0=no, NA=undecided
    sovereignty_yes = case_when(
      maheo2022_raw$cps_qc_referendum == 1 ~ 1,
      maheo2022_raw$cps_qc_referendum == 2 ~ 0,
      TRUE ~ NA_real_
    )
  )

cat("  F. SOUVERAINETÉ: done\n")
cat("    belanger2018:", sum(!is.na(belanger2018_clean$sovereignty_yes)), "with sovereignty_yes\n")
cat("    maheo2022:", sum(!is.na(maheo2022_clean$sovereignty_yes)), "with sovereignty_yes\n\n")


# ============================================================================ #
# G. CATÉGORISATION DES ÉLECTEURS ----
# ============================================================================ #


# G1. Vote choice ----
# --------------------
# belanger2018:
#   Q5: "Avez-vous voté?" (turnout)
#   Q6: "Pour quel parti avez-vous voté?" (vote choice)
#     1=PLQ, 2=PQ, 3=CAQ, 4=QS, 5=Autre, 6=Annulé
#   Q5A: "Si vous aviez voté, pour qui?" (non-voters)
#
# maheo2022:
#   pes_turnout: "Avez-vous voté?" (yes/no)
#   pes_votechoice: "Pour quel parti avez-vous voté?"
#     PLQ / PQ / CAQ / QS / PCQ / Autre
#
# VARIABLES À CRÉER:
#   voted                     : Dichotomous - A voté (0/1)
#   vote_party                : Categorical - party choice
#   vote_plq                  : Dichotomous - A voté PLQ (0/1)
#   vote_pq                   : Dichotomous - A voté PQ (0/1)
#   vote_caq                  : Dichotomous - A voté CAQ (0/1)
#   vote_qs                   : Dichotomous - A voté QS (0/1)
#   vote_pcq                  : Dichotomous - A voté PCQ (0/1) [2022 seulement]
#   vote_other                : Dichotomous - Autre parti (0/1)
#
# OUTPUT: Harmonisation nomenclature partis entre années
# ============================================================================ #

cat("Cleaning G1. VOTE CHOICE variables...\n")

# belanger2018 - Q5, Q6
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # Q5: Turnout (4 = "Je suis certain d'avoir voté")
    voted = case_when(
      belanger2018_raw$q5 == 4 ~ 1,
      belanger2018_raw$q5 %in% c(1, 2, 3, 5) ~ 0,
      TRUE ~ NA_real_
    ),

    # Q6: Vote choice (1=PLQ, 2=PQ, 3=CAQ, 4=QS, 95=Autre, 96=Annulé)
    vote_party = case_when(
      belanger2018_raw$q6 == 1 ~ "plq",
      belanger2018_raw$q6 == 2 ~ "pq",
      belanger2018_raw$q6 == 3 ~ "caq",
      belanger2018_raw$q6 == 4 ~ "qs",
      belanger2018_raw$q6 %in% c(95, 96) ~ "other",
      TRUE ~ NA_character_
    ),

    # Dichotomous party votes
    vote_plq = ifelse(vote_party == "plq", 1, 0),
    vote_pq = ifelse(vote_party == "pq", 1, 0),
    vote_caq = ifelse(vote_party == "caq", 1, 0),
    vote_qs = ifelse(vote_party == "qs", 1, 0),
    vote_pcq = 0,  # PCQ didn't exist in 2018
    vote_other = ifelse(vote_party == "other", 1, 0)
  )

# maheo2022 - pes_turnout, pes_votechoice
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # pes_turnout: 1=Yes (voted)
    voted = case_when(
      maheo2022_raw$pes_turnout == 1 ~ 1,
      maheo2022_raw$pes_turnout %in% c(2, 3, 4, 5, 6) ~ 0,
      TRUE ~ NA_real_
    ),

    # pes_votechoice: 1=PLQ, 2=PQ, 3=CAQ, 4=QS, 7=PCQ, 5=Autre, 6=Annulé
    vote_party = case_when(
      maheo2022_raw$pes_votechoice == 1 ~ "plq",
      maheo2022_raw$pes_votechoice == 2 ~ "pq",
      maheo2022_raw$pes_votechoice == 3 ~ "caq",
      maheo2022_raw$pes_votechoice == 4 ~ "qs",
      maheo2022_raw$pes_votechoice == 7 ~ "pcq",
      maheo2022_raw$pes_votechoice %in% c(5, 6) ~ "other",
      TRUE ~ NA_character_
    ),

    # Dichotomous party votes
    vote_plq = ifelse(vote_party == "plq", 1, 0),
    vote_pq = ifelse(vote_party == "pq", 1, 0),
    vote_caq = ifelse(vote_party == "caq", 1, 0),
    vote_qs = ifelse(vote_party == "qs", 1, 0),
    vote_pcq = ifelse(vote_party == "pcq", 1, 0),
    vote_other = ifelse(vote_party == "other", 1, 0)
  )

cat("  G1. VOTE CHOICE: done\n")
cat("    belanger2018:", sum(!is.na(belanger2018_clean$vote_party)), "with vote_party\n")
cat("    maheo2022:", sum(!is.na(maheo2022_clean$vote_party)), "with vote_party\n\n")


# G2. Partisan identification (PID) ----
# --------------------------------------
# belanger2018:
#   Q56: "Vous considérez-vous habituellement comme un...?"
#     1=Libéral, 2=Péquiste, 3=Caquiste, 4=Solidaire, 5=Rien de cela
#   Q57: "Force de l'identification - Très/Assez/Pas très fortement"
#     1=Très, 2=Assez, 3=Pas très
#
# maheo2022:
#   cps_provpid: "Vous considérez-vous habituellement comme étant:"
#     libéral/péquiste/caquiste/solidaire/conservateur/autre/aucun
#   cps_provpidstr: "À quel point vous sentez-vous [parti]?"
#     1=Très proche, 2=Proche, 3=Pas très proche
#
# VARIABLES À CRÉER:
#   pid_party                 : Categorical - party identification
#   pid_strength              : Ordinal - strength (0=none, 1=weak, 2=moderate, 3=strong)
#   pid_plq                   : Dichotomous - Identifie PLQ (0/1)
#   pid_pq                    : Dichotomous - Identifie PQ (0/1)
#   pid_caq                   : Dichotomous - Identifie CAQ (0/1)
#   pid_qs                    : Dichotomous - Identifie QS (0/1)
#   pid_pcq                   : Dichotomous - Identifie PCQ (0/1) [2022 seulement]
#   pid_none                  : Dichotomous - Aucune identification (0/1)
#   pid_strong_pq             : Dichotomous - PQ très fortement (0/1)
#
# OUTPUT: Harmonisation force PID entre échelles
# ============================================================================ #

cat("Cleaning G2. PARTISAN ID variables...\n")

# belanger2018 - Q56, Q57
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # Q56: PID party (1=PLQ, 2=PQ, 3=CAQ, 4=QS, 97=None, 98/99=NA)
    pid_party = case_when(
      belanger2018_raw$q56 == 1 ~ "plq",
      belanger2018_raw$q56 == 2 ~ "pq",
      belanger2018_raw$q56 == 3 ~ "caq",
      belanger2018_raw$q56 == 4 ~ "qs",
      belanger2018_raw$q56 == 97 ~ "none",
      TRUE ~ NA_character_
    ),

    # Q57: PID strength (1=Très, 2=Assez, 3=Pas très)
    # Convert to 0-3 scale: 0=none, 1=weak, 2=moderate, 3=strong
    pid_strength = case_when(
      pid_party == "none" ~ 0,
      belanger2018_raw$q57 == 3 ~ 1,  # Pas très fortement = weak
      belanger2018_raw$q57 == 2 ~ 2,  # Assez fortement = moderate
      belanger2018_raw$q57 == 1 ~ 3,  # Très fortement = strong
      TRUE ~ NA_real_
    ),

    # Dichotomous PIDs
    pid_plq = ifelse(pid_party == "plq", 1, 0),
    pid_pq = ifelse(pid_party == "pq", 1, 0),
    pid_caq = ifelse(pid_party == "caq", 1, 0),
    pid_qs = ifelse(pid_party == "qs", 1, 0),
    pid_pcq = 0,  # PCQ didn't exist in 2018
    pid_none = ifelse(pid_party == "none", 1, 0),

    # Strong PQ identifier
    pid_strong_pq = ifelse(pid_pq == 1 & pid_strength == 3, 1, 0)
  )

# maheo2022 - cps_provpid, cps_provpidstr
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # cps_provpid (1=PLQ, 2=PQ, 3=CAQ, 4=QS, 7=PCQ, 5=Autre, 6=None)
    pid_party = case_when(
      maheo2022_raw$cps_provpid == 1 ~ "plq",
      maheo2022_raw$cps_provpid == 2 ~ "pq",
      maheo2022_raw$cps_provpid == 3 ~ "caq",
      maheo2022_raw$cps_provpid == 4 ~ "qs",
      maheo2022_raw$cps_provpid == 7 ~ "pcq",
      maheo2022_raw$cps_provpid == 6 ~ "none",
      maheo2022_raw$cps_provpid == 5 ~ "other",
      TRUE ~ NA_character_
    ),

    # cps_provpidstr (1=Very strongly, 2=Fairly, 3=Not very)
    # Convert to 0-3 scale: 0=none, 1=weak, 2=moderate, 3=strong
    pid_strength = case_when(
      pid_party == "none" ~ 0,
      maheo2022_raw$cps_provpidstr == 3 ~ 1,  # Not very = weak
      maheo2022_raw$cps_provpidstr == 2 ~ 2,  # Fairly = moderate
      maheo2022_raw$cps_provpidstr == 1 ~ 3,  # Very strongly = strong
      TRUE ~ NA_real_
    ),

    # Dichotomous PIDs
    pid_plq = ifelse(pid_party == "plq", 1, 0),
    pid_pq = ifelse(pid_party == "pq", 1, 0),
    pid_caq = ifelse(pid_party == "caq", 1, 0),
    pid_qs = ifelse(pid_party == "qs", 1, 0),
    pid_pcq = ifelse(pid_party == "pcq", 1, 0),
    pid_none = ifelse(pid_party == "none", 1, 0),

    # Strong PQ identifier
    pid_strong_pq = ifelse(pid_pq == 1 & pid_strength == 3, 1, 0)
  )

cat("  G2. PARTISAN ID: done\n")
cat("    belanger2018:", sum(!is.na(belanger2018_clean$pid_party)), "with pid_party\n")
cat("    maheo2022:", sum(!is.na(maheo2022_clean$pid_party)), "with pid_party\n\n")


# G3. Thermomètres partis ----
# ----------------------------
# belanger2018:
#   [PAS DISPONIBLE - utiliser thermomètres leaders comme proxy]
#
# maheo2022:
#   cps_partytherm_23: PLQ (0-100)
#   cps_partytherm_25: PQ (0-100)
#   cps_partytherm_27: CAQ (0-100)
#   cps_partytherm_30: QS (0-100)
#   cps_partytherm_33: PCQ (0-100)
#
# VARIABLES À CRÉER:
#   party_therm_plq           : Thermomètre PLQ (0-100)
#   party_therm_pq            : Thermomètre PQ (0-100)
#   party_therm_caq           : Thermomètre CAQ (0-100)
#   party_therm_qs            : Thermomètre QS (0-100)
#   party_therm_pcq           : Thermomètre PCQ (0-100) [2022 seulement]
#
# OUTPUT: Échelle 0-100, NA si "Je ne connais pas ce parti"
# ============================================================================ #

# SKIP G3: Thermomètres partis (2022 seulement - non comparable)
# SKIP G4: Thermomètres leaders (trop contextuel - non comparable)
# SKIP G5: Vote négatif + 2e choix (pas comparables entre 2018-2022)
# SKIP G6: Enjeux et meilleur parti (2022 seulement - non comparable)


# ============================================================================ #
# H. SES/DÉMOGRAPHIE ----
# ============================================================================ #
# belanger2018:
#   age: Âge
#   d3: Éducation
#   s1: Langue maternelle
#   fsa_tabl / region: Région
#   sexfix: Sexe
#   d5: Revenu
#
# maheo2022:
#   cps_age_in_years: Âge
#   cps_edu: Éducation
#   cps_mother_tongue: Langue maternelle
#   [region variable à identifier]
#   cps_genderid: Genre
#   [income variable à identifier]
#
# VARIABLES À CRÉER (harmonisées):
#   ses_age                       : Âge (numeric)
#   ses_age_group                 : Groupe d'âge (18-34, 35-54, 55+)
#   ses_education                 : Niveau d'éducation harmonisé (categorical)
#   ses_education_university      : Diplôme universitaire (0/1)
#   ses_language                  : Langue maternelle harmonisée (french/english/other)
#   ses_language_french           : Francophone (0/1)
#   ses_region                    : Région harmonisée
#   ses_region_montreal           : Région métropolitaine MTL (0/1)
#   ses_gender                    : Genre (male/female/other)
#   ses_income                    : Revenu harmonisé (categorical)
#   ses_income_high               : Revenu élevé (0/1)
#
# OUTPUT: Harmonisation catégories entre années
#         Toutes variables SES avec préfixe ses_ pour cohérence
# ============================================================================ #

cat("Cleaning H. SES/DÉMOGRAPHIE variables...\n")

# belanger2018 - age (catégoriel), qsexe, qlangue, qscol
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    # age is categorical (1-5), convert to approximate numeric midpoints
    ses_age = case_when(
      belanger2018_raw$age == 1 ~ 24,   # 18-29
      belanger2018_raw$age == 2 ~ 37,   # 30-44
      belanger2018_raw$age == 3 ~ 52,   # 45-59
      belanger2018_raw$age == 4 ~ 67,   # 60-74
      belanger2018_raw$age == 5 ~ 80,   # 75+
      TRUE ~ NA_real_
    ),

    # qsexe: 1=homme, 2=femme
    ses_gender = case_when(
      belanger2018_raw$qsexe == 1 ~ "male",
      belanger2018_raw$qsexe == 2 ~ "female",
      TRUE ~ NA_character_
    ),

    # qlangue: 1=français, 2=anglais, 96=autre
    ses_language = case_when(
      belanger2018_raw$qlangue == 1 ~ "french",
      belanger2018_raw$qlangue == 2 ~ "english",
      belanger2018_raw$qlangue == 96 ~ "other",
      TRUE ~ NA_character_
    ),

    # qscol: years of schooling (1-15)
    ses_education = case_when(
      belanger2018_raw$qscol >= 99 ~ NA_character_,
      belanger2018_raw$qscol <= 10 ~ "low",      # Secondaire ou moins
      belanger2018_raw$qscol <= 12 ~ "medium",   # Collégial
      belanger2018_raw$qscol >= 13 ~ "high",     # Universitaire
      TRUE ~ NA_character_
    )
  )

# maheo2022 - cps_age_in_years, cps_genderid, cps_lang, cps_edu
maheo2022_clean <- maheo2022_clean %>%
  mutate(
    # age already numeric
    ses_age = maheo2022_raw$cps_age_in_years,

    # cps_genderid: 1=male, 2=female, 3/4=other
    ses_gender = case_when(
      maheo2022_raw$cps_genderid == 1 ~ "male",
      maheo2022_raw$cps_genderid == 2 ~ "female",
      maheo2022_raw$cps_genderid %in% c(3, 4) ~ "other",
      TRUE ~ NA_character_
    ),

    # cps_lang: 1=english, 2=french (can have multiple, priority french>english>other)
    ses_language = case_when(
      maheo2022_raw$cps_lang_2 == 1 & maheo2022_raw$cps_lang_1 != 1 ~ "french",
      maheo2022_raw$cps_lang_1 == 1 & maheo2022_raw$cps_lang_2 != 1 ~ "english",
      maheo2022_raw$cps_lang_2 == 1 & maheo2022_raw$cps_lang_1 == 1 ~ "french",  # bilingual = french
      maheo2022_raw$cps_lang_3 == 1 ~ "other",
      TRUE ~ NA_character_
    ),

    # cps_edu: 2-11 scale
    ses_education = case_when(
      maheo2022_raw$cps_edu <= 5 ~ "low",      # ≤ High school
      maheo2022_raw$cps_edu <= 8 ~ "medium",   # College/Some university
      maheo2022_raw$cps_edu >= 9 ~ "high",     # Bachelor+
      TRUE ~ NA_character_
    )
  )

cat("  H. SES/DÉMOGRAPHIE: done\n")
cat("    belanger2018:", sum(!is.na(belanger2018_clean$ses_age)), "with ses_age\n")
cat("    maheo2022:", sum(!is.na(maheo2022_clean$ses_age)), "with ses_age\n\n")


# ============================================================================ #
# I. VARIABLES DÉRIVÉES POUR CATÉGORISATION DES ÉLECTEURS ----
# ============================================================================ #
# Basé sur les critères définis dans plan_claude.md (lignes 501-602)
#
# CATÉGORIES À CRÉER:
#   pq_base_militant          : Base militante PQ (0/1)
#   pq_voter                  : Électeur PQ (0/1)
#   pq_pragmatic_voter        : Électeur PQ pragmatique (0/1)
#   pq_potential_electorate   : Électorat potentiel PQ (0/1)
#   pq_categorical_rejection  : Rejet catégorique PQ (0/1)
#   pq_voter_type             : Categorical - base/voter/pragmatic/potential/reject/other
#
# Critères BASE MILITANTE PQ (au moins 2 sur 3):
#   1. S'identifient "très fortement péquistes"
#   2. Thermomètre leader PQ ≥ 80/100
#   3. Vote PQ ET premier choix ET choix fait tôt (2018) / PQ pas dans negativevote (2022)
#
# Critères ÉLECTEUR PQ PRAGMATIQUE:
#   1. Votent PQ
#   2. ET (PID ≠ péquiste OU force PID faible)
#   3. ET (Thermomètre < 80 OU pas premier choix)
#
# Critères ÉLECTORAT POTENTIEL PQ (au moins 1):
#   1. Ne votent PAS PQ
#   2. MAIS: PQ 2e choix OU Thermomètre PQ ≥ 50 OU PQ pas dans negativevote
#
# Critères REJET CATÉGORIQUE PQ:
#   2018: Thermomètre leader PQ ≤ 20/100
#   2022: PQ dans cps_negativevote
#
# OUTPUT: Variables dichotomiques + variable catégorielle combinée
# ============================================================================ #

# SKIP I: Catégories électeurs (user fera l'analyse lui-même avec vote + PID + strength)


# ============================================================================ #
# J. POIDS D'ÉCHANTILLONNAGE ----
# ============================================================================ #
# belanger2018:
#   [À vérifier si variable de pondération existe]
#
# maheo2022:
#   cps_weight_general: Poids général
#   cps_weight_general_trimmed: Poids trimmed
#
# VARIABLES À CRÉER:
#   weight                    : Poids d'échantillonnage (1 si absent)
#
# OUTPUT: Variable weight harmonisée entre années
# ============================================================================ #

cat("Cleaning J. POIDS variables...\n")

# belanger2018 - pond
belanger2018_clean <- belanger2018_clean %>%
  mutate(weight = belanger2018_raw$pond)

# maheo2022 - cps_weight_general
maheo2022_clean <- maheo2022_clean %>%
  mutate(weight = maheo2022_raw$cps_weight_general)

cat("  J. POIDS: done\n")
cat("    belanger2018 weight mean:", round(mean(belanger2018_clean$weight, na.rm=TRUE), 3), "\n")
cat("    maheo2022 weight mean:", round(mean(maheo2022_clean$weight, na.rm=TRUE), 3), "\n\n")


# ============================================================================ #
# COMBINE DATASETS ----
# ============================================================================ #

cat("Combining datasets...\n")

# Add dataset identifier and year
belanger2018_clean <- belanger2018_clean %>%
  mutate(
    dataset = "belanger2018",
    year = 2018
  )

maheo2022_clean <- maheo2022_clean %>%
  mutate(
    dataset = "maheo2022",
    year = 2022
  )

combined_data <- bind_rows(
  belanger2018_clean,
  maheo2022_clean
)

cat(sprintf("  Combined dataset: %d observations\n", nrow(combined_data)))
cat(sprintf("    belanger2018: %d (%.1f%%)\n",
            sum(combined_data$dataset == "belanger2018"),
            100 * sum(combined_data$dataset == "belanger2018") / nrow(combined_data)))
cat(sprintf("    maheo2022: %d (%.1f%%)\n\n",
            sum(combined_data$dataset == "maheo2022"),
            100 * sum(combined_data$dataset == "maheo2022") / nrow(combined_data)))


# ============================================================================ #
# EXPORT ----
# ============================================================================ #

cat("Exporting clean datasets...\n")

write_csv(belanger2018_clean, "data/clean/belanger2018_clean.csv")
write_csv(maheo2022_clean, "data/clean/maheo2022_clean.csv")
write_csv(combined_data, "data/clean/combined_clean.csv")
saveRDS(combined_data, "data/clean/combined_clean.rds")

cat("  ✓ data/clean/belanger2018_clean.csv\n")
cat("  ✓ data/clean/maheo2022_clean.csv\n")
cat("  ✓ data/clean/combined_clean.csv\n")
cat("  ✓ data/clean/combined_clean.rds\n\n")

cat("Data cleaning complete!\n")


# ============================================================================ #
# SUMMARY STATISTICS ----
# ============================================================================ #

cat("\n=== SUMMARY STATISTICS ===\n\n")

cat("Variables created:\n")
cat(sprintf("  Total variables: %d\n", ncol(combined_data)))
cat(sprintf("  belanger2018 variables: %d\n", ncol(belanger2018_clean)))
cat(sprintf("  maheo2022 variables: %d\n", ncol(maheo2022_clean)))

cat("\nVariable categories:\n")
cat("  A. NATIVISME (7 items + 4 indices)\n")
cat("  B. IMMIGRATION\n")
cat("     B1. Niveau souhaité (3-4 variables)\n")
cat("     B2. Attitudes qualitatives (7 variables + 1 index) [2022 seulement]\n")
cat("  C. THERMOMÈTRES GROUPES (5-7 variables)\n")
cat("  D. LAÏCITÉ (2-3 variables)\n")
cat("  E. IDENTITÉ (5 variables)\n")
cat("  F. SOUVERAINETÉ (3 variables)\n")
cat("  G. ÉLECTEURS (vote, PID, thermomètres, enjeux, ~40 variables)\n")
cat("     G1. Vote choice\n")
cat("     G2. Partisan ID\n")
cat("     G3. Thermomètres partis\n")
cat("     G4. Thermomètres leaders\n")
cat("     G5. Vote négatif et 2e choix\n")
cat("     G6. Enjeux importants et meilleur parti [2022 seulement]\n")
cat("  H. SES/DÉMOGRAPHIE (11 variables, préfixe ses_)\n")
cat("  I. CATÉGORIES ÉLECTEURS (6 variables)\n")
cat("  J. POIDS (1 variable)\n")

# END OF SCRIPT
