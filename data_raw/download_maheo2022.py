"""
Script pour télécharger les données de l'étude électorale québécoise 2022 (Maheo et al.)
depuis Harvard Dataverse.
Ce script utilise Selenium pour gérer les acceptations de licence et les téléchargements.

Dataset: doi:10.7910/DVN/PAQBDR
"""

import os
import time
import zipfile
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


def download_dataset(url: str, download_dir: str, slug: str, accept_terms: bool = True):
    """
    Télécharge un dataset depuis Harvard Dataverse.

    Args:
        url: URL du dataset Dataverse
        download_dir: Répertoire de destination des téléchargements
        slug: Slug pour nommer les fichiers (ex: "maheo2022")
        accept_terms: Si True, accepte automatiquement les termes de licence

    Returns:
        Liste des fichiers téléchargés
    """
    driver = setup_driver(download_dir)
    downloaded_files = []
    download_path = Path(download_dir)

    try:
        print(f"Navigation vers {url}...")
        driver.get(url)

        # Attendre que la page charge
        wait = WebDriverWait(driver, 15)

        print("Attente du chargement de la page...")
        time.sleep(0.5)

        # Trouver tous les boutons dropdown de téléchargement
        print("Recherche des fichiers à télécharger...")

        # Chercher les boutons dropdown avec l'icône de téléchargement
        dropdown_buttons = driver.find_elements(By.XPATH,
            "//button[contains(@class, 'dropdown-toggle') and .//span[contains(@class, 'glyphicon-download-alt')]]")

        if not dropdown_buttons:
            print("Aucun bouton de téléchargement trouvé. Affichage de la page pour inspection...")
            print("URL actuelle:", driver.current_url)
            driver.save_screenshot(os.path.join(download_dir, "debug_screenshot.png"))
            raise Exception("Aucun bouton de téléchargement détecté")

        print(f"Trouvé {len(dropdown_buttons)} fichier(s) à télécharger")

        for idx, dropdown_btn in enumerate(dropdown_buttons, 1):
            try:
                print(f"\n{'='*60}")
                print(f"Téléchargement du fichier {idx}/{len(dropdown_buttons)}")
                print(f"{'='*60}")

                # Lister les fichiers avant téléchargement
                files_before = set(f.name for f in download_path.glob('*') if f.is_file())

                # Scroller vers le bouton dropdown en le centrant
                driver.execute_script("arguments[0].scrollIntoView({block: 'center', behavior: 'smooth'});", dropdown_btn)
                time.sleep(0.3)

                # Cliquer sur le dropdown pour l'ouvrir
                try:
                    dropdown_btn.click()
                    print("✓ Dropdown ouvert (clic normal)")
                except Exception:
                    driver.execute_script("arguments[0].click();", dropdown_btn)
                    print("✓ Dropdown ouvert (JavaScript)")

                time.sleep(0.3)

                # Chercher les liens de téléchargement dans le dropdown ouvert
                # Il peut y avoir plusieurs formats (PDF, Stata, Tab-Delimited, etc.)
                try:
                    download_links = wait.until(
                        EC.presence_of_all_elements_located((By.XPATH,
                            "//a[contains(@class, 'btn-download') and contains(@class, 'ui-commandlink')]"))
                    )

                    print(f"Trouvé {len(download_links)} format(s) disponible(s):")
                    for link in download_links:
                        print(f"  - {link.text.strip()}")

                    # Choisir le bon format
                    # Pour les données: préférer "Stata 14 Binary" ou "Tab-Delimited"
                    # Pour le codebook: "Adobe PDF"
                    download_link = None
                    for link in download_links:
                        link_text = link.text.strip()
                        if "Stata" in link_text or "Tab-Delimited" in link_text:
                            download_link = link
                            print(f"Sélection: {link_text} (données)")
                            break
                        elif "Adobe PDF" in link_text or "PDF" in link_text:
                            download_link = link
                            print(f"Sélection: {link_text} (codebook)")
                            break

                    if not download_link:
                        # Par défaut, prendre le premier
                        download_link = download_links[0]
                        print(f"Sélection par défaut: {download_link.text.strip()}")

                    # Cliquer sur le lien de téléchargement
                    try:
                        download_link.click()
                        print("✓ Clic sur le lien de téléchargement (normal)")
                    except Exception:
                        driver.execute_script("arguments[0].click();", download_link)
                        print("✓ Clic sur le lien de téléchargement (JavaScript)")

                    print("Attente de la modale d'acceptation...")
                    time.sleep(0.5)

                except TimeoutException:
                    print("✗ Lien de téléchargement non trouvé dans le dropdown")
                    driver.save_screenshot(os.path.join(download_dir, f"dropdown_error_{idx}.png"))
                    continue

                # Gérer l'acceptation des termes
                if accept_terms:
                    try:
                        # Chercher la checkbox "I accept the Terms of Use" (si elle existe)
                        try:
                            checkbox = wait.until(
                                EC.presence_of_element_located((By.XPATH,
                                    "//input[@type='checkbox']"))
                            )
                            if not checkbox.is_selected():
                                # Parfois il faut cliquer sur le label plutôt que la checkbox directement
                                try:
                                    checkbox.click()
                                except:
                                    # Essayer de cliquer via JavaScript
                                    driver.execute_script("arguments[0].click();", checkbox)
                                print("✓ Checkbox des termes cochée")
                                time.sleep(0.3)
                        except TimeoutException:
                            print("ℹ Pas de checkbox à cocher")

                        # Chercher le bouton "Accept"
                        # Le bouton PrimeFaces a la classe ui-button et contient un span avec "Accept"
                        confirm_selectors = [
                            "//button[contains(@class, 'ui-button') and .//span[contains(text(), 'Accept')]]",
                            "//button[@type='submit' and contains(., 'Accept')]",
                            "//button[contains(@class, 'btn') and contains(., 'Download')]",
                            "//button[contains(@class, 'btn') and contains(., 'Continue')]",
                        ]

                        confirm_button = None
                        for selector in confirm_selectors:
                            try:
                                confirm_button = wait.until(
                                    EC.element_to_be_clickable((By.XPATH, selector))
                                )
                                print(f"✓ Bouton trouvé: {confirm_button.text.strip()}")
                                break
                            except TimeoutException:
                                continue

                        if confirm_button:
                            try:
                                confirm_button.click()
                                print("✓ Téléchargement confirmé (clic normal)")
                            except:
                                driver.execute_script("arguments[0].click();", confirm_button)
                                print("✓ Téléchargement confirmé (JavaScript)")
                            time.sleep(0.5)
                        else:
                            print("⚠ Bouton de confirmation non trouvé")
                            driver.save_screenshot(os.path.join(download_dir, f"no_confirm_button_{idx}.png"))

                    except TimeoutException:
                        print("⚠ Pas de modale de termes détectée")
                    except Exception as e:
                        print(f"⚠ Erreur lors de l'acceptation des termes: {str(e)}")
                        driver.save_screenshot(os.path.join(download_dir, f"accept_error_{idx}.png"))

                # Attendre que le téléchargement se termine
                print("Attente de la fin du téléchargement...")
                new_files = wait_for_download_completion(download_path, files_before, timeout=60)

                if new_files:
                    for new_file_name in new_files:
                        old_path = download_path / new_file_name
                        extension = old_path.suffix
                        file_lower = new_file_name.lower()

                        # Déterminer le nouveau nom selon le type de fichier
                        if "codebook" in file_lower or extension.lower() == ".pdf":
                            new_name = f"{slug}_codebook{extension}"
                        elif any(ext in extension.lower() for ext in [".tab", ".dta", ".sav", ".csv", ".xlsx"]):
                            new_name = f"{slug}_data{extension}"
                        else:
                            # Par défaut, ajouter le préfixe slug
                            new_name = f"{slug}_{new_file_name}"

                        new_path = download_path / new_name

                        # Renommer le fichier
                        if new_path.exists():
                            print(f"⚠ Le fichier {new_name} existe déjà, renommage ignoré")
                        elif old_path == new_path:
                            downloaded_files.append(new_name)
                            print(f"✓ Fichier déjà nommé correctement: {new_name}")
                        else:
                            old_path.rename(new_path)
                            downloaded_files.append(new_name)
                            print(f"✓ Renommé: {new_file_name} → {new_name}")
                else:
                    print("⚠ Aucun nouveau fichier détecté après téléchargement")

                print(f"✓ Fichier {idx} traité avec succès")

            except Exception as e:
                print(f"✗ Erreur lors du téléchargement du fichier {idx}: {str(e)}")
                driver.save_screenshot(os.path.join(download_dir, f"error_file_{idx}.png"))
                continue

        # Attendre que tous les téléchargements se terminent
        print("\n" + "="*60)
        print("Attente de la fin de tous les téléchargements...")
        print("="*60)
        time.sleep(2)

        return downloaded_files

    except Exception as e:
        print(f"Erreur: {str(e)}")
        raise

    finally:
        driver.quit()


def convert_pdf_to_markdown(pdf_path: Path, output_dir: Path = None):
    """
    Convertit un fichier PDF en markdown en utilisant pdftotext.
    Le fichier PDF original est conservé.

    Args:
        pdf_path: Chemin du fichier PDF à convertir
        output_dir: Répertoire de sortie (par défaut, même répertoire que le fichier source)

    Returns:
        Path du fichier markdown créé, ou None si échec
    """
    if not pdf_path.exists():
        print(f"✗ Fichier source non trouvé: {pdf_path}")
        return None

    if output_dir is None:
        output_dir = pdf_path.parent

    print(f"\nConversion de {pdf_path.name} en markdown...")

    md_path = output_dir / (pdf_path.stem + '.md')

    try:
        # Utiliser pdftotext pour extraire le texte du PDF
        result = subprocess.run(
            [
                'pdftotext',
                '-layout',  # Préserver la mise en page
                str(pdf_path),
                '-'  # Sortir vers stdout
            ],
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode == 0:
            # Écrire le texte dans un fichier markdown
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(result.stdout)

            print(f"✓ Conversion markdown réussie: {md_path.name}")
            print(f"  ℹ Fichier PDF original conservé: {pdf_path.name}")

            return md_path
        else:
            print(f"✗ Erreur lors de la conversion:")
            print(f"  stderr: {result.stderr}")
            return None

    except FileNotFoundError:
        print("✗ pdftotext n'est pas installé ou n'est pas dans le PATH")
        print("  Installez poppler-utils: sudo apt-get install poppler-utils")
        return None
    except subprocess.TimeoutExpired:
        print("✗ Timeout lors de la conversion (>60s)")
        return None
    except Exception as e:
        print(f"✗ Erreur lors de la conversion: {str(e)}")
        return None


def unzip_files(download_dir: str, slug: str = None):
    """
    Dézippe tous les fichiers zip dans le répertoire et renomme les fichiers extraits avec le préfixe slug.

    Args:
        download_dir: Répertoire contenant les fichiers zip
        slug: Préfixe à ajouter aux fichiers extraits (optionnel)
    """
    download_path = Path(download_dir)
    zip_files = list(download_path.glob("*.zip"))

    if not zip_files:
        print("ℹ Aucun fichier zip à extraire")
        return

    for zip_file in zip_files:
        print(f"Extraction de {zip_file.name}...")
        try:
            # Lister les fichiers avant extraction
            files_before = set(f.name for f in download_path.glob('*') if f.is_file())

            with zipfile.ZipFile(zip_file, 'r') as zip_ref:
                zip_ref.extractall(download_path)
            print(f"✓ {zip_file.name} extrait avec succès")

            # Renommer les fichiers extraits avec le préfixe slug
            if slug:
                files_after = set(f.name for f in download_path.glob('*') if f.is_file())
                new_files = files_after - files_before - {zip_file.name}

                for new_file_name in new_files:
                    old_path = download_path / new_file_name
                    extension = old_path.suffix
                    file_lower = new_file_name.lower()

                    # Déterminer le nouveau nom selon le type de fichier
                    if "codebook" in file_lower or extension.lower() == ".pdf":
                        new_name = f"{slug}_codebook{extension}"
                    elif any(ext in extension.lower() for ext in [".tab", ".dta", ".sav", ".csv", ".xlsx"]):
                        new_name = f"{slug}_data{extension}"
                    else:
                        # Par défaut, ajouter le préfixe slug
                        new_name = f"{slug}_{new_file_name}"

                    new_path = download_path / new_name

                    if new_path.exists():
                        print(f"⚠ Le fichier {new_name} existe déjà, renommage ignoré")
                    elif old_path == new_path:
                        print(f"✓ Fichier déjà nommé correctement: {new_name}")
                    else:
                        old_path.rename(new_path)
                        print(f"✓ Renommé: {new_file_name} → {new_name}")

            # Supprimer le zip après extraction
            zip_file.unlink()
            print(f"✓ {zip_file.name} supprimé")

        except Exception as e:
            print(f"✗ Erreur lors de l'extraction de {zip_file.name}: {str(e)}")


def main():
    """Fonction principale pour télécharger les données Maheo 2022."""

    # Configuration des chemins - télécharger dans data/raw/
    script_dir = Path(__file__).parent  # data_raw/
    project_root = script_dir.parent  # racine du projet
    download_dir = str(project_root / "data" / "raw")
    slug = "maheo2022"

    # Créer le répertoire s'il n'existe pas
    os.makedirs(download_dir, exist_ok=True)

    print("=" * 60)
    print(f"Téléchargement: Étude électorale québécoise 2022 (Maheo)")
    print("=" * 60)
    print(f"Répertoire de téléchargement: {download_dir}")
    print(f"Slug: {slug}\n")

    # URL du dataset - Étude électorale québécoise 2022 (Maheo et al.)
    # doi:10.7910/DVN/PAQBDR
    dataset_url = "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/PAQBDR"

    try:
        downloaded_files = download_dataset(dataset_url, download_dir, slug)

        print("\n" + "=" * 60)
        print("Extraction des fichiers zip...")
        print("=" * 60)
        unzip_files(download_dir, slug)

        # Convertir le codebook PDF en markdown
        print("\n" + "=" * 60)
        print("Conversion du codebook en markdown...")
        print("=" * 60)

        pdf_path = Path(download_dir) / f'{slug}_codebook.pdf'
        if pdf_path.exists():
            md_path = convert_pdf_to_markdown(pdf_path)
            if md_path:
                # Ajouter le fichier markdown à la liste (on garde aussi le .pdf)
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
