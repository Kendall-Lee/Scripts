#!/bin/bash
#SBATCH --job-name=SRA_upload_pt1	# Job name
#SBATCH --nodes=1		    # N of nodes
#SBATCH --ntasks=4
#SBATCH --mem=48G		# Memory per node; by default using M as unit
#SBATCH --time=120:00:00    # Time limit hrs:min:sec or days-hours:minutes:seconds
#SBATCH --export=ALL        #export users explicit environment variables to compute node
#SBATCH --output=%x_%j.out	# Standard output log
#SBATCH --error=%x_%j.err		# Standard error log
#SBATCH --partition=normal

# login and make directory for upload on sra server
cd /cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_upload
#
# mkdir transferred # make temp dir to move succesffully transferred files to
#
# #did this before running the rest of it. Comment out before submitting job for loop.
# ftp -i
# open ftp-private.ncbi.nlm.nih.gov
# subftp
# CrasHeshyevVafivgud2
# cd uploads/lee.kendall.94_gmail.com_seoj7VjE
# mkdir SUB123456_related_data

for f in *.fastq.gz
do
ftp -in ftp-private.ncbi.nlm.nih.gov << EOF
quote USER subftp
quote PASS CrasHeshyevVafivgud2
cd uploads/lee.kendall.94_gmail.com_seoj7VjE
mput $f
quit
EOF
echo $f "transferred"
done

#if you need to delete things, you can't use rm - you have to use 'delete'

## annotated version below -- no need to run just for reference!
#for f in *.gz  # This line iterates over all files in the current directory with a .gz extension and assigns each filename to the variable 'f'.
#do
#    ftp -in ftp-private.ncbi.nlm.nih.gov << EOF  # This line initiates an FTP connection to the specified server with the options '-in', which disables interactive prompting and restricts transfers to text mode.
#    quote USER subftp  # This line sends a FTP command to authenticate with the username 'subftp'.
#    quote PASS CrasHeshyevVafivgud2  # This line sends a FTP command to authenticate with the password 'CrasHeshyevVafivgud2'.
#    cd uploads/charityzitting17_gmail.com_ia4pOfbf/NCBI_upload_pt1  # This line changes the directory on the remote FTP server.
#    mput $f  # This line uploads the current file (stored in the variable 'f') to the remote directory.
#    quit  # This line sends the quit command to close the FTP connection.
#EOF   # This marks the end of the FTP commands block.
#mv $f NCBI_upload_pt1/$f
#done  # This marks the end of the loop. The loop will iterate over each file in the directory until there are no more files matching the '*.gz' pattern.
