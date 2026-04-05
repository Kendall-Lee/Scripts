
You should be able to download the R script, add execute permission to it, load an R module and run the R script. For example:

1. start an interactive session

interact

2. download the script pafCoordsDotPlotly.R

wget https://raw.githubusercontent.com/tpoorten/dotPlotly/master/pafCoordsDotPlotly.R

3. add execute permission to it

chmod u+x pafCoordsDotPlotly.R

4. load the R/4.1.0-foss-2019b module

ml R/4.1.0-foss-2019b

5. see the help page of this script

./pafCoordsDotPlotly.R -h

#!/bin/bash
#SBATCH --job-name=dotPlotly
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=100gb
#SBATCH --time=50:00:00
#SBATCH --output=dotPlotly.out
#SBATCH --error=dotPlotly.err
#SBATCH --mail-user=kcl58759@uga.edu
#SBATCH --mail-type=END,FAIL

ml R/4.1.0-foss-2019b

./pafCoordsDotPlotly.R -i 1033-CCS_output.paf -o out -l
