#! /bin/bash
#SBATCH --job-name=qsiprep_recon
#SBATCH --ntasks=1 --nodes=1
#SBATCH --mem-per-cpu=40G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=lucinda.sisk@yale.edu
#SBATCH --partition=week

ml purge
sub=$1

#DSI Studio installed locally within QSIprep dir
#MRTrix installed locally

subjdir='/gpfs/milgram/scratch60/gee_dylan/lms233/QSIPrep/bids_data'
datadir='/gpfs/milgram/project/gee_dylan/candlab/analyses/shapes/dwi/QSIPrep'
home='/gpfs/milgram/pi/gee_dylan/candlab/analyses/shapes/dwi/QSIPrep'
scripts='/gpfs/milgram/pi/gee_dylan/lms233/QSIprep'

in_dir=${datadir}/output_data/qsiprep
recon_dir=${datadir}/output_data
workdir=${subjdir}/../working_dir

cd /gpfs/milgram/pi/gee_dylan/lms233/QSIprep

singularity run -B ${subjdir},${recon_dir} qsiprep-0.14.3.sif ${subjdir} ${recon_dir} participant --participant_label ${sub} --recon-only --skip-bids-validation --recon_input ${in_dir} --recon_spec mrtrix_multishell_msmt --fs-license-file='/home/lms233/license.txt' --work-dir=${workdir} --nthreads 8
