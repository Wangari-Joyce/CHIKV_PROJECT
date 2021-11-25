We first retrieved the Mandera-Kenya sequences from genbank
    
    #!/usr/bin/bash
    # Retrieving Mandera sequences data from GenBank
    # Creating a list of accession numbers 
    echo -e MH423{797..811}"\n" | sed 's/ //g' > mandera_chikv.txt 
    output

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
# with pre-generated accession list from genbank

for i in $(cat clean_accession_list.txt)
do
esearch -db nucleotide -query $i | efetch -format fasta >> refence_dataset.fasta
done

# filtered our sequences with dates on the identifiers
# statrting with the '19..' sequences followed by '20..'

grep ">" all_chikv_genome.fasta | grep -w "[1][9][0-9][0-9]," | head -n 6  > 19s_identifiers.txt

grep ">" all_chikv_genome.fasta | grep -w "[2][0][0-9][0-9]"  > 20s_identifiers.txt

# Create a combined accession list
cut -f 1 19s_identifiers.txt > Accessions.txt
cut -f 1 20s_identifiers.txt >> Accessions.txt

# Retrieve filtered sequences
# use accession list generated above = 324 sequences
for i in $(cat Accessions.txt)
do
esearch -db nucleotide -query $i | efetch -format fasta >> dataset1.fasta
done

# Multiple alignment using MAFFT
mafft  --auto --phylipout --reorder dataset1.fasta > aligned_dataset1.fasta

# created a neighbour joining tree using MEGAX GUI using default parameters
#TempEst input is  tree.
#  TempEst : 
# Installing TempEst
sudo apt-get install -y tempest
#running TempEst
cd TempEst_v1.5.3/
 1138  cd bin/
 1139  ./tempest 

# from tempest we removed outliers and all sequences  without sampling location manually current n=283
#combined our dataset with the 10 mandera kenya samples n=293
cat complete_genome_10seqs_mandera_dated.fasta >> clean_reference_dataset
 
# inferring maximum likehood trees
#first installing jmodeltest to get the best substitution model
sudo apt install jmodeltest
#running
jmodeltest
#jmodeltest failed for our 293sequences
#proceeded with phyml GTR+G+I as in the paper
# aligning with mafft converting to  phylip format
mafft  --auto --phylipout --reorder aligned_full_dataset.fasta > aligned_full_dataset.phylip
#removed gaps with jalview GUI
#installing phyml
sudo apt-get install -y phyml
#running phyml on hpc
#pushing file to hpc
 scp jal_aligned_edited_clean_reference_dataset.phy  joyce_wangari@hpc01.icipe.org:jal_aligned_edited_clean_reference_dataset.phy
#running on hpc 
	module load phyml
# running phyml on hpc failed. we decided to down sample our sequences to 17 plus 10 Mandera sequences
#we picked representatives from the tree in the paper: took accession numbers and downloaded as we did for our other sequences
 # running jmodeltest with 27 samples got  GTR+I+R as the model with lowest criterion value
#aligned with mafft
#!/nin/bash 
mafft  --auto --phylipout --reorder  aligned_full_dataset.fasta  > aln_reference_dataset.phy



# run phyml on the local machine.
model GTR +G+I
# visualized tree with tempest and itol


#Running raxml
#installing raxml
sudo apt-get install -y  raxml
# running raxml 
#!/usr/bin/bash

## running raxml  
raxmlHPC -d -b 3 -p 70 -#500 -s reference_dataset.phy -m GTRGAMMA -n treefile -w /home/icipe/Allan/Project1/data/Alignment/Results
# visualized tree using itol 
