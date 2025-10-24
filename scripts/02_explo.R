# ============================================================================ #
# SCRIPT D'EXPLORATION - NATIVISME PAR PARTI
# Projet: Virage nativiste du PQ
# Auteur: Opubliq
# Date: 2025-10-24
# ============================================================================ #
#
# Description:
# Exploration des attitudes nativistes par parti politique (2018 et 2022)
#
# ============================================================================ #

# SETUP ----
library(dplyr)
library(tidyr)
library(ggplot2)
library(readr)

# Create output directory if it doesn't exist
dir.create("output", showWarnings = FALSE, recursive = TRUE)

# LOAD CLEAN DATA ----
cat("Loading clean data...\n")
combined <- read_rds("data/clean/combined_clean.rds")

cat(sprintf("  Total observations: %d\n", nrow(combined)))
cat(sprintf("  2018: %d observations\n", sum(combined$year == 2018)))
cat(sprintf("  2022: %d observations\n\n", sum(combined$year == 2022)))


# ============================================================================ #
# 1. CRITÈRES D'APPARTENANCE NATIONALE - VUE D'ENSEMBLE ----
# ============================================================================ #

cat("=== ANALYSE DES CRITÈRES D'APPARTENANCE PAR PARTI ===\n\n")

# Variables disponibles (7 critères pour "être vraiment Québécois")
# Note: Selon Mudde (2007), le NATIVISME = critères ETHNIQUES/ASCRIPTIFS seulement
nativism_vars <- c(
  # CRITÈRES ETHNIQUES/ASCRIPTIFS (= nativisme, EXCLUSIFS):
  "nativism_born_qc",           # Né au Québec
  "nativism_ancestors_qc",      # Ancêtres/grands-parents nés au QC
  "nativism_speak_french",      # Parler français
  # CRITÈRES CIVIQUES (≠ nativisme, INCLUSIFS):
  "nativism_lived_qc",          # Vécu la plus grande partie au QC
  "nativism_feel_quebecer",     # Se sentir Québécois
  "nativism_share_values",      # Partager les valeurs
  "nativism_respect_institutions" # Respecter institutions
)

# Créer indices de conception de l'appartenance nationale
# Note: "Nativisme" réfère aux critères ETHNIQUES/ASCRIPTIFS (Mudde, 2007)
# Les critères CIVIQUES sont INCLUSIFS, donc OPPOSÉS au nativisme
combined <- combined %>%
  mutate(
    # Critères ETHNIQUES/ASCRIPTIFS (= NATIVISME): naissance, ancêtres, langue
    # Ces critères sont EXCLUSIFS - on ne peut pas les changer
    criteria_ethnic = rowMeans(select(., nativism_born_qc, nativism_ancestors_qc,
                                      nativism_speak_french), na.rm = TRUE),

    # Critères CIVIQUES (≠ nativisme): vécu, sentiment, valeurs, institutions
    # Ces critères sont INCLUSIFS - n'importe qui peut les remplir
    criteria_civic = rowMeans(select(., nativism_lived_qc, nativism_feel_quebecer,
                                     nativism_share_values, nativism_respect_institutions),
                             na.rm = TRUE),

    # Score moyen tous critères (pour comparaisons générales)
    criteria_all = rowMeans(select(., all_of(nativism_vars)), na.rm = TRUE),

    # Ratio ethnique/civique (>1 = priorité aux critères exclusifs)
    ratio_ethnic_civic = criteria_ethnic / criteria_civic
  )


# ============================================================================ #
# 2. STATISTIQUES DESCRIPTIVES PAR PARTI ----
# ============================================================================ #

cat("--- Critères d'appartenance par parti (toutes années confondues) ---\n\n")

# Filtrer seulement les électeurs (vote_party non-NA)
voters <- combined %>% filter(!is.na(vote_party))

# Calculer moyennes par parti
criteria_by_party <- voters %>%
  group_by(vote_party) %>%
  summarise(
    n = n(),
    ethnic_mean = mean(criteria_ethnic, na.rm = TRUE),
    civic_mean = mean(criteria_civic, na.rm = TRUE),
    all_mean = mean(criteria_all, na.rm = TRUE),
    ratio_mean = mean(ratio_ethnic_civic, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(ethnic_mean))

print(criteria_by_party)
cat("\n")


# ============================================================================ #
# 3. COMPARAISON 2018 VS 2022 ----
# ============================================================================ #

cat("--- Critères d'appartenance par parti et année ---\n\n")

criteria_by_party_year <- voters %>%
  group_by(vote_party, year) %>%
  summarise(
    n = n(),
    ethnic = mean(criteria_ethnic, na.rm = TRUE),
    civic = mean(criteria_civic, na.rm = TRUE),
    all = mean(criteria_all, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(vote_party, year)

print(criteria_by_party_year)
cat("\n")

# Calculer évolution 2018 → 2022 pour PQ (critères ethniques = nativisme)
pq_evolution <- criteria_by_party_year %>%
  filter(vote_party == "pq") %>%
  select(year, ethnic, civic) %>%
  pivot_wider(names_from = year, values_from = c(ethnic, civic))

cat("Évolution PQ (2018 → 2022):\n")
cat(sprintf("  Critères ETHNIQUES 2018: %.3f\n", pq_evolution$ethnic_2018))
cat(sprintf("  Critères ETHNIQUES 2022: %.3f\n", pq_evolution$ethnic_2022))
cat(sprintf("  Changement ethnique: %+.3f\n", pq_evolution$ethnic_2022 - pq_evolution$ethnic_2018))
cat(sprintf("  Critères CIVIQUES 2018: %.3f\n", pq_evolution$civic_2018))
cat(sprintf("  Critères CIVIQUES 2022: %.3f\n", pq_evolution$civic_2022))
cat(sprintf("  Changement civique: %+.3f\n\n", pq_evolution$civic_2022 - pq_evolution$civic_2018))


# ============================================================================ #
# 4. DÉTAIL DES 7 ITEMS PAR PARTI (2018+2022 combinés) ----
# ============================================================================ #

cat("--- Détail des 7 critères d'appartenance par parti ---\n\n")

items_by_party <- voters %>%
  group_by(vote_party) %>%
  summarise(
    n = n(),
    # Critères ETHNIQUES/ASCRIPTIFS (= nativisme)
    born_qc = mean(nativism_born_qc, na.rm = TRUE),
    ancestors_qc = mean(nativism_ancestors_qc, na.rm = TRUE),
    speak_french = mean(nativism_speak_french, na.rm = TRUE),
    # Critères CIVIQUES (inclusifs)
    lived_qc = mean(nativism_lived_qc, na.rm = TRUE),
    feel_quebecer = mean(nativism_feel_quebecer, na.rm = TRUE),
    share_values = mean(nativism_share_values, na.rm = TRUE),
    respect_inst = mean(nativism_respect_institutions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(ancestors_qc))  # Trier par critère le plus exclusif

print(items_by_party, width = Inf)
cat("\n")


# ============================================================================ #
# 5. VISUALISATION: CRITÈRES D'APPARTENANCE PAR PARTI (2022) ----
# ============================================================================ #

cat("Création visualisation critères d'appartenance par parti (2022)...\n")

# Préparer données pour graphique (2022 seulement pour plus de clarté)
plot_data_2022 <- voters %>%
  filter(year == 2022, vote_party %in% c("plq", "pq", "caq", "qs", "pcq")) %>%
  select(vote_party, all_of(nativism_vars)) %>%
  pivot_longer(cols = all_of(nativism_vars),
               names_to = "item",
               values_to = "score") %>%
  mutate(
    # Labels français pour les items avec distinction ethnique/civique
    item_label = case_when(
      item == "nativism_born_qc" ~ "Né au QC [E]",
      item == "nativism_ancestors_qc" ~ "Ancêtres au QC [E]",
      item == "nativism_speak_french" ~ "Parler français [E]",
      item == "nativism_lived_qc" ~ "Vécu au QC [C]",
      item == "nativism_feel_quebecer" ~ "Se sentir Québécois [C]",
      item == "nativism_share_values" ~ "Partager valeurs [C]",
      item == "nativism_respect_institutions" ~ "Respecter institutions [C]"
    ),
    # Type de critère
    criterion_type = ifelse(item %in% c("nativism_born_qc", "nativism_ancestors_qc", "nativism_speak_french"),
                           "Ethnique/Ascriptif", "Civique/Inclusif"),
    # Labels partis
    party_label = toupper(vote_party)
  )

# Calculer moyennes par parti et item
plot_summary <- plot_data_2022 %>%
  group_by(party_label, item_label, criterion_type) %>%
  summarise(mean_score = mean(score, na.rm = TRUE), .groups = "drop")

# Graphique: Heatmap critères d'appartenance par parti
p1 <- ggplot(plot_summary, aes(x = party_label, y = item_label, fill = mean_score)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.2f", mean_score)), color = "white", size = 3.5, fontface = "bold") +
  scale_fill_gradient2(low = "#3498db", mid = "#e74c3c", high = "#c0392b",
                       midpoint = 0.7, limits = c(0, 1),
                       name = "Score moyen\n(0-1)") +
  labs(
    title = "Critères d'appartenance québécoise par parti (2022)",
    subtitle = "Importance des critères pour 'être vraiment Québécois' | [E] = Ethnique/Exclusif | [C] = Civique/Inclusif",
    x = "Parti voté",
    y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10),
    axis.text.x = element_text(face = "bold", size = 11),
    panel.grid = element_blank()
  )

print(p1)
ggsave("output/criteria_heatmap_2022.png", p1, width = 9, height = 6, dpi = 300)
cat("  ✓ Saved: output/criteria_heatmap_2022.png\n\n")


# ============================================================================ #
# 6. VISUALISATION: CRITÈRES ETHNIQUES VS CIVIQUES PAR PARTI ----
# ============================================================================ #

cat("Création visualisation critères ethniques vs civiques...\n")

# Préparer données
plot_data_ethnic_civic <- voters %>%
  filter(year == 2022, vote_party %in% c("plq", "pq", "caq", "qs", "pcq")) %>%
  group_by(vote_party) %>%
  summarise(
    n = n(),
    ethnic = mean(criteria_ethnic, na.rm = TRUE),
    civic = mean(criteria_civic, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(party_label = toupper(vote_party)) %>%
  pivot_longer(cols = c(ethnic, civic), names_to = "type", values_to = "score")

# Couleurs partis
party_colors <- c(
  "PLQ" = "#ED1A2D",
  "PQ" = "#004C9D",
  "CAQ" = "#00AADB",
  "QS" = "#FF5605",
  "PCQ" = "#5E2C7C"
)

p2 <- ggplot(plot_data_ethnic_civic, aes(x = party_label, y = score, fill = type)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(values = c("ethnic" = "#e74c3c", "civic" = "#3498db"),
                    labels = c("civic" = "Critères civiques (inclusifs)",
                               "ethnic" = "Critères ethniques (nativisme)"),
                    name = NULL) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2)) +
  labs(
    title = "Critères ethniques vs civiques d'appartenance par parti (2022)",
    subtitle = "Ethniques (nativisme) = naissance, ancêtres, langue | Civiques (inclusifs) = vécu, sentiment, valeurs, institutions",
    x = "Parti voté",
    y = "Score moyen (0-1)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 9),
    legend.position = "top",
    panel.grid.major.x = element_blank()
  )

print(p2)
ggsave("output/criteria_ethnic_civic_2022.png", p2, width = 9, height = 6, dpi = 300)
cat("  ✓ Saved: output/criteria_ethnic_civic_2022.png\n\n")


# ============================================================================ #
# 7. ÉVOLUTION TEMPORELLE: CRITÈRES ETHNIQUES (NATIVISME) PAR PARTI ----
# ============================================================================ #

cat("Création visualisation évolution temporelle...\n")

# Évolution 2018-2022 pour partis majeurs - CRITÈRES ETHNIQUES seulement
plot_data_evolution <- voters %>%
  filter(vote_party %in% c("plq", "pq", "caq", "qs")) %>%
  group_by(vote_party, year) %>%
  summarise(
    n = n(),
    ethnic = mean(criteria_ethnic, na.rm = TRUE),
    civic = mean(criteria_civic, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(party_label = toupper(vote_party))

p3 <- ggplot(plot_data_evolution, aes(x = year, y = ethnic, color = party_label, group = party_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = party_colors, name = "Parti") +
  scale_x_continuous(breaks = c(2018, 2022)) +
  scale_y_continuous(limits = c(0.5, 0.9), breaks = seq(0.5, 0.9, 0.1)) +
  labs(
    title = "Évolution du nativisme (critères ethniques) par parti (2018-2022)",
    subtitle = "Score moyen sur critères ascriptifs: naissance, ancêtres, langue",
    x = "Année",
    y = "Score nativisme ethnique (0-1)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

print(p3)
ggsave("output/nativism_evolution_2018_2022.png", p3, width = 9, height = 6, dpi = 300)
cat("  ✓ Saved: output/nativism_evolution_2018_2022.png\n\n")


# ============================================================================ #
# 8. EXPORT TABLEAU RÉCAPITULATIF ----
# ============================================================================ #

cat("Export tableau récapitulatif...\n")

# Tableau final avec toutes les stats
summary_table <- voters %>%
  group_by(year, vote_party) %>%
  summarise(
    n = n(),
    # Indices
    criteria_ethnic = mean(criteria_ethnic, na.rm = TRUE),
    criteria_civic = mean(criteria_civic, na.rm = TRUE),
    criteria_all = mean(criteria_all, na.rm = TRUE),
    ratio_ethnic_civic = mean(ratio_ethnic_civic, na.rm = TRUE),
    # Items ethniques (nativisme)
    born_qc = mean(nativism_born_qc, na.rm = TRUE),
    ancestors_qc = mean(nativism_ancestors_qc, na.rm = TRUE),
    speak_french = mean(nativism_speak_french, na.rm = TRUE),
    # Items civiques (inclusifs)
    lived_qc = mean(nativism_lived_qc, na.rm = TRUE),
    feel_quebecer = mean(nativism_feel_quebecer, na.rm = TRUE),
    share_values = mean(nativism_share_values, na.rm = TRUE),
    respect_inst = mean(nativism_respect_institutions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year, desc(criteria_ethnic))

write_csv(summary_table, "output/criteria_by_party_summary.csv")
cat("  ✓ Saved: output/criteria_by_party_summary.csv\n\n")

cat("=== EXPLORATION TERMINÉE ===\n")
cat("\nRAPPEL CONCEPTUEL:\n")
cat("  - Critères ETHNIQUES/ASCRIPTIFS (nativisme Mudde 2007):\n")
cat("      naissance, ancêtres, langue = EXCLUSIFS\n")
cat("  - Critères CIVIQUES (opposés au nativisme):\n")
cat("      vécu, sentiment, valeurs, institutions = INCLUSIFS\n")
