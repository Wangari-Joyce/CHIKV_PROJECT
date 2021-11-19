#!/usr/bin/bash

# Retrieve Kenyan se quence data from GenBank
# Create a list of accession numbers 
echo -e MH423{797..811}"\n" | sed 's/ //g' > mandera_chikv.txt 

# Install edirect utilities
sh -c "$(wget -q ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh -O -)"

# Export PATH with the following command prompt

echo "export PATH=\$PATH:\$HOME/edirect" >> $HOME/.bash_profile

# Loop through accession list using edirect fuctionality
# retrive sequences 
for i in $(cat mandera_chikv.txt)
do
esearch -db nucleotide -query $i | efetch -format fasta >> chikv_combined_seqs.fasta
done

# Retrieve global sequence data from GenBank 
# with pre-generated accession list

for i in $(cat clean_accession_list.txt)
do
esearch -db nucleotide -query $i | efetch -format fasta >> refence_dataset.fasta
done

# Single our sequences with dates on the identifiers
# statrting with the '19..' sequences followed by '20..'

grep ">" all_chikv_genome.fasta | grep -w "[1][9][0-9][0-9]," | head -n 6  > 19s_identifiers.txt

grep ">" all_chikv_genome.fasta | grep -w "[2][0][0-9][0-9]"  > 20s_identifiers.txt

# Create a combined accession list
cut -f 1 19s_identifiers.txt > Accessions.txt
cut -f 1 20s_identifiers.txt >> Accessions.txt

# Retrieve filtered sequences
# use paccession list generated above
for i in $(cat Accessions.txt)
do
esearch -db nucleotide -query $i | efetch -format fasta >> dataset1.fasta
done

# Multiple alignment using MAFFT
mafft  --auto --phylipout --reorder dataset1.fasta > aligned_dataset1.fasta

# Run TempEst 
# Download TempEst executables
wget http://tree.bio.ed.ac.uk/download.html?name=tempest&id=102&num=3

# move 
