# WHAT WE NEEDED TO DO
1. Download full CHIKV genome sequences from genbank
2. Align the sequences
3. Create a neighbour joining tree
4. Load the tree on Tempest to use the results to filter our dataset
5. Remove all sequences without sampling location and dates, those with long stretches of Ns and all outliers
6. Align the sequences together with the Mandera sequences
7. *Test for recombination -we did not do this*
8. Run jmodeltest to determine thr best model of nucleotide substitution
9. Create maximum likehood trees with phyml and raxml to be able to see the various lineages and locate the lineage for our Mandera sequence
10. Locate the Mandera sequence lineage
12. Use only ECSA lineage as reference data set
13. Run the downsampled to data set on Beast


## 1. Downloading sequences from genbank
- We first retrieved the Mandera-Kenya sequences and the full genomes from genbank

### a. Creating an accession list file for Mandera sequences
- we first created an accession list file 

      #!/usr/bin/bash
      # Retrieving Mandera sequences data from GenBank
      # Creating a list of accession numbers 
      echo -e MH423{797..811}"\n" | sed 's/ //g' > mandera_chikv.txt 
      
**output:**  [10 Mandera sequences accession numbers](https://github.com/WANGARIJOYCE/CHIKV_PROJECT/blob/main/mandera_chikv_accession_numbers.txt)

### b. Installing edirect utilities so as to be able to download sequences from genbank
    #Install edirect utilities
    sh -c "$(wget -q ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh -O -)"
    
    #Exporting PATH
    
    echo "export PATH=\$PATH:\$HOME/edirect" >> $HOME/.bash_profile

### c. Looping through  the accession list using edirect fuctionality
    # retrieve sequences 
    for i in $(cat mandera_chikv.txt)
    do
    esearch -db nucleotide -query $i | efetch -format fasta >> complete_genome_10seqs_mandera_dated.fasta
    done
**output:**  [10_mandera_sequences.fasta](https://github.com/WANGARIJOYCE/CHIKV_PROJECT/blob/main/complete_genome_10seqs_mandera_dated.fasta)

### d. Retrieving global sequence data from GenBank 
 - We used a pre-generated accession list from genbank
 
 
        for i in $(cat 786_accession_list.txt)
       do
       esearch -db nucleotide -query $i | efetch -format fasta >> all_chikv_genome.fasta
       done
**output:**  [all_chikv_genome.fasta](https://github.com/WANGARIJOYCE/CHIKV_PROJECT/blob/main/all_chikv_genome.fasta)
## 2. Cleaning the data
### a. Filtering out samples with collection dates
- We needed to retain only the sequences that had dates

- We filtered our sequences with dates on the identifiers,starting with the '19..' sequences followed by '20..'

- The output contained an accession list for all sequences that had dates n=324
  
        grep ">" all_chikv_genome.fasta | grep -w "[1][9][0-9][0-9]," | head -n 6  > 19s_identifiers.txt
	
        grep ">" all_chikv_genome.fasta | grep -w "[2][0][0-9][0-9]"  > 20s_identifiers.txt
	
          # Creating a combined accession list
	  
          cut -f 1 19s_identifiers.txt > dated_324_accessions_chikv.txt
	  
          cut -f 1 20s_identifiers.txt >> dated_324_accessions_chikv.txt
    
**Output:**[324 sequences accession list](https://github.com/WANGARIJOYCE/CHIKV_PROJECT/blob/main/dated_324_accessions_chikv.txt)
### b. Retrieving  the sequences that had dates
    #Retrieving only filtered sequences
    # we used accession list generated above = 324 sequences
    for i in $(cat Accessions.txt)
    do
    esearch -db nucleotide -query $i | efetch -format fasta >> dataset1.fasta
    done
**output:** [324_sequences.fasta](url)

## 3. Multiple sequence alignment using MAFFT
    mafft  --auto --phylipout --reorder dataset1.fasta > aligned_dataset1.fasta
**output:** [alignment_file.fasta](url)

## 4. Running TempEst
### a. Neighbour Joining Tree
- We created a neighbour joining tree using MEGAX GUI using default parameters
- The input of TempEst is a tree.
- 
### b. Installing TempEst
    
    sudo apt-get install -y tempest
    
    #running TempEst
    
    cd TempEst_v1.5.3/
    
      cd bin/
      
      ./tempest 

- From tempest we removed outliers and all sequences  without sampling location manually current n=283
- We combined our dataset with the 10 mandera kenya samples n=293

        cat complete_genome_10seqs_mandera_dated.fasta >> clean_reference_dataset
 
## 5. Inferring maximum likehood trees
### a. Installing jmodeltest
- First we installed jmodeltest to get the best substitution model
    sudo apt install jmodeltest
    #running jmodeltest
- jmodeltest failed for our 293sequences
- We proceeded with phyml and used substitution model GTR+G+I as in the paper
### b. Aligning with mafft and converting to  phylip format
    mafft  --auto --phylipout --reorder aligned_full_dataset.fasta > aligned_full_dataset.phylip
- removed gaps with jalview GUI
### c. Installing phyml
    sudo apt-get install -y phyml
    #running phyml on hpc
    #pushing file to hpc
     scp jal_aligned_edited_clean_reference_dataset.phy  joyce_wangari@hpc01.icipe.org:jal_aligned_edited_clean_reference_dataset.phy
    #running on hpc 
    module load phyml
- Running phyml on hpc failed. we decided to down sample our sequences to 17 plus 10 Mandera sequences
- we picked representatives from the tree in the paper: took accession numbers and downloaded as we did for our other sequences
- running jmodeltest with 27 samples got  GTR+I+G as the model with lowest criterion value


        #aligned with mafft
	
        #!/bin/bash 
	
        mafft  --auto --phylipout --reorder  aligned_full_dataset.fasta  > aln_reference_dataset.phy



### d. Running phyml on the local machine.
- model used: GTR +G+I

- We visualized tree with tempest and itol


### e.Running raxml
    #installing raxml
    
    sudo apt-get install -y  raxml
    
    # running raxml 
    #!/usr/bin/bash

    ## running raxml  
    raxmlHPC -d -b 3 -p 70 -#500 -s reference_dataset.phy -m GTRGAMMA -n treefile -w /home/icipe/Allan/Project1/data/Alignment/Results
    
 - visualized tree using itol 
 
 ### *PRESENTATION* DATE 26/11/2021
 - We decided to continue with BEAST with our trial sample n=27
 

#!/bin/bash 


#Install beast executables
wget https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.4/BEASTv1.10.4.tgz

# Extract files 
tar -zcvf BEASTv1.10.4.tgz

# Move to the Beast directory  then to the /bin  
cd BEASTv1.10.4/bin

# Install beagle library 
# Prepare prerequesites
sudo apt-get install gcc 
sudo apt-get install cmake
sudo apt-get install autoconf
sudo apt-get install automake
sudo apt-get install libtool
sudo apt-get install subversion
sudo apt-get install pkg-config

# Compile and install beagle library from source code repository 
git clone --depth=1 https://github.com/beagle-dev/beagle-lib.git
# moves to /beagle-lib directory
cd beagle-lib 
# create a directory /build
mkdir build
# move into the /build directory
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$HOME .. 
make install

 The project required us to downsample our dataset and only use those of ESCA lineage
# We downloaded the global chikungunya dataset from a paper"Co-Circulation of Two Independent Clades and Persistence of CHIKV-ECSA Genotype d>
# The paper had been published in 2020 so were confident that the information was up to date
# The data had been downloaded from VIRUS PATHOGEN RESOURCE (ViPR)
# First we confirmed whether our dataset was in their dataset so we got the accession numbers from the paper manually 767 of them
# Our original dataset that we had pulled and cleaned was 293 sequences including the 10 mandera sequences
#combining the 767 accesion numbers with the 293
cat 293_clean_accessions >> acc_767.txt

wc -l acc_767.txt
# This were 1060

sort acc_767.txt | uniq -d | wc -l
# This were 269
sort acc_767.txt | uniq -d > 269_accession.txt
# We decided to use the 269 because We knew the lineage, the country and the date of collection of each sequence which could be easily access>
 #downloading the 269 sequences
for i in $(cat 269_accession.txt)
do
esearch -db nucleotide -query $i |efetch -format -fasta >> 269_seqs.fasta
done

Aligning the sequences with MAFFT

#We then created a neighbour joining tree with MEGA
#We loaded the tree in TempEst
#visualising the Tree with TempEst showed that the Mandera sequences clustered together with sequences from ECSA
We decided to Infer maximum likehood tree with IQ tree because it could accept the Fasta format.
iqtree -s aln_dataset.fasta -m GTR+G+I -st DNA

We needed to use the fasta format as the phylip format  in phyml and raxml was truncating our identifiers which had dates
However the iqtree tool still truncated the identifiers



 
