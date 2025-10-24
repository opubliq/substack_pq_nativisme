#!/bin/bash
# Script pour télécharger toutes les données des études électorales québécoises
# Ce script exécute tous les scripts de téléchargement Python en séquence

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher un en-tête
print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Fonction pour afficher un message de succès
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Fonction pour afficher un message d'erreur
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Fonction pour afficher un message d'information
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Chemin du répertoire du script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATA_RAW_DIR="$SCRIPT_DIR/data_raw"

print_header "Téléchargement de toutes les données électorales québécoises"

# Vérifier que Python est installé
if ! command -v python3 &> /dev/null; then
    print_error "Python3 n'est pas installé"
    exit 1
fi

print_success "Python3 trouvé: $(python3 --version)"

# Vérifier que les dépendances Python sont installées
print_info "Vérification des dépendances Python..."

if ! python3 -c "import selenium" 2>/dev/null; then
    print_error "La bibliothèque Selenium n'est pas installée"
    print_info "Installez-la avec: pip install selenium"
    exit 1
fi

print_success "Dépendances Python OK"

# Vérifier que chromedriver est disponible
if ! command -v chromedriver &> /dev/null && ! command -v chromium-driver &> /dev/null; then
    print_error "ChromeDriver n'est pas installé"
    print_info "Installez-le avec: sudo apt-get install chromium-chromedriver"
    print_info "ou téléchargez-le depuis: https://chromedriver.chromium.org/"
    exit 1
fi

print_success "ChromeDriver trouvé"

# Liste des scripts à exécuter
SCRIPTS=(
    "download_maheo2022.py:Maheo et al. 2022"
    "download_belanger2018.py:Bélanger et al. 2018"
    "download_durand2018.py:Durand et al. 2018"
)

# Compteur de succès/échecs
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()

# Exécuter chaque script
for SCRIPT_INFO in "${SCRIPTS[@]}"; do
    IFS=':' read -r SCRIPT_NAME SCRIPT_DESC <<< "$SCRIPT_INFO"
    SCRIPT_PATH="$DATA_RAW_DIR/$SCRIPT_NAME"

    print_header "Téléchargement: $SCRIPT_DESC"

    if [ ! -f "$SCRIPT_PATH" ]; then
        print_error "Script non trouvé: $SCRIPT_PATH"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$SCRIPT_DESC")
        continue
    fi

    # Exécuter le script Python
    if python3 "$SCRIPT_PATH"; then
        print_success "$SCRIPT_DESC téléchargé avec succès"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        print_error "Échec du téléchargement: $SCRIPT_DESC"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$SCRIPT_DESC")
    fi

    echo ""
done

# Résumé final
print_header "Résumé du téléchargement"

echo -e "${GREEN}Succès: $SUCCESS_COUNT${NC}"
echo -e "${RED}Échecs: $FAIL_COUNT${NC}"

if [ $FAIL_COUNT -gt 0 ]; then
    echo ""
    print_error "Scripts ayant échoué:"
    for FAILED in "${FAILED_SCRIPTS[@]}"; do
        echo "  - $FAILED"
    done
fi

# Afficher les fichiers téléchargés
if [ -d "$SCRIPT_DIR/data/raw" ]; then
    echo ""
    print_header "Fichiers téléchargés dans data/raw/"
    ls -lh "$SCRIPT_DIR/data/raw" | grep -v "^total" | grep -v "^d"
fi

echo ""
if [ $FAIL_COUNT -eq 0 ]; then
    print_success "Tous les téléchargements sont terminés avec succès!"
    exit 0
else
    print_error "Certains téléchargements ont échoué"
    exit 1
fi
