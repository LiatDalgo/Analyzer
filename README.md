Windows Forensics: Project ANALYZER (NX212)
Overview

Computer investigations rely on the ability to extract information efficiently. This project is an automated forensics tool designed to extract and analyze data from Windows memory dumps and HDD images. By using automation, this script reduces human error and speeds up the extraction of critical evidence during the triage phase.
Key Features

    Automated Environment Setup: Automatically identifies and installs missing forensic tools (Foremost, Binwalk, Bulk Extractor, Volatility).

    Advanced Data Carving: Orchestrates multiple engines to recover deleted files and hidden data structures from HDD images.

    Memory Forensics: Leverages the Volatility Framework to analyze RAM dumps, extracting:

        Active processes and network connections.

        Registry hives and console history.

    Network Intelligence: Automatically detects and reports the presence, size, and location of network traffic (PCAP files).

    Sensitive Info Extraction: Scans for human-readable patterns such as passwords, usernames, and executable files.

    Final Reporting: Generates a statistical summary, a detailed analysis report, and packages all findings into a secure ZIP file.

Tools Used

    Languages: Bash Scripting (Automation).

    Forensics Tools: Volatility, Bulk Extractor, Binwalk, Foremost, Strings.

    Platform: Linux-based forensics environment (Kali/Ubuntu).

How to Run

    # Make the script executable
    chmod +x win-forensics-analyzer.sh

    # Run the analyzer as root
    sudo ./win-forensics-analyzer.sh
