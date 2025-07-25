#!/bin/bash

#=== ZALOHOVANI
# Timestamp a vychozi cilova slozka
# upravit umistneni kvuli zacykleni 
BACKUP_DIR=~/linux_backup_$(date +%Y%m%d_%H%M)
mkdir -p "$BACKUP_DIR"

echo "Spoustim zalohu do: $BACKUP_DIR"

# 1. Zaloha /home bez /home/.cache
echo "Zalohuji /home "
rsync -a --progress --exclude='.cache' --exclude=$BACKUP_DIR ~ "$BACKUP_DIR/home"
: '
# 2. Zaloha seznamu balicku
if command -v dpkg &> /dev/null; then
    echo "Debian/Ubuntu typ OS : ukladam seznam balicku "
    dpkg --get-selections > "$BACKUP_DIR/package-list-dpkg.txt"
elif command -v pacman &> /dev/null; then
    echo "Arch/Manjaro typ OS : ukladam sezxnam balicku "
    pacman -Qqe > "$BACKUP_DIR/package-list-pacman.txt"
else
    echo "neznamy spravce balicku (dpkg/pacman)!"
fi

# 3. Zaloha MATE nastavení (dconf)
if command -v dconf &> /dev/null; then
    echo "dconf nastaveni prostredi MATE "
    dconf dump /org/mate/ > "$BACKUP_DIR/dconf-mate.ini"
else
    echo "dconf nebyl nalezen – nastavení MATE nebude ulozeno!"
fi

echo "Zaloha dokoncena"
#===

#=== OBNOVENI DESKTOPU

# Nastavení
BACKUP_DIR=~/linux_backup_YYYYMMDD_HHMM  # << změň dle své zálohy!
echo "Pouzivam zalohovou slozku: $BACKUP_DIR"

# Kontrola existence složky
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Zalohova slozka nebyla nalezena. Uprav promennou BACKUP_DIR ve skriptu!"
    exit 1
fi

# 1. Obnova balíčků
if command -v dpkg &> /dev/null && [ -f "$BACKUP_DIR/package-list-dpkg.txt" ]; then
    echo "Obnovuji balicky pro Debian/Ubuntu..."
    sudo dpkg --set-selections < "$BACKUP_DIR/package-list-dpkg.txt"
    sudo apt-get update && sudo apt-get dselect-upgrade
elif command -v pacman &> /dev/null && [ -f "$BACKUP_DIR/package-list-pacman.txt" ]; then
    echo "Obnovuji balicky pro Arch/Manjaro..."
    sudo pacman -Syu --needed - < "$BACKUP_DIR/package-list-pacman.txt"
else
    echo "zadny znamy seznam balicku nebyl nalezen – preskoceno."
fi

# 2. Obnova domovského adresáře
echo "Obnovuji soubory do domovskeho adresare..."
rsync -a --progress "$BACKUP_DIR/home/" ~/

# 3. Obnova nastavení MATE
if command -v dconf &> /dev/null && [ -f "$BACKUP_DIR/dconf-mate.ini" ]; then
    echo "Obnovuji MATE nastaveni pres dconf..."
    dconf load /org/mate/ < "$BACKUP_DIR/dconf-mate.ini"
else
    echo "Soubor s MATE nastavenim nenalezen nebo chybi dconf."
fi
echo "Obnova systemu dokoncena!"
'
