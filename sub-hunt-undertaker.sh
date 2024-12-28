#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check if a tool is installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${GREEN}$1 is not installed. Installing...${NC}"
        go get -u $2
    else
        echo -e "${GREEN}$1 is already installed.${NC}"
    fi
}

# Check and install required tools
check_tool subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder
check_tool assetfinder github.com/tomnomnom/assetfinder
check_tool amass github.com/OWASP/Amass/v3/...
check_tool findomain github.com/Edu4rdSHL/findomain
check_tool httprobe github.com/tomnomnom/httprobe

# Function for subdomain enumeration
enumerate_subdomains() {
    local domain=$1
    echo -e "${GREEN}Enumerating subdomains for $domain...${NC}"

    # Subfinder
    subfinder -d $domain -o subfinder.txt

    # Assetfinder
    assetfinder --subs-only $domain > assetfinder.txt

    # Amass
    amass enum -d $domain -o amass.txt

    # Findomain
    findomain -t $domain -u findomain.txt

    # Combine results
    cat subfinder.txt assetfinder.txt amass.txt findomain.txt | sort -u > all_subdomains.txt

    echo -e "${GREEN}Subdomain enumeration completed. Results saved to all_subdomains.txt${NC}"
}

# Function for enhanced subdomain hunting
enhanced_sub_hunting() {
    local domain=$1
    echo -e "${GREEN}Enhanced subdomain hunting for $domain...${NC}"

    # Probe for working HTTP and HTTPS subdomains
    cat all_subdomains.txt | httprobe > live_subdomains.txt

    echo -e "${GREEN}Enhanced subdomain hunting completed. Live subdomains saved to live_subdomains.txt${NC}"
}

# Main function
main() {
    if [ -z "$1" ]; then
        echo "Usage: $0 <domain>"
        exit 1
    fi

    local domain=$1
    enumerate_subdomains $domain
    enhanced_sub_hunting $domain
}

# Run the main function
main $1
