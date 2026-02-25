#!/bin/bash

#Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m' 
NC='\033[0m'


#3.1 - Date saving (Epoch time) 
START_TIME=$(date +%s)

#clear screen & show intro
function INTRO () 
{
    clear
    echo -e "${BLUE}===     PROJECT: ANALYZER (NX212)        ===${NC}"
}


#1.1 - checking if root
function ROOT_CHECKING ()
{ 
    
    if [[ $(id -u) -ne 0  ]]; then
        echo -e "${RED}Error: This script must be run as root.${NC}" 
        exit 1
    fi
}


#1.2 - input file & checking if exist
function INPUT_FILE ()
{
    read -p "Please insert the full path of the Image: " IMAGE_FILE
    
    #if the file is not to be found keep asking
    while [ ! -f "$IMAGE_FILE" ]; do
        echo -e "${RED}Error:File '$IMAGE_FILE' not found. Please try again.${NC}"
        read -p "Please insert the full path of the Image: " IMAGE_FILE
    done
    
    #file exists
    echo -e "${GREEN}File exists...${NC}"
    sleep 1
}


#1.3 - installing missing tools
function INSTALL_TOOLS ()
{
    echo "Checking if carving tools are installed..."
    echo "Checking if carving tools are installed...">> "$REPORT_FILE"
    sleep 1
    
    #list of tool - for loop
    TOOLS="binwalk foremost bulk_extractor strings" 
    
    #and installing tools that are missing   
    for tool in $TOOLS
    do   
        if command -v $tool > /dev/null 2>&1
        then
            echo " $tool is already installed"
            echo " $tool is already installed" >> "$REPORT_FILE" 
        else
            echo "$tool is not installed, installing..."
            echo "$tool is not installed, installing..." >> "$REPORT_FILE"
          
            PACKAGE_NAME=""
            case $tool in
                "strings")
                    PACKAGE_NAME="binutils"
                    ;;
                "bulk_extractor")
                    PACKAGE_NAME="bulk-extractor"
                    ;;
                *)
                    PACKAGE_NAME=$tool
                    ;;
            esac
            
            apt-get update > /dev/null 2>&1
            apt-get install -y $PACKAGE_NAME > /dev/null 2>&1
            
            echo "$tool installed successfully"
            echo "$tool installed successfully" >> "$REPORT_FILE" # <-- הוספנו
        fi
    done
}


#1.5- creating a directory to save Data & report file
function MK_DIR ()
{ 
BASENAME=$(basename "$IMAGE_FILE" .img)   #keeps the file name, without the path
RESULTS_DIR="${BASENAME}_analysis_$(date +%Y%m%d_%H%M%S)" #making sure not to over write by saving with date(YEARMONTHDAY_HOURMINUTESSECONDS)
mkdir -p "$RESULTS_DIR"
echo "All the Data will be saved in: $RESULTS_DIR"

#3.2 - creat a report file
REPORT_FILE="$RESULTS_DIR/report.txt"
echo "Analysis report------" > "$REPORT_FILE"
echo "Analysis started: $(date)" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"
}


# 1.4, 1.6, 1.7 - Carving & String
function CARVERS {
    echo "---  Section 1: Data Carving & Extraction  ---"
    echo "---  Section 1: Data Carving & Extraction  ---" >> "$REPORT_FILE"
    
    # Foremost
    echo "Running Foremost..."
    echo "Running Foremost..." >> "$REPORT_FILE"
    mkdir -p "$RESULTS_DIR/foremost"
    # Saving tool output to a log file instead of showing on screen
    foremost -i "$IMAGE_FILE" -o "$RESULTS_DIR/foremost" > "$RESULTS_DIR/foremost_log.txt" 2>&1
    chmod -R 777 "$RESULTS_DIR/foremost"
    echo "Foremost results saved to: $RESULTS_DIR/foremost"
    echo "Foremost results saved to: $RESULTS_DIR/foremost" >> "$REPORT_FILE"

    # Binwalk
    echo "Running Binwalk..."
    echo "Running Binwalk..." >> "$REPORT_FILE"
    
    #Define variables for paths
    BINWALK_RESULTS_DIR="$RESULTS_DIR/binwalk"
    BINWALK_LOG_FILE="$RESULTS_DIR/binwalk_log.txt" # We create the log outside first
    
    #Create results directory
    mkdir -p "$BINWALK_RESULTS_DIR"
   
    # -e is --extract, -C is --directory
    # -f writes the log to the specified file
    binwalk -e -C "$BINWALK_RESULTS_DIR" --run-as=root "$IMAGE_FILE" -f "$BINWALK_LOG_FILE" > /dev/null 2>&1
    
    #Move the log file into the results directory
    mv "$BINWALK_LOG_FILE" "$BINWALK_RESULTS_DIR/"
    
    echo "Binwalk results saved to: $BINWALK_RESULTS_DIR"
    echo "Binwalk results saved to: $BINWALK_RESULTS_DIR" >> "$REPORT_FILE"
   
   
   
   

    # 1.6 , 1.7 - Bulk Extractor 
    echo "Running Bulk Extractor..."
    echo "Running Bulk Extractor..." >> "$REPORT_FILE"
    mkdir -p "$RESULTS_DIR/bulk_extractor"
    bulk_extractor -o "$RESULTS_DIR/bulk_extractor" "$IMAGE_FILE" > "$RESULTS_DIR/bulk_extractor_log.txt" 2>&1
    echo "Bulk Extractor results saved to:$RESULTS_DIR/bulk_extractor"
    echo "Bulk Extractor results saved to:$RESULTS_DIR/bulk_extractor" >> "$REPORT_FILE"

    # 1.6 - Checking for network traffic
    echo "Checking for extracted network traffic..."
    echo "Checking for extracted network traffic..." >> "$REPORT_FILE"
    
    PCAP_FILE="$RESULTS_DIR/bulk_extractor/packets.pcap"
    
    if [ -f "$PCAP_FILE" ]; then
        PCAP_SIZE=$(du -h "$PCAP_FILE" | awk '{print $1}')
        MESSAGE="[*] Found Pcap file: $PCAP_FILE (Size: $PCAP_SIZE)"
        echo -e "${GREEN}${MESSAGE}${NC}"
        echo "$MESSAGE" >> "$REPORT_FILE"
    else
        MESSAGE="[-] No pcap file found by Bulk Extractor."
        echo "$MESSAGE"
        echo "$MESSAGE" >> "$REPORT_FILE"
    fi
    
    # 1.7 - Extracting strings
    echo "Running Strings..."
    echo "Running Strings..." >> "$REPORT_FILE"
    mkdir -p "$RESULTS_DIR/strings"
    
    # strings to all file
    ALL_STRINGS_FILE="$RESULTS_DIR/strings/all_strings.txt"
    strings "$IMAGE_FILE" > "$ALL_STRINGS_FILE"
    
    # Searching for interesting strings
    echo "Searching for interesting strings (passwords, users...)"
    echo "Searching for interesting strings..." >> "$REPORT_FILE"
    
    INTERESTING_STRINGS_FILE="$RESULTS_DIR/strings/interesting_strings.txt"
    grep -iE '(password|pass|username|user|login|secret|key|admin)' "$ALL_STRINGS_FILE" > "$INTERESTING_STRINGS_FILE"
    echo "Potential interesting strings saved to: $INTERESTING_STRINGS_FILE"
    echo "Potential interesting strings saved to: $INTERESTING_STRINGS_FILE" >> "$REPORT_FILE"
}


# 2 - Volatility Memory Analysis
function RUN_VOL {
    echo
    echo "---  Section 2: Volatility Memory Analysis  ---"
    echo "---  Section 2: Volatility Memory Analysis  ---" >> "$REPORT_FILE"
    
    
    echo "Attempting to identify memory profile..."
    echo "Attempting to identify memory profile..." >> "$REPORT_FILE"
    
    # 2.1 & 2.2 - Get profile and save output
    IMAGE_INFO_OUTPUT=$(./vol -f "$IMAGE_FILE" imageinfo 2>&1)
    echo "$IMAGE_INFO_OUTPUT" > "$RESULTS_DIR/vol_imageinfo.txt"
    
    #suggested profile
    MEM_PROFILE=$(echo "$IMAGE_INFO_OUTPUT" | grep 'Suggested Profile(s)' | awk -F ":" '{print $2}' | awk '{print $1}' | sed 's/,//g')
    
    
    #if (MEM_PROFILE is -z = zero)
    if [ -z "$MEM_PROFILE" ]; then
        echo -e "${RED}Error:Could not determine Volatility profile.${NC}"
        echo "Error: Could not determine Volatility profile. Check vol_imageinfo.txt for details." >> "$REPORT_FILE"
        return  #stops the function and moves on - to next function.
    else
        echo -e "${GREEN}[*] Success! Profile identified:$MEM_PROFILE${NC}"
        echo "[*] Success! Profile identified: $MEM_PROFILE" >> "$REPORT_FILE"
    fi

    #Running Volatility Plugins Loop
    # 2.3, 2.4, 2.5 - List of plugins to run (as requested)
    PLUGINS="pstree pslist psscan connscan netscan hivelist consoles hivedump"
    
    echo "Starting to run Volatility plugins..."
    echo "Starting to run Volatility plugins..." >> "$REPORT_FILE"

    # Loop through the list
    for plug in $PLUGINS; do
        
        echo "--- Running Plugin: $plug ---"
        echo "--- Running Plugin: $plug ---" >> "$REPORT_FILE"

        # The 'hivedump' plugin (dumpregistry) is special
        # It needs to save to a directory (-D) not a file
        if [ "$plug" == "hivedump" ]; then
        
            echo "Attempting to dump registry hives (this may take time)..."
            echo "Attempting to dump registry hives..." >> "$REPORT_FILE"
            
            # Create a special directory for the hives
            mkdir -p "$RESULTS_DIR/registry_hives"
            
            # Run the dumpregistry command
            ./vol -f "$IMAGE_FILE" --profile="$MEM_PROFILE" dumpregistry -D "$RESULTS_DIR/registry_hives" > "$RESULTS_DIR/vol_dumpregistry_log.txt" 2>&1
            
            echo "Registry hives saved to: $RESULTS_DIR/registry_hives"
            echo "Registry hives saved to: $RESULTS_DIR/registry_hives" >> "$REPORT_FILE"
        
        else
            # All other plugins just save their text output to a file
            OUTPUT_FILE="$RESULTS_DIR/vol_$plug.txt"
            
            ./vol -f "$IMAGE_FILE" --profile="$MEM_PROFILE" "$plug" > "$OUTPUT_FILE" 2>&1
            
            echo "$plug results saved to: $OUTPUT_FILE"
            echo "$plug results saved to: $OUTPUT_FILE" >> "$REPORT_FILE"
        fi
        
        sleep 1
    done
    
    echo -e "${GREEN}All plugins finished.${NC}"
    echo "All plugins finished." >> "$REPORT_FILE"
    
    echo "--- Analysis Complete ---"
    echo "--- Analysis Complete ---" >> "$REPORT_FILE"
}


# 3 - Final report and zip
function FINALIZE_REPORT {
    echo
    echo "--- [ Section 3: Final Results & Zipping ] ---"
    echo "--- [ Section 3: Final Results & Zipping ] ---" >> "$REPORT_FILE"
    
    # 3.1 - Statistics
    END_TIME=$(date +%s)
    ANALYSIS_TIME=$((END_TIME - START_TIME))
    
    echo "Total analysis time: $ANALYSIS_TIME seconds."
    echo "Total analysis time: $ANALYSIS_TIME seconds." >> "$REPORT_FILE"
    
    # Count files
    FOUND_FILES=$(find "$RESULTS_DIR" -type f | wc -l)
    echo "Total files found/created (including logs): $FOUND_FILES"
    echo "Total files found/created (including logs): $FOUND_FILES" >> "$REPORT_FILE"
    
    echo "Main report file located at: $REPORT_FILE"
    echo "Main report file located at: $REPORT_FILE" >> "$REPORT_FILE"
    
    # 3.3 - Zip results
    echo "Zipping all result files..."
    ZIP_FILE="${RESULTS_DIR}.zip"
    
    # Run zip from inside the folder to get clean paths
    (cd "$RESULTS_DIR" && zip -r "../$ZIP_FILE" ./*) > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[*] Success! All results zipped to: $ZIP_FILE${NC}"
        echo "[*] Success! All results zipped to: $ZIP_FILE" >> "$REPORT_FILE"
    else
        echo -e "${RED}Error: Failed to create zip file.${NC}"
        echo "Error: Failed to create zip file." >> "$REPORT_FILE"
    fi
    
    echo "--- Analysis Complete ---"
    echo "--- Analysis Complete ---" >> "$REPORT_FILE"
}


#Execution Block 
ROOT_CHECKING
INTRO
INPUT_FILE
MK_DIR
INSTALL_TOOLS
CARVERS
RUN_VOL
FINALIZE_REPORT
