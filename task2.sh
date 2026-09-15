#!/bin/bash

REPORT_FILE="pipeline_report.txt"
LOG_FILE="pipeline.log"
BACKUP_DIR="backup"

> "$REPORT_FILE"
> "$LOG_FILE"

# 1. Function
process_sample() {
    local file="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: Processing file $file" >> "$LOG_FILE"

    if grep -Eiq "^>|^[ATCGNatcgn]+$" "$file"; then
        echo "✅ FASTA/Nucleotide sequence found in: $file" >> "$REPORT_FILE"
        grep -Ei "^>|^[ATCGNatcgn]+$" "$file" >> "$REPORT_FILE"
        echo "------------------------" >> "$REPORT_FILE"
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: Sequence found in $file" >> "$LOG_FILE"
    else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: No FASTA/Nucleotide sequence found in $file" >> "$LOG_FILE"
    fi
}

# 3. Arguments
# هنا هنطلب الـ Argument الأول بس (اسم الفولدر)
if [ "$#" -ne 1 ]; then
    echo "Error: Missing directory argument."
    echo "Usage: $0 <directory_name>"
    exit 1 
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist." 2>> "$LOG_FILE"
    exit 1
fi

# ==========================================
# هنا الإضافة الجديدة: عرض قائمة خيارات بالأرقام
# ==========================================
echo "-----------------------------------"
echo "Select an operation to perform:"
echo "1) Scan files for FASTA/Nucleotide sequences"
echo "2) Show Help"
echo "3) Exit"
echo "-----------------------------------"

# أمر read بيخلي السكريبت يقف ويستنى المستخدم يكتب رقم، ويخزنه في المتغير OPERATION
read -p "Enter your choice (1, 2, or 3): " OPERATION

# 4. Case
# دلوقتي الـ case بتتشيك على الرقم اللي المستخدم كتبه
case "$OPERATION" in
    1)
        echo "Starting scan..."
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: Starting pipeline in: $TARGET_DIR" >> "$LOG_FILE"
        
        # 5. For loop
        for txt_file in "$TARGET_DIR"/*.txt; do
            if [ -f "$txt_file" ]; then
                process_sample "$txt_file" 
            fi
        done

        # 6. Backup
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: Creating backup..." >> "$LOG_FILE"
        mkdir -p "$BACKUP_DIR"
        
        if cp "$TARGET_DIR"/*.txt "$BACKUP_DIR/" 2>> "$LOG_FILE"; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: Backup created in /$BACKUP_DIR" >> "$LOG_FILE"
            echo "🎉 Pipeline finished successfully!"
            echo "Check '$REPORT_FILE' and '$LOG_FILE'."
            exit 0
        else
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: Backup failed." >> "$LOG_FILE"
            echo "❌ Error during backup. Check log."
            exit 1
        fi
        ;;
        
    2)
        echo "================ HELP ================"
        echo "This script scans a directory for files containing"
        echo "DNA/RNA sequences or FASTA headers."
        echo "Usage: ./script.sh <directory_name>"
        echo "======================================"
        exit 0
        ;;
        
    3)
        echo "Exiting pipeline..."
        exit 0
        ;;
        
    *)
        # لو المستخدم كتب أي رقم غير 1 و 2 و 3
        echo "Error: Invalid option."
        exit 1
        ;;
esac
