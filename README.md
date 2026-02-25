📖 Overview

Computer investigations rely on the ability to extract information efficiently. This project is an automated forensics tool designed to extract and analyze data from Windows memory dumps and HDD images. By using automation, this script reduces human error and speeds up the extraction of critical evidence.
⚙️ Analysis Workflow

    Validation: The script ensures root privileges and verifies the target image path.

    Environment Prep: Automated check and installation of forensics dependencies.

    Data Extraction: Execution of carving engines (Foremost, Binwalk, Bulk Extractor) to recover files.

    Memory Triage: Deep memory profile identification followed by process and network analysis using Volatility.

    Packaging: Final report generation and secure compression of all artifacts into a ZIP file.

🛠️ Tools Used

    Languages: Bash Scripting (Automation).

    Forensics Tools: Volatility, Bulk Extractor, Binwalk, Foremost, Strings.

    Platform: Linux-based forensics environment (Kali/Ubuntu).

🚀 How to Run

    # Make the script executable
    chmod +x win-forensics-analyzer.sh

    # Run the analyzer as root
    sudo ./win-forensics-analyzer.sh
