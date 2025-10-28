library(dplyr)
library(ggplot2)

# Fonction pour créer des catégories d'électeurs par parti
create_voter_category <- function(vote_party, pid_party, pid_strength) {
  # Convertir en numérique si nécessaire
  vote_party <- as.numeric(vote_party)
  pid_party <- as.numeric(pid_party)
  pid_strength <- as.numeric(pid_strength)

  # Initialiser la catégorie
  category <- case_when(
    # Vote pour le parti ET identification avec le parti
    vote_party == 1 & pid_party == 1 & pid_strength >= 2 ~ "solide",
    vote_party == 1 & pid_party == 1 & pid_strength == 1 ~ "fragile",

    # Vote pour le parti MAIS identification avec autre parti (toutes forces)
    vote_party == 1 & pid_party == 0 ~ "fragile",

    # Ne vote PAS pour le parti MAIS identification avec le parti
    vote_party == 0 & pid_party == 1 & pid_strength >= 2 ~ "potentiel_eleve",
    vote_party == 0 & pid_party == 1 & pid_strength == 1 ~ "potentiel_faible",

    # Ne vote PAS pour le parti ET identification avec autre parti
    vote_party == 0 & pid_party == 0 & pid_strength == 1 ~ "potentiel_faible",
    vote_party == 0 & pid_party == 0 & (pid_strength >= 2 | pid_strength == 0) ~ "inatteignable",

    # Cas par défaut (valeurs manquantes)
    TRUE ~ NA_character_
  )

  # Ordonner les catégories
  factor(category,
         levels = c("inatteignable", "potentiel_faible", "potentiel_eleve",
                    "fragile", "solide"),
         ordered = TRUE)
}

df <- readRDS("data/clean/combined_clean.rds") |>
  mutate(
    # Créer catégories d'électeurs pour chaque parti (utilise les variables binaires)
    cat_pq = create_voter_category(vote_pq, pid_pq, pid_strength),
    cat_caq = create_voter_category(vote_caq, pid_caq, pid_strength),
    cat_plq = create_voter_category(vote_plq, pid_plq, pid_strength),
    cat_qs = create_voter_category(vote_qs, pid_qs, pid_strength),
    cat_pcq = create_voter_category(vote_pcq, pid_pcq, pid_strength)
  )

ggplot(
  df,
  aes(x = weight)
) +
  geom_histogram() +
  facet_wrap(~year)

categories <- df |> 
  group_by(
    year, vote_party, pid_party, pid_strength
  ) |> 
  summarise(
    weight = sum(weight)
  ) |> 
  tidyr::drop_na()
