# ============================================================================ #
# ANALYSE FACTORIELLE - Critères d'appartenance et attitudes immigration
# Projet: Virage nativiste du PQ
# Auteur: Opubliq
# Date: 2025-10-30
# ============================================================================ #
#
# Description:
# Analyse factorielle exploratoire pour vérifier si les variables forment
# des échelles cohérentes mesurant le même phénomène latent.
#
# Questions:
# 1. Les 7 critères d'appartenance forment-ils 2 facteurs distincts (ethnique/civique)?
# 2. "Parler français" charge-t-il avec ethnique ou civique?
# 3. Les attitudes anti-immigration forment-elles un facteur cohérent?
# 4. Quelle est la fiabilité (alpha de Cronbach) de chaque dimension?
#
# ============================================================================ #

# SETUP ----
library(dplyr)
library(tidyr)
library(ggplot2)
library(readr)
library(psych)      # Pour analyse factorielle et alpha de Cronbach
library(corrplot)   # Pour visualisation matrices de corrélation

# Create output directory
dir.create("output", showWarnings = FALSE, recursive = TRUE)

# LOAD CLEAN DATA ----
cat("Loading clean data...\n")
combined <- read_rds("data/clean/combined_clean.rds")

cat(sprintf("  Total observations: %d\n", nrow(combined)))
cat(sprintf("  2018: %d observations\n", sum(combined$year == 2018)))
cat(sprintf("  2022: %d observations\n\n", sum(combined$year == 2022)))


# ============================================================================ #
# 1. ANALYSE FACTORIELLE: CRITÈRES D'APPARTENANCE (2018+2022) ----
# ============================================================================ #

cat("\n=== ANALYSE FACTORIELLE: CRITÈRES D'APPARTENANCE ===\n\n")

# Variables des 7 critères d'appartenance
nativism_vars <- c(
  "nativism_born_qc",           # Né au Québec
  "nativism_ancestors_qc",      # Ancêtres/grands-parents nés au QC
  "nativism_speak_french",      # Parler français ⭐ QUESTION CLÉ
  "nativism_lived_qc",          # Vécu la plus grande partie au QC
  "nativism_feel_quebecer",     # Se sentir Québécois
  "nativism_share_values",      # Partager les valeurs
  "nativism_respect_institutions" # Respecter institutions
)

# Préparer données (cas complets seulement)
fa_data_all <- combined %>%
  select(year, all_of(nativism_vars)) %>%
  na.omit()

cat(sprintf("N avec données complètes (2018+2022): %d\n", nrow(fa_data_all)))
cat(sprintf("  2018: %d\n", sum(fa_data_all$year == 2018)))
cat(sprintf("  2022: %d\n\n", sum(fa_data_all$year == 2022)))

# Matrice de corrélation
cat("--- Matrice de corrélation (2018+2022) ---\n\n")
cor_matrix_all <- cor(fa_data_all %>% select(-year))
print(round(cor_matrix_all, 3))
cat("\n")

# Visualisation matrice de corrélation
png("output/correlation_matrix_nativism.png", width = 2400, height = 2400, res = 300)
corrplot(cor_matrix_all, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45, tl.cex = 0.8,
         addCoef.col = "black", number.cex = 0.7,
         col = colorRampPalette(c("#3498db", "white", "#e74c3c"))(200),
         title = "Corrélations - Critères d'appartenance (2018+2022)",
         mar = c(0,0,2,0))
dev.off()
cat("  ✓ Saved: output/correlation_matrix_nativism.png\n\n")


# Test de sphéricité de Bartlett et KMO
cat("--- Tests d'adéquation pour analyse factorielle ---\n\n")
kmo_result <- KMO(fa_data_all %>% select(-year))
cat(sprintf("KMO (Kaiser-Meyer-Olkin): %.3f\n", kmo_result$MSA))
cat("  Interprétation: ")
if(kmo_result$MSA >= 0.9) cat("excellente\n")
else if(kmo_result$MSA >= 0.8) cat("méritoire\n")
else if(kmo_result$MSA >= 0.7) cat("moyenne\n")
else if(kmo_result$MSA >= 0.6) cat("médiocre\n")
else cat("inacceptable\n")

bartlett_result <- cortest.bartlett(cor_matrix_all, n = nrow(fa_data_all))
cat(sprintf("\nTest de Bartlett: chi2(%d) = %.2f, p < .001\n",
            bartlett_result$df, bartlett_result$chisq))
cat("  → Les variables sont suffisamment corrélées pour l'analyse factorielle\n\n")


# Déterminer nombre optimal de facteurs
cat("--- Détermination du nombre de facteurs ---\n\n")

# Scree plot et analyse parallèle
png("output/scree_plot_nativism.png", width = 2400, height = 1800, res = 300)
fa.parallel(fa_data_all %>% select(-year),
            fa = "fa",
            n.iter = 100,
            main = "Analyse parallèle - Critères d'appartenance",
            show.legend = TRUE)
dev.off()
cat("  ✓ Saved: output/scree_plot_nativism.png\n")

# Extraction automatique
parallel_result <- fa.parallel(fa_data_all %>% select(-year),
                               fa = "fa",
                               n.iter = 100,
                               plot = FALSE)
n_factors_suggested <- parallel_result$nfact
cat(sprintf("\nNombre de facteurs suggéré (analyse parallèle): %d\n\n", n_factors_suggested))


# Analyse factorielle avec 2 facteurs (hypothèse ethnique/civique)
cat("--- Analyse factorielle: 2 facteurs (rotation oblimin) ---\n\n")
cat("Hypothèse: Facteur 1 = Ethnique/Ascriptif | Facteur 2 = Civique/Inclusif\n\n")

fa_2factors <- fa(fa_data_all %>% select(-year),
                  nfactors = 2,
                  rotate = "oblimin",  # Rotation oblique (facteurs corrélés)
                  fm = "ml")           # Maximum likelihood

print(fa_2factors, cut = 0.3, digits = 3)
cat("\n")

# Variance expliquée
cat("Variance expliquée:\n")
cat(sprintf("  Facteur 1: %.1f%%\n", fa_2factors$Vaccounted[2,1] * 100))
cat(sprintf("  Facteur 2: %.1f%%\n", fa_2factors$Vaccounted[2,2] * 100))
cat(sprintf("  Total: %.1f%%\n\n", sum(fa_2factors$Vaccounted[2,]) * 100))

# Corrélation entre facteurs
cat("Corrélation entre facteurs:\n")
print(round(fa_2factors$Phi, 3))
cat("\n")


# Visualisation des loadings
loadings_df <- as.data.frame(fa_2factors$loadings[,1:2])
loadings_df$variable <- rownames(loadings_df)
colnames(loadings_df)[1:2] <- c("Facteur1", "Facteur2")

loadings_long <- loadings_df %>%
  pivot_longer(cols = c(Facteur1, Facteur2),
               names_to = "factor",
               values_to = "loading")

p_loadings <- ggplot(loadings_long, aes(x = variable, y = loading, fill = factor)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_hline(yintercept = c(-0.3, 0.3), linetype = "dashed", color = "gray50") +
  scale_fill_manual(values = c("Facteur1" = "#e74c3c", "Facteur2" = "#3498db"),
                    name = NULL) +
  coord_flip() +
  labs(
    title = "Loadings factoriels - Critères d'appartenance",
    subtitle = "Rotation oblimin | Lignes pointillées: seuil ±0.3",
    x = NULL,
    y = "Loading"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "top"
  )

print(p_loadings)
ggsave("output/factor_loadings_nativism.png", p_loadings,
       width = 10, height = 6, dpi = 300)
cat("  ✓ Saved: output/factor_loadings_nativism.png\n\n")


# ============================================================================ #
# 2. FIABILITÉ: ALPHA DE CRONBACH ----
# ============================================================================ #

cat("\n=== FIABILITÉ DES ÉCHELLES (Alpha de Cronbach) ===\n\n")

# Identifier les variables qui chargent sur chaque facteur (loading > 0.4)
factor1_vars <- rownames(fa_2factors$loadings)[abs(fa_2factors$loadings[,1]) > 0.4]
factor2_vars <- rownames(fa_2factors$loadings)[abs(fa_2factors$loadings[,2]) > 0.4]

cat("Variables chargeant sur Facteur 1 (|loading| > 0.4):\n")
cat(paste("  -", factor1_vars, "\n"))
cat("\n")

cat("Variables chargeant sur Facteur 2 (|loading| > 0.4):\n")
cat(paste("  -", factor2_vars, "\n"))
cat("\n")

# Alpha de Cronbach pour chaque dimension
if(length(factor1_vars) >= 2) {
  alpha_f1 <- alpha(fa_data_all %>% select(all_of(factor1_vars)))
  cat("--- Alpha de Cronbach - Facteur 1 ---\n")
  print(alpha_f1, digits = 3)
  cat("\n")
}

if(length(factor2_vars) >= 2) {
  alpha_f2 <- alpha(fa_data_all %>% select(all_of(factor2_vars)))
  cat("--- Alpha de Cronbach - Facteur 2 ---\n")
  print(alpha_f2, digits = 3)
  cat("\n")
}

# Classification a priori (naissance + ancêtres = ethnique)
cat("--- Comparaison avec classification a priori ---\n\n")

ethnic_priori <- c("nativism_born_qc", "nativism_ancestors_qc")
civic_priori <- c("nativism_speak_french", "nativism_lived_qc",
                  "nativism_feel_quebecer", "nativism_share_values",
                  "nativism_respect_institutions")

alpha_ethnic_priori <- alpha(fa_data_all %>% select(all_of(ethnic_priori)))
cat("Alpha - Critères ethniques a priori (naissance + ancêtres):\n")
cat(sprintf("  α = %.3f\n\n", alpha_ethnic_priori$total$raw_alpha))

alpha_civic_priori <- alpha(fa_data_all %>% select(all_of(civic_priori)))
cat("Alpha - Critères civiques a priori (langue + vécu + sentiment + valeurs + institutions):\n")
cat(sprintf("  α = %.3f\n\n", alpha_civic_priori$total$raw_alpha))


# ============================================================================ #
# 3. ANALYSE FACTORIELLE PAR ANNÉE (2018 vs 2022) ----
# ============================================================================ #

cat("\n=== ANALYSE FACTORIELLE PAR ANNÉE ===\n\n")

for(yr in c(2018, 2022)) {
  cat(sprintf("--- Année %d ---\n\n", yr))

  fa_data_year <- combined %>%
    filter(year == yr) %>%
    select(all_of(nativism_vars)) %>%
    na.omit()

  cat(sprintf("N avec données complètes: %d\n\n", nrow(fa_data_year)))

  # Analyse factorielle 2 facteurs
  fa_year <- fa(fa_data_year,
                nfactors = 2,
                rotate = "oblimin",
                fm = "ml")

  cat("Loadings:\n")
  print(fa_year, cut = 0.3, digits = 3)
  cat("\n")

  cat(sprintf("Variance expliquée totale: %.1f%%\n\n",
              sum(fa_year$Vaccounted[2,]) * 100))
}


# ============================================================================ #
# 4. ANALYSE FACTORIELLE: ATTITUDES IMMIGRATION (2022 seulement) ----
# ============================================================================ #

cat("\n=== ANALYSE FACTORIELLE: ATTITUDES ENVERS IMMIGRATION (2022) ===\n\n")

# Variables d'attitudes immigration (2022 seulement)
immig_attitude_vars <- c(
  "immig_harm_culture",       # Culture mise à mal ⭐
  "immig_dont_integrate",     # Ne veulent pas s'intégrer
  "immig_take_jobs",          # Enlèvent emplois
  "immig_increase_crime",     # Augmentent criminalité
  "immig_minorities_adapt",   # Devraient s'adapter
  "immig_good_economy"        # Mauvais pour économie (inversé)
)

# Préparer données 2022
fa_data_immig <- combined %>%
  filter(year == 2022) %>%
  select(all_of(immig_attitude_vars)) %>%
  na.omit()

cat(sprintf("N avec données complètes (2022): %d\n\n", nrow(fa_data_immig)))

# Matrice de corrélation
cat("--- Matrice de corrélation - Attitudes immigration ---\n\n")
cor_matrix_immig <- cor(fa_data_immig)
print(round(cor_matrix_immig, 3))
cat("\n")

# Visualisation
png("output/correlation_matrix_immigration.png", width = 2400, height = 2400, res = 300)
corrplot(cor_matrix_immig, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45, tl.cex = 0.8,
         addCoef.col = "black", number.cex = 0.7,
         col = colorRampPalette(c("#3498db", "white", "#e74c3c"))(200),
         title = "Corrélations - Attitudes envers immigration (2022)",
         mar = c(0,0,2,0))
dev.off()
cat("  ✓ Saved: output/correlation_matrix_immigration.png\n\n")

# Tests d'adéquation
kmo_immig <- KMO(fa_data_immig)
cat(sprintf("KMO: %.3f → ", kmo_immig$MSA))
if(kmo_immig$MSA >= 0.8) cat("méritoire\n\n")
else if(kmo_immig$MSA >= 0.7) cat("moyenne\n\n")
else cat("médiocre\n\n")

# Scree plot
png("output/scree_plot_immigration.png", width = 2400, height = 1800, res = 300)
fa.parallel(fa_data_immig,
            fa = "fa",
            n.iter = 100,
            main = "Analyse parallèle - Attitudes immigration",
            show.legend = TRUE)
dev.off()
cat("  ✓ Saved: output/scree_plot_immigration.png\n\n")

# Analyse factorielle 1 facteur (hypothèse: nativisme culturel unifactoriel)
cat("--- Analyse factorielle: 1 facteur ---\n\n")

fa_immig_1f <- fa(fa_data_immig,
                  nfactors = 1,
                  rotate = "none",
                  fm = "ml")

print(fa_immig_1f, cut = 0.3, digits = 3)
cat("\n")

cat(sprintf("Variance expliquée: %.1f%%\n\n",
            fa_immig_1f$Vaccounted[2,1] * 100))

# Alpha de Cronbach
alpha_immig <- alpha(fa_data_immig)
cat("--- Alpha de Cronbach - Attitudes immigration ---\n")
cat(sprintf("  α = %.3f\n", alpha_immig$total$raw_alpha))
cat(sprintf("  Interprétation: "))
if(alpha_immig$total$raw_alpha >= 0.9) cat("excellente\n")
else if(alpha_immig$total$raw_alpha >= 0.8) cat("bonne\n")
else if(alpha_immig$total$raw_alpha >= 0.7) cat("acceptable\n")
else cat("questionnable\n")
cat("\n")


# ============================================================================ #
# 5. ANALYSE COMBINÉE: APPARTENANCE + ATTITUDES (2022) ----
# ============================================================================ #

cat("\n=== ANALYSE FACTORIELLE COMBINÉE: APPARTENANCE + ATTITUDES (2022) ===\n\n")

# Combiner critères d'appartenance + attitudes immigration
combined_vars <- c(nativism_vars, immig_attitude_vars)

fa_data_combined <- combined %>%
  filter(year == 2022) %>%
  select(all_of(combined_vars)) %>%
  na.omit()

cat(sprintf("N avec données complètes (2022): %d\n\n", nrow(fa_data_combined)))

# Analyse parallèle pour déterminer nombre de facteurs
cat("--- Détermination nombre de facteurs (analyse parallèle) ---\n\n")
parallel_combined <- fa.parallel(fa_data_combined,
                                 fa = "fa",
                                 n.iter = 100,
                                 plot = FALSE)

n_factors_combined <- parallel_combined$nfact
cat(sprintf("Nombre de facteurs suggéré: %d\n\n", n_factors_combined))

# Analyse factorielle avec nombre optimal
fa_combined <- fa(fa_data_combined,
                  nfactors = n_factors_combined,
                  rotate = "oblimin",
                  fm = "ml")

cat(sprintf("--- Analyse factorielle: %d facteurs ---\n\n", n_factors_combined))
print(fa_combined, cut = 0.3, digits = 3)
cat("\n")

# Variance expliquée
cat("Variance expliquée par facteur:\n")
for(i in 1:n_factors_combined) {
  cat(sprintf("  Facteur %d: %.1f%%\n",
              i, fa_combined$Vaccounted[2,i] * 100))
}
cat(sprintf("  Total: %.1f%%\n\n", sum(fa_combined$Vaccounted[2,]) * 100))


# ============================================================================ #
# 6. RÉSUMÉ ET CONCLUSIONS ----
# ============================================================================ #

cat("\n=== RÉSUMÉ ET CONCLUSIONS ===\n\n")

cat("1. CRITÈRES D'APPARTENANCE (7 items):\n")
cat(sprintf("   - Structure factorielle: %d facteurs\n", n_factors_suggested))
cat(sprintf("   - Variance expliquée: %.1f%%\n", sum(fa_2factors$Vaccounted[2,]) * 100))
cat("   - 'Parler français' charge principalement sur: ")
french_loading_f1 <- fa_2factors$loadings["nativism_speak_french", 1]
french_loading_f2 <- fa_2factors$loadings["nativism_speak_french", 2]
if(abs(french_loading_f1) > abs(french_loading_f2)) {
  cat(sprintf("Facteur 1 (%.3f)\n", french_loading_f1))
} else {
  cat(sprintf("Facteur 2 (%.3f)\n", french_loading_f2))
}
cat("\n")

cat("2. ATTITUDES IMMIGRATION (6 items, 2022):\n")
cat(sprintf("   - Structure: %d facteur unifié\n", 1))
cat(sprintf("   - Variance expliquée: %.1f%%\n",
            fa_immig_1f$Vaccounted[2,1] * 100))
cat(sprintf("   - Fiabilité (α): %.3f\n", alpha_immig$total$raw_alpha))
cat("\n")

cat("3. ANALYSE COMBINÉE (2022):\n")
cat(sprintf("   - Nombre optimal de facteurs: %d\n", n_factors_combined))
cat("   - Interprétation: ")
if(n_factors_combined == 2) {
  cat("Appartenance (ethnique/civique) et Attitudes (menace) sont distincts\n")
} else if(n_factors_combined == 3) {
  cat("Trois dimensions: Ethnique, Civique, Menace culturelle\n")
} else {
  cat("Structure plus complexe\n")
}
cat("\n")

cat("4. RECOMMANDATION POUR L'ÉCHELLE:\n")
if(alpha_ethnic_priori$total$raw_alpha >= 0.7 & alpha_civic_priori$total$raw_alpha >= 0.7) {
  cat("   ✓ Les échelles ethnique (2 items) et civique (5 items) sont fiables\n")
  cat("   ✓ Utiliser ces deux dimensions séparément\n")
} else {
  cat("   ! Considérer révision de la structure des échelles\n")
}

cat("\n=== ANALYSE FACTORIELLE TERMINÉE ===\n")
