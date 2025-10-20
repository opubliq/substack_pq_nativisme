"""
Script pour télécharger les données de l'étude électorale québécoise 2018 (Bélanger et al.)
depuis Borealis Dataverse.
Ce script utilise Selenium pour gérer les acceptations de licence et les téléchargements.

Dataset: doi:10.5683/SP3/NWTGWS
Télécharge uniquement:
- Le codebook (MS Word)
- Les données (Stata 14 Binary)
"""

import os
import time
import subprocess
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException, NoSuchElementException


def setup_driver(download_dir: str):
    """Configure le driver Chrome avec les options de téléchargement."""
    chrome_options = Options()

    # Options pour le téléchargement automatique
    prefs = {
        "download.default_directory": download_dir,
        "download.prompt_for_download": False,
        "download.directory_upgrade": True,
        "safebrowsing.enabled": True
    }
    chrome_options.add_experimental_option("prefs", prefs)

    # Mode headless optionnel (décommenter pour exécution sans interface)
    # chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    driver = webdriver.Chrome(options=chrome_options)
    return driver


def wait_for_download_completion(download_path: Path, files_before: set, timeout: int = 60):
    """
    Attend qu'un nouveau fichier soit complètement téléchargé.

    Args:
        download_path: Chemin du dossier de téléchargement
        files_before: Set des fichiers présents avant le téléchargement
        timeout: Temps maximum d'attente en secondes

    Returns:
        Set des nouveaux fichiers téléchargés (noms uniquement)
    """
    start_time = time.time()

    while time.time() - start_time < timeout:
        # Vérifier s'il y a des fichiers en cours de téléchargement (.crdownload, .part, .tmp)
        downloading = list(download_path.glob('*.crdownload')) + \
                     list(download_path.glob('*.part')) + \
                     list(download_path.glob('*.tmp'))

        if downloading:
            # Un téléchargement est en cours
            time.sleep(0.5)
            continue

        # Vérifier s'il y a de nouveaux fichiers complètement téléchargés
        files_after = set(f.name for f in download_path.glob('*') if f.is_file())
        new_files = files_after - files_before

        # Exclure les fichiers temporaires et screenshots
        new_files = {f for f in new_files if not any(f.endswith(ext) for ext in ['.crdownload', '.part', '.tmp', '.png'])}

        if new_files:
            # Donner un petit délai supplémentaire pour s'assurer que le fichier est bien écrit
            time.sleep(0.5)
            return new_files

        time.sleep(0.5)

    # Timeout atteint
    return set()


def download_file_from_page(driver, wait, file_url: str, file_name: str, format_to_download: str):
    """
    Télécharge un fichier depuis sa page dédiée dans Dataverse.

    Args:
        driver: WebDriver Selenium
        wait: WebDriverWait object
        file_url: URL de la page du fichier
        file_name: Nom du fichier (pour logging)
        format_to_download: Format à télécharger (ex: "MS Word", "Format binaire Stata 14")
    """
    print(f"\n{'='*60}")
    print(f"Téléchargement de: {file_name}")
    print(f"{'='*60}")

    # Naviguer vers la page du fichier
    print(f"Navigation vers {file_url}...")
    driver.get(file_url)
    time.sleep(0.5)

    # Trouver et cliquer sur le dropdown "Conditions d'accès au fichier"
    try:
        dropdown_btn = wait.until(
            EC.presence_of_element_located((By.XPATH,
                "//button[contains(@class, 'btn-access-file') and contains(@class, 'dropdown-toggle')]"))
        )

        # Scroller vers le dropdown
        driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", dropdown_btn)
        time.sleep(0.2)

        # Cliquer sur le dropdown
        try:
            dropdown_btn.click()
            print("✓ Dropdown ouvert")
        except:
            driver.execute_script("arguments[0].click();", dropdown_btn)
            print("✓ Dropdown ouvert (JavaScript)")

        time.sleep(0.3)

        # Trouver le lien de téléchargement pour le format demandé
        download_links = driver.find_elements(By.XPATH,
            "//a[contains(@class, 'btn-download') and contains(@class, 'ui-commandlink')]")

        print(f"Formats disponibles:")
        for link in download_links:
            print(f"  - {link.text.strip()}")

        # Chercher le format demandé
        download_link = None
        for link in download_links:
            link_text = link.text.strip()
            if format_to_download in link_text:
                download_link = link
                print(f"✓ Sélection: {link_text}")
                break

        if not download_link:
            print(f"✗ Format '{format_to_download}' non trouvé")
            return False

        # Cliquer pour télécharger
        try:
            download_link.click()
            print("✓ Téléchargement lancé")
        except:
            driver.execute_script("arguments[0].click();", download_link)
            print("✓ Téléchargement lancé (JavaScript)")

        time.sleep(0.5)
        return True

    except Exception as e:
        print(f"✗ Erreur: {str(e)}")
        return False


def download_specific_files(url: str, download_dir: str, files_to_download: list):
    """
    Télécharge des fichiers spécifiques depuis Borealis Dataverse.

    Args:
        url: URL du dataset Dataverse
        download_dir: Répertoire de destination des téléchargements
        files_to_download: Liste de dict avec 'name_pattern', 'format', et 'output_name'

    Returns:
        Liste des fichiers téléchargés avec leurs nouveaux noms
    """
    driver = setup_driver(download_dir)
    downloaded_files = []

    try:
        print(f"Navigation vers {url}...")
        driver.get(url)

        wait = WebDriverWait(driver, 15)

        print("Attente du chargement de la page...")
        time.sleep(0.5)

        # Trouver tous les fichiers disponibles et stocker leurs infos
        print("Recherche des fichiers à télécharger...")

        all_file_links = driver.find_elements(By.XPATH,
            "//div[contains(@class, 'fileNameOriginal')]//a[contains(@href, 'file.xhtml')]")

        if not all_file_links:
            print("Aucun fichier trouvé.")
            driver.save_screenshot(os.path.join(download_dir, "debug_screenshot.png"))
            raise Exception("Aucun fichier détecté")

        # Stocker les infos des fichiers (nom, URL) pour éviter stale element
        file_infos = []
        for link in all_file_links:
            file_name = link.text.strip()
            file_href = link.get_attribute('href')
            if not file_href.startswith('http'):
                base_url = driver.current_url.split('/dataset.xhtml')[0]
                file_href = base_url + file_href
            file_infos.append({'name': file_name, 'url': file_href})

        print(f"Trouvé {len(file_infos)} fichier(s) disponible(s):")
        for info in file_infos:
            print(f"  - {info['name']}")

        files_downloaded = 0

        # Pour chaque fichier à télécharger
        for file_spec in files_to_download:
            name_pattern = file_spec['name_pattern']
            format_to_get = file_spec['format']
            output_name = file_spec['output_name']

            print(f"\nRecherche de '{name_pattern}'...")

            # Trouver le fichier correspondant
            file_info = None
            for info in file_infos:
                if name_pattern in info['name']:
                    file_info = info
                    break

            if not file_info:
                print(f"✗ Fichier '{name_pattern}' non trouvé")
                continue

            # Lister les fichiers avant téléchargement
            download_path = Path(download_dir)
            files_before = set(f.name for f in download_path.glob('*') if f.is_file())

            # Télécharger depuis la page du fichier
            if download_file_from_page(driver, wait, file_info['url'], file_info['name'], format_to_get):
                files_downloaded += 1

                # Attendre que le téléchargement se termine
                print("Attente de la fin du téléchargement...")
                new_files = wait_for_download_completion(download_path, files_before, timeout=60)

                if new_files:
                    # Renommer le fichier téléchargé
                    for new_file_name in new_files:
                        old_path = download_path / new_file_name
                        new_path = download_path / output_name

                        # Éviter les conflits de noms
                        if new_path.exists():
                            print(f"⚠ Le fichier {output_name} existe déjà, renommage ignoré")
                            downloaded_files.append(output_name)
                        elif old_path.exists():
                            old_path.rename(new_path)
                            print(f"✓ Renommé: {new_file_name} → {output_name}")
                            downloaded_files.append(output_name)
                        break
                else:
                    print(f"⚠ Fichier téléchargé non trouvé pour renommage")

        print(f"\n✓ {files_downloaded} fichier(s) téléchargé(s)")
        return downloaded_files

    except Exception as e:
        print(f"Erreur: {str(e)}")
        raise

    finally:
        driver.quit()


def convert_doc_to_markdown(doc_path: Path, output_dir: Path = None):
    """
    Convertit un fichier .doc en .md en utilisant antiword.
    Le fichier .doc original est conservé.

    Args:
        doc_path: Chemin du fichier .doc à convertir
        output_dir: Répertoire de sortie (par défaut, même répertoire que le fichier source)

    Returns:
        Path du fichier markdown créé, ou None si échec
    """
    if not doc_path.exists():
        print(f"✗ Fichier source non trouvé: {doc_path}")
        return None

    if output_dir is None:
        output_dir = doc_path.parent

    print(f"\nConversion de {doc_path.name} en markdown...")
    print("  Utilisation de antiword pour extraire le texte...")

    md_path = output_dir / (doc_path.stem + '.md')

    try:
        # Utiliser antiword pour extraire le texte du .doc
        result = subprocess.run(
            [
                'antiword',
                str(doc_path)
            ],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            # Écrire le texte dans un fichier markdown
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(result.stdout)

            print(f"✓ Conversion markdown réussie: {md_path.name}")
            print(f"  ℹ Fichier .doc original conservé: {doc_path.name}")

            return md_path
        else:
            print(f"✗ Erreur lors de la conversion:")
            print(f"  stderr: {result.stderr}")
            return None

    except FileNotFoundError:
        print("✗ antiword n'est pas installé ou n'est pas dans le PATH")
        print("  Installez antiword: sudo apt-get install antiword")
        return None
    except subprocess.TimeoutExpired:
        print("✗ Timeout lors de la conversion (>30s)")
        return None
    except Exception as e:
        print(f"✗ Erreur lors de la conversion: {str(e)}")
        return None


def main():
    """Fonction principale pour télécharger les données Bélanger 2018."""

    # Configuration des chemins - télécharger dans data/raw/
    script_dir = Path(__file__).parent  # data_raw/
    project_root = script_dir.parent  # racine du projet
    download_dir = str(project_root / "data" / "raw")
    slug = "belanger2018"

    # Créer le répertoire s'il n'existe pas
    os.makedirs(download_dir, exist_ok=True)

    print("=" * 60)
    print(f"Téléchargement: Étude électorale québécoise 2018 (Bélanger)")
    print("=" * 60)
    print(f"Répertoire de téléchargement: {download_dir}")
    print(f"Slug: {slug}\n")

    # URL du dataset - Étude électorale québécoise 2018 (Bélanger et al.)
    # doi:10.5683/SP3/NWTGWS
    dataset_url = "https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP3/NWTGWS"

    # Fichiers spécifiques à télécharger
    files_to_download = [
        {
            'name_pattern': 'FR.doc',  # Codebook en français: "Quebec Election Study 2018 FR.doc"
            'format': 'MS Word',
            'output_name': f'{slug}_codebook.doc'
        },
        {
            'name_pattern': '2018.tab',  # Données: "Quebec Election Study 2018.tab"
            'format': 'Stata 14 Binary',  # Le format est en anglais!
            'output_name': f'{slug}_data.dta'
        }
    ]

    try:
        downloaded_files = download_specific_files(dataset_url, download_dir, files_to_download)

        # Convertir le fichier .doc en markdown
        print("\n" + "=" * 60)
        print("Conversion du codebook en markdown...")
        print("=" * 60)

        doc_path = Path(download_dir) / f'{slug}_codebook.doc'
        if doc_path.exists():
            md_path = convert_doc_to_markdown(doc_path)
            if md_path:
                # Ajouter le fichier markdown à la liste (on garde aussi le .doc)
                downloaded_files.append(md_path.name)

        print("\n" + "=" * 60)
        print("✓ Téléchargement terminé avec succès!")
        print("=" * 60)
        print(f"Fichiers téléchargés dans {download_dir}:")

        # Lister les fichiers téléchargés
        for file_name in downloaded_files:
            file_path = Path(download_dir) / file_name
            if file_path.is_file():
                size_mb = file_path.stat().st_size / (1024 * 1024)
                print(f"  - {file_name} ({size_mb:.2f} MB)")

    except Exception as e:
        print(f"\n✗ Erreur lors du téléchargement: {str(e)}")
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
