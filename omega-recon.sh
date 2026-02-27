#!/bin/bash

echo "Enter domain name:"
read domain

# Create a directory for the domain
mkdir -p $domain
cd $domain || exit 1  # Exit if directory change fails

# Function to find subdomains
subdomain() {
	dig +short "$domain" >/dev/null || exit 1
    echo "----Finding subdomains----"
    subfinder -d $domain -all -recursive -o subfinder.txt &
    assetfinder --subs-only $domain > assetfinder.txt &
    findomain -t $domain | tee findomain.txt &
    wait
    echo "----merging all subdomains----"
    cat subfinder.txt assetfinder.txt findomain.txt | sort -u > subdomains.txt
    rm subfinder.txt assetfinder.txt findomain.txt
    echo "----discover alive subdomains----"
    cat subdomains.txt | httpx -ports 80,443,8080,8000,8888 -threads 200 -timeout 5 -retries 3 > livesubdomains.txt
	wait
	httpx-pd -l subdomains.txt -mc 403 > subdomains_403.txt & 
	httpx-pd -l subdomains.txt -mc 404 > subdomains_404.txt &
	wait 
	mkdir subdomains
	mv subdomains.txt livesubdomains.txt subdomains_403.txt subdomains_404.txt subdomains/
	wait
}

# Function for detecting vulnerabilities using GF patterns
gf_patterns() {
	gf_dir="${GF_PATH:-$HOME/.gf}"
	output_dir="gf"
	
	mkdir -p "$output_dir" || return 1
	
	for pattern_file in "$gf_dir"/*.json; do
	    [ -e "$pattern_file" ] || continue
	    pattern="$(basename "$pattern_file" .json)"
	    cat urls/totalurls.txt | gf "$pattern" > "$output_dir/gf_${pattern}.txt" 2>/dev/null
	    [ -s "$output_dir/gf_${pattern}.txt" ] || rm -f "$output_dir/gf_${pattern}.txt"
	done

}

# URL Collection and Analysis
url_collection_analysis() {
	mkdir urls
    timeout 60s katana -u subdomains/livesubdomains.txt -d 2 -o urls/urls.txt &
    timeout 60s gau --mc 200 $domain | urldedupe >> urls/urls.txt &
    wait
    cat urls/urls.txt | hakrawler -u >> urls/urls2.txt &
    urlfinder -d $domain | sort -u >> urls/urls2.txt 
    wait
    cat urls/urls* | sort -u > urls/allurls.txt
    rm urls/urls.txt urls/urls2.txt
    cat urls/allurls.txt | grep -E ".php|.asp|.aspx|.jspx|.jsp" | grep '=' | sort > urls/output.txt
    cat urls/output.txt | sed 's/=.*/=/' >> urls/out.txt 
    cat urls/allurls.txt | grep -E '\?[^=]+=.+$' >> urls/out.txt 
    cat urls/allurls.txt | grep '=' | urldedupe >> urls/out.txt 
    wait
    cat urls/*.txt | sort -u > urls/totalurls.txt
}

# Start functions
subdomain
url_collection_analysis
gf_patterns

echo "All tasks completed for domain: $domain"

